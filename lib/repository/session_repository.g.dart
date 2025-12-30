// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionRepository)
final sessionRepositoryProvider = SessionRepositoryProvider._();

final class SessionRepositoryProvider
    extends $NotifierProvider<SessionRepository, SessionRepository> {
  SessionRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionRepositoryHash();

  @$internal
  @override
  SessionRepository create() => SessionRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionRepository>(value),
    );
  }
}

String _$sessionRepositoryHash() => r'8d57023d9484ce5514d135ffb88e31695a6ded4d';

abstract class _$SessionRepository extends $Notifier<SessionRepository> {
  SessionRepository build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SessionRepository, SessionRepository>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionRepository, SessionRepository>,
        SessionRepository,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
