import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final _Cache cache = _Cache();

class _Cache {
  Database _db;

  Future<void> connect() async {
    Directory tempDirectory = await getTemporaryDirectory();
    String dbPath = path.join(tempDirectory.path, 'database.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
        """);
    });
  }
}
