import 'package:flutter/material.dart';

import 'bloc/bloc_provider.dart';
import 'bloc/settings_bloc.dart';
import 'bloc/newsgroup_bloc.dart';
import 'nntp/nntp.dart';
import 'screens/home/home_screen.dart';
import 'storage/cache.dart';
import 'storage/database.dart';

void main() async {
  await database.connect();
  await cache.connect();
  print('databases & cache connected');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SettingsBloc settingsBloc = SettingsBloc();
    final NewsgroupBloc newsBloc = NewsgroupBloc();
    nntpClient.connect('news.tugraz.at', 119).then((msg) => print(msg));
    return BlocProvider<SettingsBloc>(
      bloc: settingsBloc,
      child: BlocProvider<NewsgroupBloc>(
        bloc: newsBloc,
        child: StreamBuilder(
            stream: settingsBloc.stream,
            builder: (BuildContext context, AsyncSnapshot<Settings> snapshot) {
              if (snapshot.hasData) {
                final bool dark = snapshot.data.useDarkTheme;
                final ThemeData theme = ThemeData(
                  brightness: dark ? Brightness.dark : Brightness.light,
                  primaryColor: Color(0xffa30f37),
                  accentColor: Color(0xffe4154b),
                  toggleableActiveColor: Color(0xffe4154b),
                );
                return MaterialApp(title: 'TU News', theme: theme, home: HomeScreen());
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
