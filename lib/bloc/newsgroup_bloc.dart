import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';

import '../models/newsgroup.dart';
import '../nntp/nntp.dart';
import '../storage/database.dart';

import 'bloc_provider.dart';

class NewsgroupBloc implements BlocBase {
  // Added newsgroups, from database
  List<Newsgroup> _addedNewsgroups;
  final BehaviorSubject<List<Newsgroup>> _addedSubject = BehaviorSubject<List<Newsgroup>>();
  ValueObservable<List<Newsgroup>> get addedNewsgroups => _addedSubject.stream;

  // All available newsgroups, from nntp
  List<Newsgroup> _availableNewsgroups;
  final BehaviorSubject<List<Newsgroup>> _availableSubject = BehaviorSubject<List<Newsgroup>>();
  ValueObservable<List<Newsgroup>> get availableNewsgroups => _availableSubject.stream;

  NewsgroupBloc() {
    refreshNewsgroups();
  }

  Future<void> refreshNewsgroups() async {
    final List<Newsgroup> groups = await database.getNewsgroups();
    _addedNewsgroups = groups;
    _addedSubject.sink.add(UnmodifiableListView<Newsgroup>(_addedNewsgroups));
  }

  Future<bool> addNewsgroup(Newsgroup group) async {
    try {
      await database.addNewsgroup(group);
    } on DatabaseException {
      return false;
    }
    await refreshNewsgroups();
    _availableNewsgroups.remove(group);
    _availableSubject.sink.add(UnmodifiableListView<Newsgroup>(_availableNewsgroups));
    return true;
  }

  Future<void> removeNewsgroup(Newsgroup group) async {
    await database.removeNewsgroup(group);
    await refreshNewsgroups();
  }

  Future<void> fetchNewsgroups() async {
    final List<Newsgroup> groups = await nntpClient.newsgroups();
    _availableNewsgroups = groups.where((group) => !_addedNewsgroups.contains(group)).toList();
    _availableSubject.sink.add(UnmodifiableListView<Newsgroup>(_availableNewsgroups));
  }

  void filterNewsgroups(String text) {
    _availableSubject.sink.add(UnmodifiableListView<Newsgroup>(_availableNewsgroups.where((group) =>
        group.name.toLowerCase().contains(text) ||
        (group.description?.toLowerCase()?.contains(text) ?? false))));
  }

  @override
  void dispose() {
    _addedSubject.close();
    _availableSubject.close();
  }
}
