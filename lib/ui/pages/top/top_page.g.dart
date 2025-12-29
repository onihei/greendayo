// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_videoPlayerController)
const _videoPlayerControllerProvider = _VideoPlayerControllerProvider._();

final class _VideoPlayerControllerProvider extends $FunctionalProvider<
        AsyncValue<VideoPlayerController>,
        VideoPlayerController,
        FutureOr<VideoPlayerController>>
    with
        $FutureModifier<VideoPlayerController>,
        $FutureProvider<VideoPlayerController> {
  const _VideoPlayerControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'_videoPlayerControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_videoPlayerControllerHash();

  @$internal
  @override
  $FutureProviderElement<VideoPlayerController> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<VideoPlayerController> create(Ref ref) {
    return _videoPlayerController(ref);
  }
}

String _$_videoPlayerControllerHash() =>
    r'68fda810cc2fccf7f035c56af725748d7051cb00';

@ProviderFor(_ViewController)
const _viewControllerProvider = _ViewControllerProvider._();

final class _ViewControllerProvider
    extends $NotifierProvider<_ViewController, _ViewController> {
  const _ViewControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'_viewControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_viewControllerHash();

  @$internal
  @override
  _ViewController create() => _ViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(_ViewController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<_ViewController>(value),
    );
  }
}

String _$_viewControllerHash() => r'e3b6479c44c93e3a4a65fdc0ce9329b4c4f37014';

abstract class _$ViewController extends $Notifier<_ViewController> {
  _ViewController build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<_ViewController, _ViewController>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<_ViewController, _ViewController>,
        _ViewController,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
