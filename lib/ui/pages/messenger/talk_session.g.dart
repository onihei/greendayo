// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk_session.dart';

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

String _$_viewControllerHash() => r'aa578c7d19a3818225690b35a4c71933af0e2a7b';

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
