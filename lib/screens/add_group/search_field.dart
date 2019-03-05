import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../bloc/bloc_provider.dart';
import '../../bloc/newsgroup_bloc.dart';

class SearchField extends StatefulWidget {
  @override
  _SearchFieldState createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> with SingleTickerProviderStateMixin {
  final TextEditingController _searchTextController = TextEditingController();
  AnimationController _clearButtonController;
  Animation<double> _clearButtonAnimation;

  @override
  void initState() {
    super.initState();
    _clearButtonController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    double iconSize = IconThemeData.fallback().size;
    _clearButtonAnimation = Tween(begin: 0.0, end: iconSize).animate(_clearButtonController);
    _searchTextController.addListener(_filterNewsgroups);
  }

  @override
  void dispose() {
    _clearButtonController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle =
        Theme.of(context).primaryTextTheme.title.copyWith(fontWeight: FontWeight.w400);
    return TextField(
      controller: _searchTextController,
      autofocus: true,
      style: textStyle,
      cursorColor: textStyle.color,
      decoration: InputDecoration(
        hintStyle: textStyle.copyWith(color: textStyle.color.withOpacity(0.6)),
        hintText: 'Search...',
        border: InputBorder.none,
        suffixIcon: _AnimatedClearButton(
          animation: _clearButtonAnimation,
          textController: _searchTextController,
        ),
      ),
    );
  }

  void _filterNewsgroups() {
    final String text = _searchTextController.text.toLowerCase();
    final AnimationStatus status = _clearButtonController.status;
    // Show/hide clear button
    if (text.isNotEmpty && [AnimationStatus.dismissed, AnimationStatus.reverse].contains(status)) {
      _clearButtonController.forward();
    } else if (text.isEmpty &&
        [AnimationStatus.completed, AnimationStatus.forward].contains(status)) {
      _clearButtonController.reverse();
    }
    // Filter groups
    final NewsgroupBloc bloc = BlocProvider.of<NewsgroupBloc>(context);
    bloc.filterNewsgroups(text);
  }
}

class _AnimatedClearButton extends AnimatedWidget {
  final TextEditingController _textController;

  _AnimatedClearButton({
    Key key,
    @required Animation<double> animation,
    @required TextEditingController textController,
  })  : _textController = textController,
        super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    if (animation.value == 0) {
      return Icon(
        MdiIcons.close,
        size: 0,
      );
    }
    final IconThemeData theme = Theme.of(context).primaryIconTheme;
    return IconButton(
      padding: EdgeInsets.all(0),
      tooltip: 'Clear',
      color: theme.color,
      icon: Icon(
        MdiIcons.close,
        size: animation.value,
      ),
      onPressed: () => _textController.clear(), // InputConnection warning, see flutter #11321
    );
  }
}
