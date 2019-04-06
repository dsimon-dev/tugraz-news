import 'package:flutter/material.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/overview_bloc.dart';
import '../../models/newsgroup.dart';
import '../../models/overview.dart';
import '../article/article_screen.dart';

class MessageList extends StatelessWidget {
  final Newsgroup newsgroup;

  MessageList(this.newsgroup);

  @override
  Widget build(BuildContext context) {
    final OverviewBloc bloc = OverviewBloc(newsgroup);
    return BlocProvider<OverviewBloc>(
      bloc: bloc,
      child: StreamBuilder(
        stream: bloc.overviews,
        builder: (BuildContext context, AsyncSnapshot<List<Overview>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: bloc.fetchOverviews,
            child: _overviewList(snapshot.data),
          );
        },
      ),
    );
  }

  Widget _overviewList(List<Overview> overviews) {
    if (overviews.isEmpty) {
      return Center(
        child: const Text('No articles'),
      );
    }
    return ListView.separated(
      itemCount: overviews.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
          ),
      itemBuilder: (BuildContext context, int index) {
        Overview over = overviews[index];
        List<Overview> overviewsFlat = over.flatten();
        int totalReplies = overviewsFlat.length - 1;
        bool unread = overviewsFlat.any((over) => !over.read);
        TextStyle textStyle = Theme.of(context).textTheme.subhead;
        return ListTile(
          title: Hero(
            tag: over.messageId,
            child: Material(
              textStyle: unread ? textStyle.copyWith(fontWeight: FontWeight.w600) : textStyle,
              color: Colors.transparent,
              child: Text(
                over.subject,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          subtitle: Text(
            over.authorAndDateTime,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: totalReplies > 0 ? Text('+$totalReplies') : null,
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ArticleScreen(over),
                ));
          },
        );
      },
    );
  }
}
