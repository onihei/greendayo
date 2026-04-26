import 'package:greendayo/features/games/game.dart';
import 'package:greendayo/features/games/game_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'game_providers.g.dart';

@riverpod
GameRepository gameRepository(Ref ref) => GameRepository();

@riverpod
List<Game> games(Ref ref) => ref.watch(gameRepositoryProvider).getAll();
