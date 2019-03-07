import 'package:intl/intl.dart';

import 'newsgroup.dart';

class Overview {
  static final DateFormat dateTimeFormatIn = DateFormat('EEE, dd MMM yyyy HH:mm:ss ZZZZ');
  static final DateFormat dateTimeFormatInAlt = DateFormat('dd MMM yyyy HH:mm:ss ZZZZ');
  static final DateFormat dateTimeFormatOut = DateFormat('dd MMM yyyy, HH:mm');

  final Newsgroup newsgroup;
  final int number;
  final String subject;
  final String fromName;
  final String fromEmail;
  final DateTime dateTime;
  final String messageId;
  List<String> references;
  List<Overview> replies;
  int depth;
  bool read;

  Overview(this.newsgroup, this.number, this.subject, this.fromName,
      this.fromEmail, this.dateTime, this.messageId, this.references,
      [this.replies, this.depth]) {
    replies ??= [];
    depth ??= 0;
  }

  /// Create an [Overview] object from an nntp response
  factory Overview.fromResponse(Newsgroup group, String response) {
    // Each field is separated by a TAB (\t)
    List<String> fields = response.split('\t');
    List<String> from = fields[2].split(' ');
    String fromName = from.sublist(0, from.length - 1).join(' ');
    if (fromName.startsWith('"')) fromName = fromName.substring(1); // Name is in quotes sometimes
    if (fromName.endsWith('"')) fromName = fromName.substring(0, fromName.length - 1);
    String fromEmail = from.last.substring(1, from.last.length - 1); // Remove <>
    // TODO timezones are not parsed correctly
    DateTime dateTime;
    try {
      dateTime = dateTimeFormatIn.parse(fields[3]);
    } on FormatException {
      try {
        dateTime = dateTimeFormatInAlt.parse(fields[3]);
      } on FormatException {
        print('Cannot parse ${fields[3]}, setting datetime to current time');
        dateTime = DateTime.now();
      }
    }
    return Overview(
      group,
      int.parse(fields[0]),
      fields[1],
      fromName,
      fromEmail, 
      dateTime,
      fields[4],
      fields[5].split(' ')
    );
  }

  /// Create an [Overview] object from a cache query
  factory Overview.fromCache(Newsgroup newsgroup, Map<String, dynamic> row) {
    return Overview(
      newsgroup,
      row['number'],
      row['subject'],
      row['from_name'],
      row['from_email'],
      DateTime.tryParse(row['datetime']) ?? DateTime.now(),
      row['message_id'],
      row['refs'] == null ? [] : (row['refs'] as String).split(','),
    );
  }

  String get dateTimeString => dateTimeFormatOut.format(dateTime);
  String get authorAndDateTime => '$fromName  ⋅  $dateTimeString';
  DateTime get latestReplyDateTime {
    final List<Overview> sorted = flatten<Overview>()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return sorted.last.dateTime;
  }

  /// Return a list of this overview and all flattened replies
  List<T> flatten<T>() => replies.fold(<T>[this as T], (prev, over) => prev + over.flatten<T>());

  void deepPrint([int depth = 0]) {
    print(' ' * depth + subject);
    replies.forEach((r) => r.deepPrint(depth + 2));
  }

  bool operator ==(dynamic other) {
    if (other is Overview)
      return messageId == other.messageId;
    return false;
  }

  @override
  int get hashCode => messageId.hashCode;

  @override
  String toString() {
    return '<Overview id=\'$messageId\' subject=\'$subject\' name=\'$fromName>\'';
  }

  /// Get a list of [Overview] objects, grouped into threads with .replies property
  static List<Overview> groupOverviews(Iterable<Overview> overviews) {
    // Map messageId to Overview object for quick lookup
    final Map<String, Overview> overviewsMap =
        Map.fromIterable(overviews, key: (over) => over.messageId, value: (over) => over);

    // Identify replies and add to parent
    for (final overview in overviews) {
      // Add to existing overview if it is a reply (= has references)
      if (overview.references.isNotEmpty) {
        Overview refOverview = overviewsMap[overview.references.last];
        if (refOverview != null) {
          refOverview.replies.add(overview);
          overview.depth = refOverview.depth + 1;
        } else {
          // Reference not found, set to top level
          overview.references = [];
        }
      }
    }

    // Filter out overviews that are not top level, sort by latest reply
    return overviewsMap.values.where((over) => over.references.isEmpty).toList()
      ..sort((a, b) => b.latestReplyDateTime.compareTo(a.latestReplyDateTime));
  }
}
