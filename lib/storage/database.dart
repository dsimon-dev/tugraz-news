import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart';

import '../models/newsgroup.dart';
import '../models/overview.dart';

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
        )
      """);
      await db.execute("""
        CREATE TABLE article_info (
          message_id TEXT PRIMARY KEY,
          newsgroup_name TEXT NOT NULL,
          read INTEGER NOT NULL
        )
      """);
    });
  }

  Future<List<Newsgroup>> getNewsgroups() async {
    final List<Map<String, dynamic>> results =
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

  Future<bool> isArticleRead(String messageId) async {
    final List<Map<String, dynamic>> info =
        await _db.rawQuery('SELECT read FROM article_info WHERE message_id = ?', [messageId]);
    return info.isNotEmpty && info.first['read'] == 1;
  }

  /// Mark an [Overview]/[Article] as read
  Future<void> markArticleRead(Overview over) async {
    await _db.transaction((txn) async {
      final info = await txn
          .rawQuery('SELECT read FROM article_info WHERE message_id = ?', [over.messageId]);
      if (info.isEmpty) {
        // insert
        await txn.rawInsert("""
          INSERT INTO article_info (message_id, newsgroup_name, read)
          VALUES (?, ?, ?)
        """, [over.messageId, over.newsgroup.name, 1]);
      } else if (info.first['read'] != 1) {
        // update
        await txn.rawUpdate("""
          UPDATE article_info
          SET read = ?
          WHERE message_id = ?
        """, [1, over.messageId]);
      }
    });
  }

  /// Mark an article as unread
  Future<void> markArticleUnread(String messageId) async {
    await _db.rawUpdate("""
      UPDATE article_info
      SET read = ?
      WHERE message_id = ?
    """, [0, messageId]);
  }
}
