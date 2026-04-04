// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(talkRepository)
final talkRepositoryProvider = TalkRepositoryProvider._();

final class TalkRepositoryProvider
    extends $FunctionalProvider<TalkRepository, TalkRepository, TalkRepository>
    with $Provider<TalkRepository> {
  TalkRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'talkRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$talkRepositoryHash();

  @$internal
  @override
  $ProviderElement<TalkRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TalkRepository create(Ref ref) {
    return talkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TalkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TalkRepository>(value),
    );
  }
}

String _$talkRepositoryHash() => r'a6ce8357c11e2c4898512cc737d95187bfb6de6c';
