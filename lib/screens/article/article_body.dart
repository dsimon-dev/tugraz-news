import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../components/url_text_span.dart';

enum TextState {
  normal,
  quote,
  signature,
}

class ArticleBody extends StatefulWidget {
  final String text;

  ArticleBody(this.text, {Key key}) : super(key: key);

  @override
  _ArticleBodyState createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<ArticleBody> {
  final RegExp _urlRegex = RegExp(r'https?://[\w\-.]+\.[\w/\-.?&=%+]+(#[\w\-%+]+)?');
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.body1.copyWith(height: 1.15);
    final List<TextSpan> textSpans = _buildTextSpans(context).toList();
    return RichText(
      text: TextSpan(
        style: textStyle,
        children: textSpans,
      ),
    );
  }

  /// Grey out quoted text, monospace signature
  Iterable<TextSpan> _buildTextSpans(BuildContext context) sync* {
    // TODO add show/hide quoted text (gmail)
    final Map<TextState, TextStyle> textStyles = {
      TextState.normal: null,
      TextState.quote: Theme.of(context).textTheme.body1.copyWith(color: Colors.grey),
      TextState.signature:
          Theme.of(context).textTheme.body1.copyWith(fontFamily: 'RobotoMono', fontSize: 12),
    };
    final List<String> lines = widget.text.split('\n');
    TextState textState;
    TextState prevTextState;
    String text = '';
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      bool last = i == lines.length - 1;
      String newText = last ? line : '$line\n'; // Don't add \n to last line

      // Update current textState, no change after signature was found
      if (textState != TextState.signature) {
        if (line.startsWith('-- ')) {
          textState = TextState.signature;
        } else if (line.startsWith('>') ||
            i < lines.length - 1 &&
                lines[i + 1].startsWith('>') &&
                line.contains(RegExp(r'am|on|wrote|schrieb', caseSensitive: false))) {
          // Quote or one line before quote ("On <date> <time>, <name> wrote:")
          textState = TextState.quote;
        } else {
          textState = TextState.normal;
        }
      }

      // Init prev textState
      if (i == 0) {
        prevTextState = textState;
      }

      if (textState != prevTextState) {
        // Build a text span on textState change
        yield TextSpan(
          style: textStyles[prevTextState],
          children: _findUrls(text, context, textStyles[prevTextState]).toList(),
        );
        text = '';
      }
      if (last) {
        // No change will happen after last line, yield the rest
        yield TextSpan(
          style: textStyles[textState],
          children: _findUrls(text + newText, context, textStyles[textState]).toList(),
        );
      }

      // Append text
      text += newText;

      // Update previous textState
      prevTextState = textState;
    }
  }

  /// Create clickable URLs
  Iterable<TextSpan> _findUrls(String text, BuildContext context, TextStyle textStyle) sync* {
    Match prevMatch;
    for (Match match in _urlRegex.allMatches(text)) {
      // Add text before match
      int textStart = prevMatch?.end ?? 0;
      yield TextSpan(text: text.substring(textStart, match.start));

      // Add clickable url
      String url = match.group(0);
      TapGestureRecognizer recognizer = TapGestureRecognizer();
      _recognizers.add(recognizer);
      yield UrlTextSpan(
        text: url,
        url: url,
        context: context,
        recognizer: recognizer,
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

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }
}
