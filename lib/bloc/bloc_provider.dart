// thanks https://www.didierboelens.com/2018/08/reactive-programming---streams---bloc/

import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
}

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  final T bloc;
  final Widget child;

  BlocProvider({
    Key key,
    @required this.bloc,
    @required this.child,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    final Type type = _typeOf<BlocProvider<T>>();
    return (context.ancestorWidgetOfExactType(type) as BlocProvider<T>).bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  void dispose() { 
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
