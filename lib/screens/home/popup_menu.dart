import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/settings_bloc.dart';
import '../../components/url_text_span.dart';
import '../settings/settings_screen.dart';

class PopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      tooltip: 'Menu',
      onSelected: (dynamic value) => _onSelected(value, context),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem>[
          _item('Settings', MdiIcons.settingsOutline),
          _item('About', MdiIcons.informationOutline),
        ];
      },
    );
  }

  PopupMenuItem _item(String text, IconData icon) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: <Widget>[
          Icon(icon),
          SizedBox(
            width: 16,
          ),
          Text(text),
        ],
      ),
    );
  }

  void _onSelected(String value, BuildContext context) {
    value = value.toLowerCase();
    if (value == 'settings') {
      BlocProvider.of<SettingsBloc>(context).update();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsScreen()),
      );
    } else if (value == 'about') {
      _showAbout(context);
    }
  }

  void _showAbout(BuildContext context) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    showAboutDialog(
      context: context,
      applicationIcon: Container(
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        padding: EdgeInsets.all(10),
        child: Image(
          image: AssetImage('assets/icon/legacy_small.png'),
          height: 48,
          width: 48,
        ),
      ),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      children: <Widget>[
        _AboutContent(),
      ],
    );
  }
}

class _AboutContent extends StatefulWidget {
  _AboutContent({Key key}) : super(key: key);
  _AboutContentState createState() => _AboutContentState();
}

class _AboutContentState extends State<_AboutContent> {
  final List<TapGestureRecognizer> _recognizers = [];

  void initState() {
    super.initState();
    _recognizers.add(TapGestureRecognizer());
    _recognizers.add(TapGestureRecognizer());
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle linkTextStyle = theme.textTheme.subhead.copyWith(color: theme.primaryColor);
    return RichText(
      text: TextSpan(
        style: theme.textTheme.subhead.copyWith(height: 1.15),
        children: <TextSpan>[
          TextSpan(
              text: 'This project is open-source, you can view the code, ' +
                  'report issues and contribute on '),
          UrlTextSpan(
            text: 'GitHub',
            url: 'https://github.com/gerenook/tugraz-news',
            context: context,
            recognizer: _recognizers[0],
            style: linkTextStyle,
          ),
          TextSpan(text: '.\n\nMade with ❤️ and '),
          UrlTextSpan(
            text: 'Flutter',
            url: 'https://flutter.io/',
            context: context,
            recognizer: _recognizers[1],
            style: linkTextStyle,
          ),
          TextSpan(text: '.'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }
}
