import 'package:flutter/material.dart';
import 'package:greendayo/tab_config.dart';

class GamesTabConfig implements TabConfig {
  @override
  String get label => 'ゲーム';

  @override
  Widget get icon => Icon(Icons.games_outlined);

  @override
  Widget get activeIcon => Icon(Icons.games);

  @override
  Function get factoryMethod => GamesPage.new;

  @override
  Widget? get floatingActionButton => null;
}

class GamesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('games'),
    );
  }
}
