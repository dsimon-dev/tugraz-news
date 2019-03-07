import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/newsgroup_bloc.dart';
import '../../components/newsgroup_list.dart';
import '../../models/newsgroup.dart';
import '../newsgroup/newsgroup_screen.dart';

class AddedNewsgroups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final NewsgroupBloc bloc = BlocProvider.of<NewsgroupBloc>(context);
    return StreamBuilder(
      stream: bloc.addedNewsgroups,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return _buildNewsgroupList(snapshot.data);
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildNewsgroupList(List<Newsgroup> groups) {
    if (groups.isEmpty) {
      return Center(
        child: const Text('No newsgroups added yet'),
      );
    }
    return NewsgroupList(
      newsgroups: groups,
      onTap: (BuildContext context, Newsgroup group) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => NewsgroupScreen(group)),
        );
      },
      onLongPress: (BuildContext context, Newsgroup group) => _showBottomMenu(context, group),
    );
  }

  void _showBottomMenu(BuildContext context, Newsgroup group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        final bloc = BlocProvider.of<NewsgroupBloc>(context);
        final theme = Theme.of(context);
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(group.name, style: theme.textTheme.subtitle.copyWith(color: theme.accentColor)),
            ),
            ListTile(
              leading: Icon(MdiIcons.emailOutline),
              title: const Text('Mark newsgroup as read'),
              onTap: () {
                // TODO
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(MdiIcons.deleteOutline),
              title: const Text('Remove newsgroup'),
              onTap: () {
                bloc.removeNewsgroup(group);
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }
}
