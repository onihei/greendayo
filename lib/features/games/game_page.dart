import 'package:flutter/material.dart';
import 'package:greendayo/app/navigation_item_widget.dart';
import 'package:greendayo/features/games/game_card.dart';
import 'package:greendayo/features/games/game_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GamePage extends HookConsumerWidget implements NavigationItemWidget {
  const GamePage({super.key});

  @override
  String get title => 'ゲーム';

  @override
  Widget? get floatingActionButton => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesProvider);
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, i) => GameCard(game: games[i]),
    );
  }
}
