import 'overview.dart';

class Article extends Overview {
  final String body;

  Article(Overview o, this.body)
    : super(o.newsgroup, o.number, o.subject, o.fromName, o.fromEmail,
            o.dateTime, o.messageId, o.references, o.replies, o.depth);

  /// Create an [Article] object from an nntp response
  factory Article.fromResponse(Overview overview, String response) {
    // TODO this whole thing is a hack, need to properly parse mime messages
    final List<String> meta = response.split('\r\n\r\n')[0].split('\r\n');
    final List<String> typeLines = meta.where((m) => m.startsWith('Content-Type:')).toList();
    final String type = typeLines.isEmpty
      ? 'text/plain'
      : typeLines[0].split(':')[1].split(';')[0].trim();
    String body;
    if (type == 'text/plain') {
      body = response.split('\r\n\r\n').sublist(1).join('\r\n\r\n');
    }
    else if (type.startsWith('multipart/')) {
      // TODO attachments, encoding
      try {
        String boundary;
        if (type == 'multipart/mixed') {
          boundary = RegExp(r'boundary="(.+?)"').firstMatch(response).group(1);
        }
        else if (type == 'multipart/signed') {
          boundary = RegExp(r'Content-Type: multipart/mixed.*?boundary="(.+?)"')
            .firstMatch(response)
            .group(1);
        }
        List<String> blocks = response
            .split(RegExp(r'\r\n.*?' + boundary))
            .firstWhere((t) => t.trim().startsWith('Content-Type: text/plain'))
            .split('\r\n\r\n');
        body = blocks.sublist(1, blocks.length).join('\r\n\r\n');
      }
      catch (err) {
        print('Error retrieving article ${overview.messageId}: ${err.toString()}');
        body = 'Error retrieving article';
      }
    }
    else {
      print('Unknown article type $type for ${overview.messageId}');
      body = 'Error: Unknown article type';
    }

    // Remove random newlines
    // ! Don't touch this or everything breaks
    body = body.trim().replaceAllMapped(RegExp(r'([^>\-\n] )\r\n(>+ )?'), (match) => match.group(1));

    // Apparently flutter doesn't like tabs
    body = body.replaceAll('\t', '  ');
    return Article(overview, body);
  }

  /// Get the root [Article] object with replies
  static Article groupArticles(Iterable<Article> articles) {
    final grouped = Overview.groupOverviews(articles);
    return grouped.isEmpty ? null : grouped.first as Article;
  }
}
