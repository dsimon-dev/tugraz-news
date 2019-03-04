import 'package:flutter/material.dart';

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
      onLongPress: (BuildContext context, Newsgroup group) => _removeNewsgroup(context, group),
    );
  }

  Future<void> _removeNewsgroup(BuildContext context, Newsgroup group) async {
    final NewsgroupBloc bloc = BlocProvider.of<NewsgroupBloc>(context);
    await bloc.removeNewsgroup(group);
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('${group.name} removed'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => bloc.undoRemoveNewsgroup(group),
      ),
    ));
  }
}
