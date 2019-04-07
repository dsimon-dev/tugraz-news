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
          id INTEGER PRIMARY KEY,
          newsgroup_name TEXT NOT NULL,
          article_number INTEGER NOT NULL,
          read INTEGER NOT NULL
        )
      """);
    });
  }

  Future<List<Newsgroup>> getNewsgroups() async {
    final List<Map<String, dynamic>> results = await _db.rawQuery("""
      SELECT *
      FROM newsgroup
      ORDER BY name ASC
    """);
    return results.map((map) => Newsgroup.fromMap(map)).toList();
  }

  Future<void> addNewsgroup(Newsgroup group) async {
    await _db.rawInsert("""
      INSERT INTO newsgroup (name, description)
      VALUES (?, ?)
    """, [group.name, group.description]);
  }

  Future<void> removeNewsgroup(Newsgroup group) async {
    await _db.rawDelete('DELETE FROM newsgroup WHERE name = ?', [group.name]);
  }

  Future<bool> isArticleRead(Overview overview) async {
    final info = await _db.rawQuery("""
      SELECT read
      FROM article_info
      WHERE newsgroup_name = ?
        AND article_number = ?
    """, [overview.newsgroup.name, overview.number]);
    return info.isNotEmpty && info.first['read'] == 1;
  }

  /// Get a Set of [Overview] numbers that are marked as read
  Future<Set<int>> readArticles(Newsgroup newsgroup) async {
    final results = await _db.rawQuery("""
      SELECT article_number, read
      FROM article_info
      WHERE newsgroup_name = ?
    """, [newsgroup.name]);
    return Set.from(results.where((res) => res['read'] == 1).map((res) => res['article_number']));
  }

  /// Mark an [Overview]/[Article] as read (shallow)
  Future<void> markArticleRead(Overview over) async {
    await _db.transaction((txn) async {
      final info = await txn.rawQuery("""
        SELECT read
        FROM article_info
        WHERE newsgroup_name = ?
          AND article_number = ?
      """, [over.newsgroup.name, over.number]);
      if (info.isEmpty) {
        // insert
        await txn.rawInsert("""
          INSERT INTO article_info (newsgroup_name, article_number, read)
          VALUES (?, ?, 1)
        """, [over.newsgroup.name, over.number]);
      } else if (info.first['read'] != 1) {
        // update
        await txn.rawUpdate("""
          UPDATE article_info
          SET read = 1
          WHERE newsgroup_name = ?
            AND article_number = ?
        """, [over.messageId, over.number]);
      }
    });
  }

  /// Mark an article as unread
  Future<void> markArticleUnread(Overview overview) async {
    await _db.rawDelete("""
      DELETE FROM article_info
      WHERE newsgroup_name = ?
        AND article_number = ?
    """, [overview.newsgroup.name, overview.number]);
  }

  /// Mark all articles in a newsgroup as read
  Future<void> markNewsgroupRead(Newsgroup newsgroup) async {
    // TODO
  }

  /// Mark all articles in a newsgroup as unread
  Future<void> markNewsgroupUnread(Newsgroup newsgroup) async {
    await _db.rawDelete("""
      DELETE FROM article_info
      WHERE newsgroup_name = ?
    """, [newsgroup.name]);
  }
}
