import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../models/newsgroup.dart';
import 'message_list.dart';

class NewsgroupScreen extends StatelessWidget {
  final Newsgroup _newsgroup;

  NewsgroupScreen(this._newsgroup);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_newsgroup.shortname}',
          overflow: TextOverflow.fade,
        ),
      ),
      body: MessageList(_newsgroup),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Compose',
        onPressed: () {},
        child: Icon(MdiIcons.pencil),
      ),
    );
  }
}
