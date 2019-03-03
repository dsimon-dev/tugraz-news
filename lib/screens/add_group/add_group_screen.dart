import 'package:flutter/material.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/newsgroup_bloc.dart';
import '../../components/newsgroup_list.dart';
import '../../models/newsgroup.dart';
import 'search_field.dart';

class AddGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<NewsgroupBloc>(context);
    return StreamBuilder(
      stream: bloc.availableNewsgroups,
      builder: (BuildContext context, AsyncSnapshot<List<Newsgroup>> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: SearchField(),
            ),
            body: snapshot.data.isEmpty
                ? Center(
                    child: const Text('No matching newsgroups'),
                  )
                : NewsgroupList(
                    newsgroups: snapshot.data,
                    onTap: (BuildContext context, Newsgroup newsgroup) =>
                        _addNewsgroup(context, newsgroup),
                  ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<void> _addNewsgroup(BuildContext context, Newsgroup newsgroup) async {
    final NewsgroupBloc bloc = BlocProvider.of<NewsgroupBloc>(context);
    if (await bloc.addNewsgroup(newsgroup)) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('${newsgroup.name} added'),
      ));
    }
  }
}
