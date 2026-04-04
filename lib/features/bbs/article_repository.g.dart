// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(articleRepository)
final articleRepositoryProvider = ArticleRepositoryProvider._();

final class ArticleRepositoryProvider extends $FunctionalProvider<
    ArticleRepository,
    ArticleRepository,
    ArticleRepository> with $Provider<ArticleRepository> {
  ArticleRepositoryProvider._()
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
  $ProviderElement<ArticleRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ArticleRepository create(Ref ref) {
    return articleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ArticleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ArticleRepository>(value),
    );
  }
}

String _$articleRepositoryHash() => r'3f2a6a2e2347e8b5dcb2cd9d5afefeeba9c34aa6';
