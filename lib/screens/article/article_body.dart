import 'package:flutter/material.dart';

import '../../components/link_text_span.dart';

class ArticleBody extends StatefulWidget {
  final String text;

  ArticleBody(this.text, {Key key}) : super(key: key);

  @override
  ArticleBodyState createState() => ArticleBodyState();
}

class ArticleBodyState extends State<ArticleBody> {
  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(height: 1.15);
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: _buildTextSpans(context),
      ),
    );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    // TODO quoted text, selection, ...
    List<TextSpan> textSpans = [];
    Match prevMatch;
    // URI regex
    RegExp regex = RegExp(r'(https?|ftp)://(-\.)?([^\s/?\.#-]+\.?)+(/[^\s]*)?');
    for (Match match in regex.allMatches(widget.text)) {
      // Add raw text until match
      int textStart = prevMatch?.end ?? 0;
      textSpans.add(TextSpan(text: widget.text.substring(textStart, match.start)));
      // Add clickalbe uri
      String uri = match.group(0);
      textSpans.add(LinkTextSpan(
        text: uri,
        uri: uri,
        context: context,
      ));
      prevMatch = match;
    }
    // Add raw text after last match
    int textStart = prevMatch?.end ?? 0;
    if (textStart <= widget.text.length) {
      textSpans.add(TextSpan(text: widget.text.substring(textStart, widget.text.length)));
    }
    return textSpans;
  }
}
