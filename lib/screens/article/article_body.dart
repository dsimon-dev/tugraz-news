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

  /// Grey out quoted text, monospace signature
  Iterable<TextSpan> _buildTextSpans(BuildContext context) sync* {
    // TODO add show/hide quoted text (gmail)

    final TextStyle quoteStyle = Theme.of(context).textTheme.body1.copyWith(color: Colors.grey);
    final TextStyle sigStyle =
        Theme.of(context).textTheme.body1.copyWith(fontFamily: 'RobotoMono', fontSize: 12);
    final List<String> lines = widget.text.split('\n');

    bool isQuote = false;
    bool isSig = false;

    // Classic for-loop because index is needed
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];

      // Don't add \n to last line
      String text = i == lines.length - 1 ? line : '$line\n';

      // Determine if signature starts
      if (line.startsWith('-- ')) {
        isSig = true;
      }

      if (!isSig) {
        // Determine if current line is part of a quote
        isQuote = false;
        if (line.startsWith('> ')) {
          isQuote = true;
        } else if (i < lines.length - 1 &&
            lines[i + 1].startsWith('> ') &&
            line.contains(RegExp(r'am|on|wrote|schrieb', caseSensitive: false))) {
          // Also grey out one line before the quote ("On <date> <time>, <name> wrote:")
          isQuote = true;
        }
      }

      TextStyle textStyle = isSig ? sigStyle : isQuote ? quoteStyle : null;
      yield TextSpan(
        style: textStyle,
        children: _findUrls(text, context, textStyle).toList(),
      );
    }
  }

  /// Create clickable URLs
  Iterable<TextSpan> _findUrls(String text, BuildContext context, TextStyle textStyle) sync* {
    Match prevMatch;
    for (Match match in _urlRegex.allMatches(text)) {
      // Add text before match
      int textStart = prevMatch?.end ?? 0;
      yield TextSpan(text: text.substring(textStart, match.start));
      // Add clickable uri
      String uri = match.group(0);
      yield LinkTextSpan(
        text: uri,
        uri: uri,
        context: context,
        style: textStyle?.copyWith(color: Theme.of(context).primaryColor),
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
