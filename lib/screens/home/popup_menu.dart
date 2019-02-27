import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';

import '../../components/link_text_span.dart';
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
          SizedBox(width: 16,),
          Text(text),
        ],
      ),
    );
  }

  void _onSelected(String value, BuildContext context) {
    value = value.toLowerCase();
    if (value == 'settings') {
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
    final ThemeData theme = Theme.of(context);
    final TextStyle linkTextStyle = theme.textTheme.subhead.copyWith(color: theme.primaryColor);
    showAboutDialog(
      context: context,
      applicationIcon: Image(
        image: AssetImage('assets/icon/legacy_small.png'),
        height: 48,
        width: 48,
      ),
      applicationName: packageInfo.appName,
      applicationVersion: packageInfo.version,
      children: <Widget>[
        RichText(
          text: TextSpan(
            style: theme.textTheme.subhead.copyWith(height: 1.15),
            children: <TextSpan>[
              TextSpan(
                text: 'This project is open-source, you can view the code, report issues and contribute on '
              ),
              LinkTextSpan(
                text: 'GitHub',
                uri: 'https://github.com/gerenook/tugraz-news',
                context: context,
                style: linkTextStyle,
              ),
              TextSpan(
                text: '.\n\nMade with ❤️ and '
              ),
              LinkTextSpan(
                text: 'Flutter',
                uri: 'https://flutter.io/',
                context: context,
                style: linkTextStyle,
              ),
              TextSpan(
                text: '.'
              ),
            ],
          ),
        ),
      ],
    );
  }
}
