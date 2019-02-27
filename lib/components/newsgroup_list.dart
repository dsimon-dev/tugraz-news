import 'package:flutter/material.dart';

import '../models/newsgroup.dart';

class NewsgroupList extends StatelessWidget {
  final List<Newsgroup> newsgroups;
  final Function(BuildContext context, Newsgroup newsgroup) onTap;
  final Function(BuildContext context, Newsgroup newsgroup) onLongPress;

  const NewsgroupList({
    Key key,
    @required this.newsgroups,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: newsgroups.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
            height: 0,
          ),
      itemBuilder: (BuildContext context, int index) {
        Newsgroup group = newsgroups[index];
        return ListTile(
          title: Text(group.name),
          subtitle: Text(group.description),
          onTap: onTap == null ? null : () => onTap(context, group),
          onLongPress: onLongPress == null ? null : () => onLongPress(context, group),
        );
      },
    );
  }
}
