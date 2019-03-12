/// Base NNTP exception
class NntpException implements Exception {
  final int code;
  final String message;

  NntpException(String response)
      : code = int.tryParse(response.substring(0, 3)),
        message = response.substring(4);

  @override
  String toString() {
    return '$code $message';
  }
}

/// 4xx errors: Command was syntactically correct but failed for some reason
class NntpServerException extends NntpException {
  NntpServerException(String response) : super(response);
}

/// 5xx errors: Command unknown, unsupported, unavailable, or syntax error
class NntpSyntaxException extends NntpException {
  NntpSyntaxException(String response) : super(response);
}

/// Read timeout
class NntpTimeoutException implements Exception {}
