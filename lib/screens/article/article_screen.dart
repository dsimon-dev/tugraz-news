import 'package:flutter/material.dart';

import '../../bloc/article_bloc.dart';
import '../../bloc/bloc_provider.dart';
import '../../models/article.dart';
import '../../models/overview.dart';
import '../../storage/database.dart';
import 'article_body.dart';

class ArticleScreen extends StatelessWidget {
  final Overview _overview;

  ArticleScreen(this._overview);

  @override
  Widget build(BuildContext context) {
    final ArticleBloc bloc = ArticleBloc(_overview);
    final TextTheme textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(''),
        ),
        body: StreamBuilder<Article>(
          stream: bloc.article,
          builder: (BuildContext context, AsyncSnapshot<Article> snapshot) {
            final articles = snapshot.data?.flatten<Article>(); // Can be null
            return ListView.separated(
              padding: EdgeInsets.all(10),
              itemCount: (articles?.length ?? 1) + 1,
              separatorBuilder: (_, __) => Divider(height: 30.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  // Header
                  return Hero(
                    tag: _overview.messageId,
                    child: Material(
                      textStyle:
                          textTheme.title.copyWith(fontWeight: FontWeight.normal, height: 1.25),
                      color: Colors.transparent,
                      child: Text(_overview.subject),
                    ),
                  );
                }
                if (articles == null) {
                  return Center(
                    heightFactor: 10.0,
                    child: CircularProgressIndicator(),
                  );
                }
                index -= 1;
                final article = articles[index];
                if (!article.read) {
                  database.markArticleRead(article);
                }
                print(article.read);
                return Padding(
                  padding: EdgeInsets.only(left: article.depth * 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          article.authorAndDateTime,
                          style: textTheme.caption.copyWith(fontStyle: FontStyle.italic, fontWeight: article.read ? null : FontWeight.w600),
                        ),
                      ),
                      ArticleBody(article.body),
                    ],
                  ),
                );
              },
            );
          }
        ),
      ),
    );
  }
}
