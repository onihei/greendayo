// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArticleRepository)
const articleRepositoryProvider = ArticleRepositoryProvider._();

final class ArticleRepositoryProvider
    extends $NotifierProvider<ArticleRepository, ArticleRepository> {
  const ArticleRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'articleRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$articleRepositoryHash();

  @$internal
  @override
  ArticleRepository create() => ArticleRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArticleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArticleRepository>(value),
    );
  }
}

String _$articleRepositoryHash() => r'510402d2f57f2c557ae332422e67020822563558';

abstract class _$ArticleRepository extends $Notifier<ArticleRepository> {
  ArticleRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ArticleRepository, ArticleRepository>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ArticleRepository, ArticleRepository>,
        ArticleRepository,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
