import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'exceptions.dart';

/// Connects to NNTP server via [RawSocket]
/// TODO automatic reconnect
/// TODO offline
class NntpConnector {
  RawSocket _socket;
  bool _locked;

  /// Connect to socket and return welcome message
  Future<String> connect(String host, int port) async {
    // Connect
    _locked = true;
    _socket = await RawSocket.connect(host, port);

    // Get welcome msg
    String welcome = await _readFirstLine();

    // Send something so server doesn't close socket
    await _write('CAPABILITIES');
    await _readUntilTerminator();

    return welcome;
  }

  /// Send a 'LIST NEWSGROUPS' command
  Future<String> newsgroups() async {
    await _write('LIST NEWSGROUPS');
    return await _readUntilTerminator();
  }

  /// Send a 'GROUP <groupName>' command to select a group
  Future<String> group(String groupName) async {
    await _write('GROUP $groupName');
    return await _readFirstLine();
  }

  /// Send an 'OVER <low>-<high>' command for the currently selected newsgroup
  Future<String> over(int low, int high) async {
    await _write('OVER $low-$high');
    return await _readUntilTerminator();
  }

  /// Send an 'ARTICLE <number>' command for the currently selected newsgroup
  Future<String> article({int number, String messageId}) async {
    await _write('ARTICLE ${number ?? messageId}');
    return await _readUntilTerminator();
  }

  Future<void> destroy() async {
    print('destroying socket');
    await _socket.close();
  }

  /// Calls [_readFirstLine] once, then [_read] until the terminator '\r\n.\r\n' is found
  Future<String> _readUntilTerminator({bool raw = false}) async {
    String response = await _readFirstLine(unlock: false);
    while (!response.endsWith('\r\n.\r\n')) {
      response += await _read();
    }
    _locked = false;
    if (raw) {
      return response;
    }
    // Remove first line and terminator, replace encoded terminator
    return response
        .substring(response.indexOf('\r\n') + 2, response.length - 5)
        .replaceAll('\r\n..\r\n', '\r\n.\r\n');
  }

  /// Calls [_read] once
  /// Throws [NntpServerException] on 4xx errors
  /// Throws [NntpSyntaxException] on 5xx errors
  Future<String> _readFirstLine({bool unlock = true}) async {
    String response = await _read();
    if (unlock) {
      _locked = false;
    }
    if (response.startsWith('4')) {
      _locked = false;
      throw NntpServerException(response);
    }
    if (response.startsWith('5')) {
      _locked = false;
      throw NntpSyntaxException(response);
    }
    return response;
  }

  /// Calls [_socket.read] and decodes the response
  Future<String> _read() async {
    await _waitForResponse();

    // Decode bytes, try utf-8 first, then latin-1 (ISO-8859-1)
    final List<int> bytes = _socket.read();
    String response;
    try {
      response = utf8.decode(bytes);
    } on FormatException {
      try {
        response = latin1.decode(bytes);
      } on FormatException {
        response = utf8.decode(bytes, allowMalformed: true);
      }
    }

    // Decode base64 (B) and quoted printable (Q)
    Iterable<Match> matches = RegExp(
      r'=\?.+?\?(b|q)\?(.+?)\?=',
      caseSensitive: false,
    ).allMatches(response);
    for (Match match in matches) {
      String full = match.group(0);
      String encType = match.group(1).toLowerCase();
      String inner = match.group(2);
      String decoded;
      switch (encType) {
        // base64
        case 'b':
          try {
            decoded = utf8.decode(base64.decode(inner));
          } catch (e) {
            print('Can\'t decode base64 $inner');
            print('Error: $e');
            decoded = inner;
          }
          break;
        // quoted printable
        case 'q':
          String replaced = inner.replaceAll('=', '%').replaceAll('_', '%20');
          // Try utf-8
          try {
            // print(replaced);
            decoded = Uri.decodeFull(replaced);
          } on FormatException {
            // If that didn't work, try latin1
            try {
              decoded = Uri.decodeQueryComponent(replaced, encoding: Latin1Codec());
            } on FormatException {
              // Shit
              print('Can\'t decode quoted printable $replaced, unknown format');
              decoded = inner;
            }
          } on ArgumentError {
            // Malformed url
            print('Can\'t decode quoted printable $replaced, malformed encoding');
            decoded = inner;
          }
          break;
        default:
          print('Unknown encoding type: $encType');
          decoded = inner;
      }
      response = response.replaceFirst(full, decoded);
    }
    return response;
  }

  /// Waits for server response with [_socket.available]
  /// Throws [NntpTimeoutException] after 3 seconds
  Future<void> _waitForResponse() async {
    int counter = 0;
    while (_socket.available() == 0) {
      await Future.delayed(Duration(milliseconds: 10));
      counter++;
      if (counter > 300) {
        throw NntpTimeoutException;
      }
    }
  }

  /// Add CRLF, encode, write
  Future<void> _write(String cmd) async {
    while (_locked) {
      await Future.delayed(Duration(milliseconds: 10));
    }
    _locked = true;
    _socket.write(utf8.encode('$cmd\r\n'));
  }
}
