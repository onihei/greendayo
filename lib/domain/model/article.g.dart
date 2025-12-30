// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

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

String _$articlesStreamHash() => r'7bd881b3d18a232a374cea153088a02fc9240617';
