// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bbs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BbsController)
final bbsControllerProvider = BbsControllerProvider._();

final class BbsControllerProvider
    extends $NotifierProvider<BbsController, BbsController> {
  BbsControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'bbsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$bbsControllerHash();

  @$internal
  @override
  BbsController create() => BbsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BbsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BbsController>(value),
    );
  }
}

String _$bbsControllerHash() => r'a50633a65c32e876a17c1630233918b6fe671252';

abstract class _$BbsController extends $Notifier<BbsController> {
  BbsController build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BbsController, BbsController>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<BbsController, BbsController>,
        BbsController,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
