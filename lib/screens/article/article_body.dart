import 'package:flutter/material.dart';

import '../../components/link_text_span.dart';

class ArticleBody extends StatefulWidget {
  final String text;

  ArticleBody(this.text, {Key key}) : super(key: key);

  @override
  ArticleBodyState createState() => ArticleBodyState();
}

class ArticleBodyState extends State<ArticleBody> {
  final RegExp _urlRegex = RegExp(r'https?://[\w\-.]+\.[\w/\-.?&=%+]+');

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(height: 1.15);
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: _buildTextSpans(context).toList(),
      ),
    );
  }

  /// Grey out quoted text
  Iterable<TextSpan> _buildTextSpans(BuildContext context) sync* {
    final TextStyle quoteStyle =
        Theme.of(context).textTheme.body1.copyWith(color: Colors.grey.shade400);
    final List<String> lines = widget.text.split('\n');
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      // Don't add \n to last line
      String text = i == lines.length - 1 ? line : '$line\n';
      yield TextSpan(
        style: line.startsWith('>') ? quoteStyle : null,
        children: _findUrls(text, context).toList(),
      );
    }
  }

  /// Create clickable URLs
  Iterable<TextSpan> _findUrls(String text, BuildContext context) sync* {
    Match prevMatch;
    for (Match match in _urlRegex.allMatches(text)) {
      // Add text before until match
      int textStart = prevMatch?.end ?? 0;
      yield TextSpan(text: text.substring(textStart, match.start));
      // Add clickable uri
      String uri = match.group(0);
      yield LinkTextSpan(
        text: uri,
        uri: uri,
        context: context,
      );
      prevMatch = match;
    }
    // Add text after last match
    int textStart = prevMatch?.end ?? 0;
    if (textStart <= text.length) {
      yield TextSpan(text: text.substring(textStart, text.length));
    }
  }
}
