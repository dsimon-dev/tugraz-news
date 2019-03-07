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
    _overviews = _groupOverviews(cachedOverviews + newOverviews);
    _overviewsSubject.sink.add(UnmodifiableListView(_overviews));
  }

  /// Get a list of [Overview] objects, grouped into threads with .replies property
  static List<Overview> _groupOverviews(List<Overview> overviews) {
    // Map messageId to Overview object for quick lookup
    final Map<String, Overview> overviewsMap =
        Map.fromIterable(overviews, key: (over) => over.messageId, value: (over) => over);

    // Identify replies and add to parent
    for (final overview in overviews) {
      // Add to existing overview if it is a reply (= has references)
      if (overview.references.isNotEmpty) {
        Overview refOverview = overviewsMap[overview.references.last];
        if (refOverview != null) {
          refOverview.replies.add(overview);
          overview.depth = refOverview.depth + 1;
        } else {
          // Reference not found, set to top level
          overview.references = [];
        }
      }
    }

    // Filter out overviews that are not top level, sort by latest reply
    return overviewsMap.values.where((over) => over.references.isEmpty).toList()
      ..sort((a, b) => b.latestReplyDateTime.compareTo(a.latestReplyDateTime));
  }

  @override
  void dispose() {
    _overviewsSubject.close();
  }
}
