import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart';

class LinkTextSpan extends TextSpan {
  LinkTextSpan(
      {@required String text,
      @required String uri,
      @required BuildContext context,
      TextStyle style})
      : super(
            text: text,
            style: style ?? _getDefaultStyle(context),
            recognizer: _getRecognizer(uri, context));
}

TextStyle _getDefaultStyle(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.textTheme.body1.copyWith(color: theme.primaryColor);
}

TapGestureRecognizer _getRecognizer(String uri, BuildContext context) {
  return TapGestureRecognizer()
    ..onTap = () {
      // TODO use chrome/firefox custom tabs
      launch(
        uri,
      ).catchError((err) {
        print('Can\'t launch uri "$uri": $err');
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Can\'t open URL: ${err.runtimeType}'),
        ));
      });
    };
}
