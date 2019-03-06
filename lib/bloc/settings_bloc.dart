import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/cache.dart';
import 'bloc_provider.dart';

class SettingsBloc implements BlocBase {
  final BehaviorSubject<Settings> _subject = BehaviorSubject<Settings>();
  ValueObservable<Settings> get stream => _subject.stream;

  SettingsBloc() {
    update();
  }

  Future<void> setUseDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDarkTheme', value);
    await update();
  }

  Future<int> clearCache() async {
    final int count = await cache.clear();
    await update();
    return count;
  }

  Future<void> update() async {
    final Settings settings = Settings();
    await settings.load();
    _subject.sink.add(settings);
  }

  @override
  void dispose() {
    _subject.close();
  }
}

class Settings {
  bool useDarkTheme;
  int cacheSize;
  int cacheCount;

  String get cacheSizeStr =>
      cacheCount == 0 ? '0' : '$cacheCount, ${(cacheSize / 1000 / 1000).toStringAsFixed(1)}MB';

  Future<void> load() async {
    // Shared preferences
    final prefs = await SharedPreferences.getInstance();
    useDarkTheme = prefs.getBool('useDarkTheme') ?? false;

    // Cache
    Directory tempDirectory = await getTemporaryDirectory();
    String cachePath = path.join(tempDirectory.path, 'database.db');
    cacheSize = await File(cachePath).length();
    cacheCount = await cache.getArticleCount();
  }
}
