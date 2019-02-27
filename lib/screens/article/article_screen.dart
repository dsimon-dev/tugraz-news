import 'package:flutter/material.dart';

import '../../models/overview.dart';
import '../../models/article.dart';
import '../../nntp/nntp.dart';
import 'article_body.dart';

class ArticleScreen extends StatefulWidget {
  final Overview overview;

  ArticleScreen(this.overview);

  @override
  ArticleScreenState createState() => ArticleScreenState();
}

class ArticleScreenState extends State<ArticleScreen> {
  List<Article> _articles;

  @override
  void initState() {
    super.initState();
    _fetchArticle();
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(10),
        itemCount: (_articles?.length ?? 1) + 1,
        separatorBuilder: (BuildContext context, int index) => Divider(
              height: 30.0,
            ),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // Header
            return Hero(
              tag: widget.overview.messageId,
              child: Material(
                textStyle:
                    textTheme.title.copyWith(fontWeight: FontWeight.normal, height: 1.25),
                color: Colors.transparent,
                child: Text(widget.overview.subject),
              ),
            );
          }
          if (_articles == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(),
              )
            );
          }
          index -= 1;
          Article article = _articles[index];
          return Padding(
            padding: EdgeInsets.only(left: article.depth * 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    article.authorAndDateTime,
                    style: textTheme.caption.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
                ArticleBody(article.body),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchArticle() async {
    Article article = await nntpClient.article(widget.overview);
    if (mounted) {
      setState(() {
        _articles = article.flatten<Article>();
      });
    }
  }
}
