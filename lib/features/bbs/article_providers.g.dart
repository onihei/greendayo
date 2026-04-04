// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(articlesStream)
final articlesStreamProvider = ArticlesStreamProvider._();

final class ArticlesStreamProvider extends $FunctionalProvider<
        AsyncValue<QuerySnapshot<Article>>,
        QuerySnapshot<Article>,
        Stream<QuerySnapshot<Article>>>
    with
        $FutureModifier<QuerySnapshot<Article>>,
        $StreamProvider<QuerySnapshot<Article>> {
  ArticlesStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'articlesStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$articlesStreamHash();

  @$internal
  @override
  $StreamProviderElement<QuerySnapshot<Article>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<QuerySnapshot<Article>> create(Ref ref) {
    return articlesStream(ref);
  }
}

String _$articlesStreamHash() => r'3eb2aa45e51e43eb245607d5dec94625a7f8ae98';
