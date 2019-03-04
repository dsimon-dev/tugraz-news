import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../models/newsgroup.dart';
import 'message_list.dart';

class NewsgroupScreen extends StatelessWidget {
  final Newsgroup _group;

  NewsgroupScreen(Newsgroup group) : _group = group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_group.shortname}',
          overflow: TextOverflow.fade,
        ),
      ),
      body: MessageList(group: _group),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Compose',
        onPressed: () {},
        child: Icon(MdiIcons.pencil),
      ),
    );
  }
}
