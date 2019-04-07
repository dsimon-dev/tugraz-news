import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import '../models/newsgroup.dart';
import '../models/overview.dart';
import '../nntp/nntp.dart';
import '../storage/cache.dart';
import '../storage/database.dart'; // mark read
import 'bloc_provider.dart';

class OverviewBloc implements BlocBase {
  final Newsgroup _newsgroup;

  List<Overview> _overviewsFlat;
  List<Overview> _overviewsGrouped;
  final BehaviorSubject<List<Overview>> _overviewsSubject = BehaviorSubject<List<Overview>>();
  ValueObservable<List<Overview>> get overviews => _overviewsSubject.stream;

  OverviewBloc(this._newsgroup) {
    fetchOverviews();
  }

  Future<void> fetchOverviews() async {
    // Get cached overviews
    final cachedOverviews = await cache.getArticles(_newsgroup);

    // Get new overviews from nntp
    final int startAt = cachedOverviews.isEmpty ? 0 : cachedOverviews.last.number + 1;
    final newOverviews = await nntpClient.overviews(_newsgroup, startAt);

    print('Overviews for ${_newsgroup.name}: ${cachedOverviews.length} cached, ${newOverviews.length} new');

    // Add new ones to cache
    await cache.addOverviews(newOverviews);

    // Concat
    _overviewsFlat = cachedOverviews + newOverviews;

    // Identify read, group into threads, add to stream
    await refreshRead();
  }

  Future<void> refreshRead() async {
    await _identifyRead();
    _groupAndAdd();
  }

  void _groupAndAdd() {
    _overviewsFlat.forEach((over) => over.replies.clear());
    _overviewsGrouped = Overview.groupOverviews(_overviewsFlat);
    _overviewsSubject.sink.add(UnmodifiableListView(_overviewsGrouped));
  }

  Future<void> _identifyRead() async {
    final readArticles = await database.readArticles(_newsgroup);
    _overviewsFlat.forEach((over) => over.read = readArticles.contains(over.number));
  }

  @override
  void dispose() {
    _overviewsSubject.close();
  }
}
