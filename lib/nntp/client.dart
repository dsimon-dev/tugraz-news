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
    final String response = await _nntp.newsgroups();
    return response.split('\r\n').map((String group) => Newsgroup.fromString(group)).toList();
  }

  /// Get a list of [Overview] objects for a newsgroup
  ///
  /// Optional [startAt] parameter to only get overviews starting at a specific [Overview.number]
  /// Returns an empty list on any [NntpException]
  Future<List<Overview>> overviews(Newsgroup newsgroup, [int startAt]) async {
    // Select the group and parse article numbers
    String response = await _nntp.group(newsgroup.name);
    List<int> values = response.split(' ').map((value) => int.tryParse(value) ?? 0).toList();
    int number = values[1], low = values[2], high = values[3];
    startAt ??= low;

    // No new articles
    if (number == 0 || low > high || startAt > high) {
      return [];
    }

    // Fetch new overviews
    try {
      response = await _nntp.over(startAt, high);
    } on NntpException catch (err) {
      print(err);
      return [];
    }
    return response.split('\r\n').map((res) {
      
      return Overview.fromResponse(newsgroup, res);
    }).toList();
  }

  /// Get an [Article] object for an overview, without fetching replies
  Future<Article> articleShallow(Overview overview) async {
    final String response = await _nntp.article(messageId: overview.messageId);
    return Article.fromResponse(overview, response);
  }

  /// Get an [Article] object for an overview with all replies
  Future<Article> articleDeep(Overview overview) async {
    final Article thisArticle = await articleShallow(overview);
    final Iterable<Future<Article>> replies =
        thisArticle.replies.map((artcl) => articleDeep(artcl));
    thisArticle.replies = await Future.wait(replies);
    return thisArticle;
  }

  Future<void> destroy() async {
    // TODO call this method somewhere (AppBloc?)
    await _nntp.destroy();
  }
}
