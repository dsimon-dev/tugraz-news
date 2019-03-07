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
  Future<int> clear({Newsgroup newsgroup}) async {
    int count;
    if (newsgroup == null) {
      count = await _db.rawDelete('DELETE FROM article');
    } else {
      count = await _db.rawDelete('DELETE FROM article WHERE newsgroup_name = ?', [newsgroup.name]);
    }
    await _db.execute('VACUUM');
    return count;
  }

  /// Get the total amount of cached articles
  Future<int> getArticleCount() async {
    try {
      return (await _db.rawQuery('SELECT COUNT(*) FROM article')).first.values.first;
    } on StateError {
      return 0;
    }
  }

  /// Returns a list of [Overview] (if body is null) or [Article] objects for a given newsgroup
  /// Ordered by number ascending (oldest first)
  Future<List<Overview>> getArticles(Newsgroup newsgroup) async {
    return (await _db.rawQuery("""
      SELECT *
      FROM article
      WHERE newsgroup_name = ?
      ORDER BY number ASC
    """, [newsgroup.name])).map((row) {
      final overview = Overview.fromCache(newsgroup, row);
      return row['body'] == null ? overview : Article(overview, row['body']);
    }).toList();
  }

  /// Returns a list of [Article] objects for a given ids
  /// Ordered by number ascending (oldest first)
  Future<List<Article>> getArticlesByIds(Newsgroup newsgroup, List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    final String placeholders = (',?' * ids.length).substring(1);
    return (await _db.rawQuery("""
      SELECT *
      FROM article
      WHERE body IS NOT NULL
        AND message_id IN ($placeholders)
      ORDER BY number ASC
    """, ids)).map((row) {
      final overview = Overview.fromCache(newsgroup, row);
      return Article(overview, row['body']);
    }).toList();
  }

  /// Adds an [Overview] to the cache
  /// If [overview] is an [Article], [Article.body] is also added
  Future<void> addOverview(Overview overview) async {
    await _db.rawInsert("""
      INSERT OR REPLACE INTO article (
        message_id,
        newsgroup_name,
        number,
        subject,
        from_name,
        from_email,
        datetime,
        refs,
        body
      ) VALUES (
        ?, ?, ?, ?, ?, ?, datetime(?), ?, ?
      )
    """, [
      overview.messageId,
      overview.newsgroup.name,
      overview.number,
      overview.subject,
      overview.fromName,
      overview.fromEmail,
      overview.dateTime.toIso8601String(),
      overview.references.isEmpty ? null : overview.references.join(','),
      (overview is Article) ? overview.body : null,
    ]);
  }

  /// Adds [Article.body] to existing [Overview] in cache
  Future<bool> addArticle(Article article) async {
    final int updated = await _db.rawUpdate("""
      UPDATE article
      SET body = ?
      WHERE message_id = ?
    """, [
      article.body,
      article.messageId,
    ]);
    return updated > 0;
  }
}
