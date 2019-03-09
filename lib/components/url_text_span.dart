import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart';

class UrlTextSpan extends TextSpan {
  UrlTextSpan(
      {@required String text,
      @required String url,
      @required BuildContext context,
      @required TapGestureRecognizer recognizer,
      TextStyle style})
      : super(
            text: text,
            style: style ?? _getDefaultStyle(context),
            recognizer: recognizer..onTap = () => _launchUrl(url, context));
}

TextStyle _getDefaultStyle(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.textTheme.body1.copyWith(color: theme.primaryColor);
}

void _launchUrl(String url, BuildContext context) {
  // TODO use chrome/firefox custom tabs
  launch(url).catchError((err) {
    print('Can\'t launch uri "$url": $err');
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Can\'t open URL: ${err.runtimeType}'),
    ));
  });
}
