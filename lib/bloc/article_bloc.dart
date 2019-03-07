import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import '../models/article.dart';
import '../models/newsgroup.dart';
import '../models/overview.dart';
import '../nntp/nntp.dart';
import '../storage/cache.dart';
import '../storage/database.dart'; // mark read
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
    _article = await nntpClient.article(_overview);
    _articleSubject.sink.add(_article);
  }

  @override
  void dispose() {
    _articleSubject.close();
  }
}
