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

  List<Overview> _overviews;
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
    for (final overview in newOverviews) {
      cache.addOverview(overview);
    }

    // Group into threads and sort
    _overviews = Overview.groupOverviews(cachedOverviews + newOverviews);
    _overviewsSubject.sink.add(UnmodifiableListView(_overviews));
  }



  @override
  void dispose() {
    _overviewsSubject.close();
  }
}
