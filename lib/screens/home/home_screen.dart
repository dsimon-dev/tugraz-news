import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/newsgroup_bloc.dart';
import '../add_group/add_group_screen.dart';
import 'added_newsgroups.dart';
import 'popup_menu.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NewsgroupBloc bloc = BlocProvider.of<NewsgroupBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('TU Graz News'),
        actions: <Widget>[
          PopupMenu(),
        ],
      ),
      body: AddedNewsgroups(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add newsgroup',
        onPressed: () async {
          bloc.fetchNewsgroups();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGroupScreen()),
          );
          bloc.refreshNewsgroups();
        },
        child: Icon(MdiIcons.plus),
      ),
    );
  }
}
