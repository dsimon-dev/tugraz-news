import 'package:flutter/foundation.dart';

import '../models/newsgroup.dart';
import '../models/overview.dart';
import '../models/article.dart';
import 'connector.dart';
import 'exceptions.dart';

class NntpClient {
  NntpConnector _nntp = NntpConnector();

  Future<String> connect(String host, int port) async {
    return await _nntp.connect(host, port);
  }

  /// Get a list of [Newsgroup] objects available on the server
  Future<List<Newsgroup>> newsgroups() async {
    String response = await _nntp.newsgroups();
    return response
      .split('\r\n')
      .map((String group) => Newsgroup.fromString(group))
      .toList();
  }

  /// Get a list of [Overview] objects for a newsgroup, grouped into threads
  Future<List<Overview>> overviews(Newsgroup group) async {
    // Select the group and parse article numbers
    String response = await _nntp.group(group.name);
    List<int> values = response.split(' ').map((value) => int.tryParse(value)).toList();
    int number = values[1],
        low = values[2],
        high = values[3];
    if (number == 0 || low > high) {
      return [];
    }
    // Fetch overviews
    response = await _nntp.over(low, high);
    // Map messageId to object for quick lookup
    Map<String, Overview> overviewsMap = Map();
    // Each overview is separated by a CRLF
    for (String resp in response.split('\r\n')) {
      Overview overview = Overview.fromResponse(group, resp);
      // Add to existing overview if it is a reply
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
      overviewsMap[overview.messageId] = overview;
    }
    // Filter out overviews that are not top level, sort by latest reply
    return overviewsMap.values.where((over) => over.references.isEmpty).toList()
      ..sort((a, b) => b.latestReplyDateTime().compareTo(a.latestReplyDateTime()));
  }

  /// Get an [Article] object for an overview, without fetching replies
  Future<Article> articleShallow(Overview overview) async {
    String response = await _nntp.article(messageId: overview.messageId);
    return Article.fromResponse(overview, response);
  }

  /// Get an [Article] object for an overview with all replies
  Future<Article> article(Overview overview) async {
    Article thisArticle = await articleShallow(overview);
    Iterable<Future<Article>> replies = thisArticle.replies.map((artcl) => article(artcl));
    thisArticle.replies = await Future.wait(replies);
    return thisArticle;
  }

  Future<void> destroy() async {
    // TODO call this method somewhere (AppBloc?)
    await _nntp.destroy();
  }
}
