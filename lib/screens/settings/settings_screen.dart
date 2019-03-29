import 'package:flutter/material.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/settings_bloc.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SettingsBloc bloc = BlocProvider.of<SettingsBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: StreamBuilder(
          stream: bloc.stream,
          builder: (BuildContext context, AsyncSnapshot<Settings> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: <Widget>[
                  _SettingsHeader('Appearance'),
                  SwitchListTile(
                    title: const Text('Dark theme'),
                    value: snapshot.data.useDarkTheme,
                    onChanged: (bool value) => bloc.setUseDarkTheme(value),
                  ),
                  Divider(),
                  _SettingsHeader('Storage'),
                  ListTile(
                    title: const Text('Clear cache'),
                    subtitle: Text('Removes saved articles (${snapshot.data.cacheSizeStr})'),
                    onTap: () async {
                      final int count = await bloc.clearCache();
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(count == 0
                            ? 'Cache is already empty'
                            : 'Cache cleared'),
                      ));
                    },
                  ),
                ],
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;

  _SettingsHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.subhead.copyWith(
      color: theme.accentColor,
      fontWeight: FontWeight.w600,
    );
    return ListTile(
      title: Text(
        title,
        style: textStyle,
      ),
    );
  }
}
