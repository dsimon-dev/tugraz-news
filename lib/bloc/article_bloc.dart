import 'dart:async';

import 'package:rxdart/rxdart.dart';

import '../models/article.dart';
import '../models/overview.dart';
import '../nntp/nntp.dart';
import '../storage/cache.dart';
import 'bloc_provider.dart';

class ArticleBloc implements BlocBase {
  final Overview _overview;

  Article _article;
  final BehaviorSubject<Article> _articleSubject = BehaviorSubject<Article>();
  ValueObservable<Article> get article => _articleSubject.stream;

  ArticleBloc(this._overview) {
    fetchArticle();
  }

  Future<void> fetchArticle() async {
    final overviewsFlat = _overview.flatten<Overview>();

    // Get cached articles
    final cachedArticles = await cache.getArticlesByIds(
        _overview.newsgroup, overviewsFlat.map((o) => o.messageId).toList());

    // Set read (hack :/)
    for (final article in cachedArticles) {
      try {
        article.read = overviewsFlat.firstWhere((over) => over.messageId == article.messageId).read;
      } on StateError {
        article.read = false;
      }
    }

    // Get new articles and add to cache
    final newArticles = <Article>[];
    Article newArticle;
    for (final overview in overviewsFlat) {
      if (!cachedArticles.any((article) => article.messageId == overview.messageId)) {
        newArticle = (await nntpClient.articleShallow(overview))..replies.clear();
        newArticles.add(newArticle);
        await cache.addArticle(newArticle);
      }
    }

    print('Articles: ${cachedArticles.length} cached, ${newArticles.length} new');

    // Group into thread
    _article = Article.groupArticles(cachedArticles + newArticles);
    _articleSubject.sink.add(_article);
  }

  @override
  void dispose() {
    _articleSubject.close();
  }
}
