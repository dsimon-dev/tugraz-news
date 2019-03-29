import 'package:flutter/material.dart';

import '../models/newsgroup.dart';

class NewsgroupList extends StatelessWidget {
  final List<Newsgroup> newsgroups;
  final void Function(BuildContext, Newsgroup) onTap;
  final void Function(BuildContext, Newsgroup) onLongPress;
  final bool truncate;

  const NewsgroupList({
    Key key,
    @required this.newsgroups,
    this.truncate = false,
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
          title:
              Text(group.name, overflow: truncate ? TextOverflow.fade : null, softWrap: !truncate),
          subtitle: Text(group.description,
              overflow: truncate ? TextOverflow.fade : null, softWrap: !truncate),
          onTap: onTap == null ? null : () => onTap(context, group),
          onLongPress: onLongPress == null ? null : () => onLongPress(context, group),
        );
      },
    );
  }
}
