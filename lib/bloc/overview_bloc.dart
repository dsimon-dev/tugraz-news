import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

import '../models/newsgroup.dart';
import '../models/overview.dart';
import '../nntp/nntp.dart';
import '../storage/cache.dart';
import '../storage/database.dart';
import 'bloc_provider.dart';

class OverviewBloc implements BlocBase {
  final Newsgroup newsgroup;

  List<Overview> _overviews;
  final BehaviorSubject<List<Overview>> _overviewsSubject = BehaviorSubject<List<Overview>>();
  ValueObservable<List<Overview>> get overviews => _overviewsSubject.stream;

  OverviewBloc(this.newsgroup) {
    fetchOverviews();
  }

  Future<void> fetchOverviews() async {
    // TODO:
    // 1. Get overviews from cache
    // 2. Get remaining overviews from nntp
    // 3. Group overviews into threads

    // nntp only for now
    
    _overviews = await nntpClient.overviews(newsgroup);
    _overviewsSubject.sink.add(UnmodifiableListView(_overviews));
  }

  @override
  void dispose() {
    _overviewsSubject.close();
  }
}
