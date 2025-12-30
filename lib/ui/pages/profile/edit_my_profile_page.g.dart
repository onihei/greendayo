// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_my_profile_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_ViewController)
final _viewControllerProvider = _ViewControllerProvider._();

final class _ViewControllerProvider
    extends $NotifierProvider<_ViewController, _ViewController> {
  _ViewControllerProvider._()
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

String _$_viewControllerHash() => r'd709d0759c1c7f171ba6a62fa264bfe9547f27c0';

abstract class _$ViewController extends $Notifier<_ViewController> {
  _ViewController build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<_ViewController, _ViewController>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<_ViewController, _ViewController>,
        _ViewController,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
