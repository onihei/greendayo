import 'package:flutter/material.dart';
import 'package:fx_widget/main.dart';
import 'package:greendayo/tab_config.dart';

class GamesTabConfig implements TabConfig {
  @override
  String get label => 'ゲーム';

  @override
  Widget get icon => const Icon(Icons.games_outlined);

  @override
  Widget get activeIcon => const Icon(Icons.games);

  @override
  Function get factoryMethod => GamesPage.new;

  @override
  Widget? get floatingActionButton => null;
}

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 400),
        child: const FxGame(
          userId: "xxx",
        ),
      ),
    );
  }
}
