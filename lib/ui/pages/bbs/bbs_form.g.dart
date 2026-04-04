// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bbs_form.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BbsForm)
final bbsFormProvider = BbsFormProvider._();

final class BbsFormProvider extends $NotifierProvider<BbsForm, BbsFormState> {
  BbsFormProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bbsFormProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bbsFormHash();

  @$internal
  @override
  BbsForm create() => BbsForm();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BbsFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BbsFormState>(value),
    );
  }
}

String _$bbsFormHash() => r'56bb138c24213fe483ff4038c6e22273bd6d1d34';

abstract class _$BbsForm extends $Notifier<BbsFormState> {
  BbsFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BbsFormState, BbsFormState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BbsFormState, BbsFormState>,
        BbsFormState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BbsFormEnabled)
final bbsFormEnabledProvider = BbsFormEnabledProvider._();

final class BbsFormEnabledProvider
    extends $NotifierProvider<BbsFormEnabled, bool> {
  BbsFormEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bbsFormEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bbsFormEnabledHash();

  @$internal
  @override
  BbsFormEnabled create() => BbsFormEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$bbsFormEnabledHash() => r'041a9a1106be5d5d3d5aedb49df4696b4f145c3b';

abstract class _$BbsFormEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BbsScale)
final bbsScaleProvider = BbsScaleProvider._();

final class BbsScaleProvider extends $NotifierProvider<BbsScale, double> {
  BbsScaleProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bbsScaleProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bbsScaleHash();

  @$internal
  @override
  BbsScale create() => BbsScale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$bbsScaleHash() => r'905bf72214e6c21d39e9bace7f2105ce027a7fe7';

abstract class _$BbsScale extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<double, double>, double, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BbsOffset)
final bbsOffsetProvider = BbsOffsetProvider._();

final class BbsOffsetProvider extends $NotifierProvider<BbsOffset, Offset> {
  BbsOffsetProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bbsOffsetProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bbsOffsetHash();

  @$internal
  @override
  BbsOffset create() => BbsOffset();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Offset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Offset>(value),
    );
  }
}

String _$bbsOffsetHash() => r'04094999c48320e083c15569921c262f3fa3fe81';

abstract class _$BbsOffset extends $Notifier<Offset> {
  Offset build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Offset, Offset>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Offset, Offset>, Offset, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
