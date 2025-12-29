// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TalkRepository)
const talkRepositoryProvider = TalkRepositoryFamily._();

final class TalkRepositoryProvider
    extends $NotifierProvider<TalkRepository, SessionTalkRepository> {
  const TalkRepositoryProvider._(
      {required TalkRepositoryFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'talkRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$talkRepositoryHash();

  @override
  String toString() {
    return r'talkRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TalkRepository create() => TalkRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionTalkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionTalkRepository>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TalkRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$talkRepositoryHash() => r'6a9612120a1360e07acda18e944968195750e91f';

final class TalkRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<TalkRepository, SessionTalkRepository,
            SessionTalkRepository, SessionTalkRepository, String> {
  const TalkRepositoryFamily._()
      : super(
          retry: null,
          name: r'talkRepositoryProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TalkRepositoryProvider call(
    String sessionId,
  ) =>
      TalkRepositoryProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'talkRepositoryProvider';
}

abstract class _$TalkRepository extends $Notifier<SessionTalkRepository> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  SessionTalkRepository build(
    String sessionId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<SessionTalkRepository, SessionTalkRepository>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionTalkRepository, SessionTalkRepository>,
        SessionTalkRepository,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
