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
    // TODO hyperlinks, quoted text, selection, ...
    final TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(height: 1.15);
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: _buildTextSpans(context),
      ),
    );
    // return Text(
    //   widget.text,
    //   style: textStyle,
    // );
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    List<TextSpan> textSpans = [];
    Match prevMatch;
    RegExp regex = RegExp(r'(https?|ftp)://(-\.)?([^\s/?\.#-]+\.?)+(/[^\s]*)?');
    for (Match match in regex.allMatches(widget.text)) {
      int textStart = (prevMatch?.end ?? -1) + 1;
      textSpans.add(
        TextSpan(
          text: widget.text.substring(textStart, match.start)
        )
      );
      String uri = match.group(0);
      textSpans.add(
        LinkTextSpan(
          text: uri,
          uri: uri,
          context: context,
        )
      );
      prevMatch = match;
    }
    // TODO trailing text block
    return textSpans;
  }
}
