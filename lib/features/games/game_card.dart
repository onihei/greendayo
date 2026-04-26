import 'package:flutter/material.dart';
import 'package:greendayo/features/games/game.dart';
import 'package:url_launcher/url_launcher_string.dart';

class GameCard extends StatelessWidget {
  const GameCard({super.key, required this.game});

  final Game game;

  Future<void> _open() => launchUrlString(
        game.url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: game.id,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: game.color.withValues(alpha: 0.15),
                child: Icon(game.icon, size: 36, color: game.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(game.title, style: theme.textTheme.titleLarge),
                    Text(
                      game.subtitle,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: game.color),
                    ),
                    const SizedBox(height: 8),
                    Text(game.description, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _open,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('遊ぶ'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
