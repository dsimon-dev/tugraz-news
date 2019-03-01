import 'overview.dart';

// TODO proper mime message parsing

class Article extends Overview {
  final String body;

  Article(Overview over, this.body)
    : super(over.newsgroup, over.number, over.subject, over.fromName, over.fromEmail,
            over.dateTime, over.messageId, over.references, over.replies, over.depth);

  /// Create an [Article] object from an nntp response
  factory Article.fromResponse(Overview overview, String response) {
    List<String> meta = response.split('\r\n\r\n')[0].split('\r\n');
    List<String> typeLines = meta.where((m) => m.startsWith('Content-Type:')).toList();
    String type = typeLines.isEmpty
      ? 'text/plain'
      : typeLines[0].split(':')[1].split(';')[0].trim();
    String body;
    if (type == 'text/plain') {
      body = response.split('\r\n\r\n').sublist(1).join('\r\n\r\n');
    } else if (type == 'multipart/mixed') {
      // TODO attachments
      try {
        String boundary = RegExp(r'boundary="(.+?)"').firstMatch(response).group(1);
        List<String> lines = response.split(boundary)[2].split('\r\n');
        body = lines.sublist(4, lines.length - 1).join('\r\n');
      } catch (err) {
        print('Error retrieving article ${overview.messageId}: ${err.toString()}');
        body = 'Error retrieving article';
      }
    } else {
      print('Unknown article type $type for ${overview.messageId}');
      body = 'Error: Unknown article type';
    }

    // Remove random newlines
    // Don't touch this or everything breaks
    body = body.trim().replaceAllMapped(RegExp(r'([^>\n] )\r\n(>+ )?'), (match) => match.group(1));

    // Apparently flutter doesn't like tabs
    body = body.replaceAll('\t', '  ');
    return Article(overview, body);
  }
}
