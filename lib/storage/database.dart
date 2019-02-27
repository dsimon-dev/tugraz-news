import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart';

import '../models/newsgroup.dart';

final _Database database = _Database();

class _Database {
  Database _db;

  Future<void> connect() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = path.join(databasesPath, 'database.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      await db.execute("""
          CREATE TABLE newsgroup (
            id INTEGER PRIMARY KEY,
            name TEXT UNIQUE NOT NULL,
            description TEXT
          );
        """);
    });
  }

  Future<List<Newsgroup>> getNewsgroups() async {
    List<Map<String, dynamic>> results =
        await _db.rawQuery('SELECT * FROM newsgroup ORDER BY name ASC');
    return results.map((map) => Newsgroup.fromMap(map)).toList();
  }

  Future<void> addNewsgroup(Newsgroup group) async {
    await _db.rawInsert(
        'INSERT INTO newsgroup (name, description) VALUES (?, ?)', [group.name, group.description]);
  }

  Future<void> removeNewsgroup(Newsgroup group) async {
    await _db.rawDelete('DELETE FROM newsgroup WHERE name = ?', [group.name]);
  }
}
