// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messenger_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_SelectedSessionId)
final _selectedSessionIdProvider = _SelectedSessionIdProvider._();

final class _SelectedSessionIdProvider
    extends $NotifierProvider<_SelectedSessionId, String?> {
  _SelectedSessionIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'_selectedSessionIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_selectedSessionIdHash();

  @$internal
  @override
  _SelectedSessionId create() => _SelectedSessionId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$_selectedSessionIdHash() =>
    r'6340d9197a9f5323737fe83631783e37d97c36b1';

abstract class _$SelectedSessionId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String?, String?>, String?, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(_selectedSessionTitle)
final _selectedSessionTitleProvider = _SelectedSessionTitleProvider._();

final class _SelectedSessionTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  _SelectedSessionTitleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'_selectedSessionTitleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_selectedSessionTitleHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return _selectedSessionTitle(ref);
  }
}

String _$_selectedSessionTitleHash() =>
    r'7f5923dcff832d5a75400062af8fa104f1f94ecd';

@ProviderFor(_sessionTitle)
final _sessionTitleProvider = _SessionTitleFamily._();

final class _SessionTitleProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  _SessionTitleProvider._(
      {required _SessionTitleFamily super.from,
      required Session super.argument})
      : super(
          retry: null,
          name: r'_sessionTitleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_sessionTitleHash();

  @override
  String toString() {
    return r'_sessionTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as Session;
    return _sessionTitle(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is _SessionTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_sessionTitleHash() => r'b9080443efb67f922ab99cb30a16f45bacc8645e';

final class _SessionTitleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, Session> {
  _SessionTitleFamily._()
      : super(
          retry: null,
          name: r'_sessionTitleProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  _SessionTitleProvider call(
    Session session,
  ) =>
      _SessionTitleProvider._(argument: session, from: this);

  @override
  String toString() => r'_sessionTitleProvider';
}

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

String _$_viewControllerHash() => r'a2e45bdac88088950f60a65805e328d5212d6c7c';

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
