import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/article.dart';
import '../models/newsgroup.dart';
import '../models/overview.dart';

final _Cache cache = _Cache();

class _Cache {
  Database _db;

  Future<void> connect() async {
    Directory tempDirectory = await getTemporaryDirectory();
    String dbPath = path.join(tempDirectory.path, 'database.db');
    _db = await openDatabase(dbPath, version: 1, onCreate: (Database db, int version) async {
      print('creating cache db');
      // The 'refs' (references) column is stored as a comma-separated list
      await db.execute("""
        CREATE TABLE article (
          message_id TEXT PRIMARY KEY,
          newsgroup_name TEXT NOT NULL,
          number INTEGER NOT NULL,
          subject TEXT NOT NULL,
          from_name TEXT NOT NULL,
          from_email TEXT NOT NULL,
          datetime TEXT NOT NULL,
          refs TEXT,
          body TEXT
        )
      """);
    });
  }

  /// Delete all articles, return amount deleted
  Future<int> clear() async {
    final int count = await _db.rawDelete('DELETE FROM article');
    await _db.execute('VACUUM');
    return count;
  }

  /// Get the total amount of cached articles
  Future<int> getArticleCount() async {
    return (await _db.rawQuery('SELECT COUNT(*) FROM article')).first.values.first;
  }

  /// Returns a list of [Overview] (if body is null) or [Article] objects for a given newsgroup
  /// Ordered by number ascending (oldest first)
  Future<List<Overview>> getArticles(Newsgroup newsgroup) async {
    final rows = await _db.rawQuery("""
      SELECT *
      FROM article
      WHERE newsgroup_name = ?
      ORDER BY number ASC
    """, [newsgroup.name]);
    return rows.map((row) {
      final overview = Overview(
        newsgroup,
        row['number'],
        row['subject'],
        row['from_name'],
        row['from_email'],
        DateTime.tryParse(row['datetime']) ?? DateTime.now(),
        row['message_id'],
        row['refs'] == null ? [] : (row['refs'] as String).split(','),
      );
      return row['body'] == null ? overview : Article(overview, row['body']);
    }).toList();
  }

  /// Adds an [Overview] or [Article] to the cache
  Future<void> addOverview(Overview overview) async {
    // TODO add body if article
    await _db.rawInsert("""
      INSERT OR REPLACE INTO article (
        message_id,
        newsgroup_name,
        number,
        subject,
        from_name,
        from_email,
        datetime,
        refs
      ) VALUES (
        ?, ?, ?, ?, ?, ?, datetime(?), ?
      )
    """, [
      overview.messageId,
      overview.newsgroup.name,
      overview.number,
      overview.subject,
      overview.fromName,
      overview.fromEmail,
      overview.dateTime.toIso8601String(),
      overview.references.isEmpty ? null : overview.references.join(',')
    ]);
  }
}
