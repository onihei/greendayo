// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionsStream)
final sessionsStreamProvider = SessionsStreamProvider._();

final class SessionsStreamProvider extends $FunctionalProvider<
        AsyncValue<QuerySnapshot<Session>>,
        QuerySnapshot<Session>,
        Stream<QuerySnapshot<Session>>>
    with
        $FutureModifier<QuerySnapshot<Session>>,
        $StreamProvider<QuerySnapshot<Session>> {
  SessionsStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionsStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionsStreamHash();

  @$internal
  @override
  $StreamProviderElement<QuerySnapshot<Session>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<QuerySnapshot<Session>> create(Ref ref) {
    return sessionsStream(ref);
  }
}

String _$sessionsStreamHash() => r'224542a948e000c536e123d4128843a9a02c5289';

@ProviderFor(session)
final sessionProvider = SessionFamily._();

final class SessionProvider
    extends $FunctionalProvider<AsyncValue<Session>, Session, FutureOr<Session>>
    with $FutureModifier<Session>, $FutureProvider<Session> {
  SessionProvider._(
      {required SessionFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'sessionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionHash();

  @override
  String toString() {
    return r'sessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Session> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Session> create(Ref ref) {
    final argument = this.argument as String;
    return session(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionHash() => r'0f56aa3af41e246b9808407c35c425059178f3ed';

final class SessionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Session>, String> {
  SessionFamily._()
      : super(
          retry: null,
          name: r'sessionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  SessionProvider call(
    String sessionId,
  ) =>
      SessionProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionProvider';
}
