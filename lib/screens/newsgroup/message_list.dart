import 'package:flutter/material.dart';

import '../../models/newsgroup.dart';
import '../../models/overview.dart';
import '../../nntp/nntp.dart';
import '../article/article_screen.dart';

class MessageList extends StatefulWidget {
  final Newsgroup group;

  const MessageList({Key key, @required this.group}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  List<Overview> _overviews;

  @override
  void initState() {
    _fetchOverviews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_overviews == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_overviews.isEmpty) {
      return Center(
        child: Text('No articles'),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchOverviews,
      child: _overviewList()
    );
  }

  Widget _overviewList() {
    return ListView.separated(
      itemCount: _overviews.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
          ),
      itemBuilder: (BuildContext context, int index) {
        Overview over = _overviews[index];
        int totalReplies = over.flatten().length - 1;
        return ListTile(
          title: Hero(
            tag: over.messageId,
            child: Material(
              textStyle: Theme.of(context).textTheme.subhead,
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
          onLongPress: () {},
        );
      },
    );
  }

  Future<void> _fetchOverviews() async {
    List<Overview> overs = await nntpClient.overviews(widget.group);
    if (mounted) {
      setState(() {
        _overviews = overs;
      });
    }
  }
}
