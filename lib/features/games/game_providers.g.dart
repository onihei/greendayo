// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gameRepository)
final gameRepositoryProvider = GameRepositoryProvider._();

final class GameRepositoryProvider
    extends $FunctionalProvider<GameRepository, GameRepository, GameRepository>
    with $Provider<GameRepository> {
  GameRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gameRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gameRepositoryHash();

  @$internal
  @override
  $ProviderElement<GameRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GameRepository create(Ref ref) {
    return gameRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GameRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GameRepository>(value),
    );
  }
}

String _$gameRepositoryHash() => r'0d9fc37df97a3ac54f2776b7be257a58095cd7bd';

@ProviderFor(games)
final gamesProvider = GamesProvider._();

final class GamesProvider
    extends $FunctionalProvider<List<Game>, List<Game>, List<Game>>
    with $Provider<List<Game>> {
  GamesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gamesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gamesHash();

  @$internal
  @override
  $ProviderElement<List<Game>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Game> create(Ref ref) {
    return games(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Game> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Game>>(value),
    );
  }
}

String _$gamesHash() => r'd20c8bc2571460dcb33ac7bcc15871ba1984f6b6';
