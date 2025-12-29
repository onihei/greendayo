// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocking_overlay.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Blocking)
const blockingProvider = BlockingProvider._();

final class BlockingProvider extends $NotifierProvider<Blocking, bool> {
  const BlockingProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'blockingProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$blockingHash();

  @$internal
  @override
  Blocking create() => Blocking();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$blockingHash() => r'89d414930d0a3de871ebf26510bd463d5488344b';

abstract class _$Blocking extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
