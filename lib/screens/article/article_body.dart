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

  bool containsQuote = false;
  bool hideQuote = true;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.body1.copyWith(height: 1.15);
    final List<TextSpan> textSpans = _buildTextSpans(context).toList();
    final List<Widget> children = [
      RichText(
        text: TextSpan(
          style: textStyle,
          children: textSpans,
        ),
      )
    ];
    if (containsQuote) {
      children.insert(
          0,
          FlatButton(
            onPressed: () => setState(() => hideQuote = !hideQuote),
            child: Text('${hideQuote ? 'Show' : 'Hide'} quotes',
                style: theme.textTheme.button.copyWith(
                    fontWeight: FontWeight.w400,
                    color: theme.primaryColor,
                    fontStyle: FontStyle.italic)),
          ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Grey out quoted text, monospace signature
  Iterable<TextSpan> _buildTextSpans(BuildContext context) sync* {
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
                line.contains(RegExp(r'am|on|wrote|schrieb|:\r?$', caseSensitive: false))) {
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
        yield _getTextSpan(context, text, prevTextState, textStyles[prevTextState]);
        text = '';
      }
      if (last) {
        // No change will happen after last line, yield the rest
        yield _getTextSpan(context, text + newText, textState, textStyles[textState]);
      }

      // Append text
      text += newText;

      // Update previous textState
      prevTextState = textState;
    }
  }

  TextSpan _getTextSpan(
      BuildContext context, String text, TextState textState, TextStyle textStyle) {
    if (textState == TextState.quote) {
      containsQuote = true;
      if (hideQuote) {
        return TextSpan(text: '> ...${text.endsWith('\n') ? '\n' : ''}', style: textStyle);
      }
    }
    return TextSpan(style: textStyle, children: _findUrls(text, context, textStyle).toList());
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
