// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TalkUseCase)
final talkUseCaseProvider = TalkUseCaseProvider._();

final class TalkUseCaseProvider
    extends $NotifierProvider<TalkUseCase, TalkUseCase> {
  TalkUseCaseProvider._()
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

String _$talkUseCaseHash() => r'80aca801774b504fbc7c624786942b4f7167abfe';

abstract class _$TalkUseCase extends $Notifier<TalkUseCase> {
  TalkUseCase build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TalkUseCase, TalkUseCase>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TalkUseCase, TalkUseCase>, TalkUseCase, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
