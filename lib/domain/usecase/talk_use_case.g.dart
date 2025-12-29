// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TalkUseCase)
const talkUseCaseProvider = TalkUseCaseProvider._();

final class TalkUseCaseProvider
    extends $NotifierProvider<TalkUseCase, TalkUseCase> {
  const TalkUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'talkUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$talkUseCaseHash();

  @$internal
  @override
  TalkUseCase create() => TalkUseCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TalkUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TalkUseCase>(value),
    );
  }
}

String _$talkUseCaseHash() => r'cd9e3ee6082ed41927895528e3a8718c76f7689b';

abstract class _$TalkUseCase extends $Notifier<TalkUseCase> {
  TalkUseCase build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TalkUseCase, TalkUseCase>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TalkUseCase, TalkUseCase>, TalkUseCase, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
