import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc_provider.dart';

class SettingsBloc implements BlocBase {
  final BehaviorSubject<Settings> _subject = BehaviorSubject<Settings>();
  ValueObservable<Settings> get stream => _subject.stream;

  SettingsBloc() {
    _update();
  }

  @override
  void dispose() {
    _subject.close();
  }

  Future<void> setUseDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDarkTheme', value);
    await _update();
  }

  Future<void> _update() async {
    final Settings settings = Settings();
    await settings.load();
    _subject.sink.add(settings);
  }
}

class Settings {
  bool useDarkTheme;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    useDarkTheme = prefs.getBool('useDarkTheme') ?? false;
  }
}
