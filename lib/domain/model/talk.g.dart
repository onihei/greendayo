// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talk.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(talksStream)
final talksStreamProvider = TalksStreamFamily._();

final class TalksStreamProvider extends $FunctionalProvider<
        AsyncValue<QuerySnapshot<Talk>>,
        QuerySnapshot<Talk>,
        Stream<QuerySnapshot<Talk>>>
    with
        $FutureModifier<QuerySnapshot<Talk>>,
        $StreamProvider<QuerySnapshot<Talk>> {
  TalksStreamProvider._(
      {required TalksStreamFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'talksStreamProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$talksStreamHash();

  @override
  String toString() {
    return r'talksStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<QuerySnapshot<Talk>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<QuerySnapshot<Talk>> create(Ref ref) {
    final argument = this.argument as String;
    return talksStream(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TalksStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$talksStreamHash() => r'7d65d801f40c7cd99efe0225e68360716381fe62';

final class TalksStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<QuerySnapshot<Talk>>, String> {
  TalksStreamFamily._()
      : super(
          retry: null,
          name: r'talksStreamProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  TalksStreamProvider call(
    String sessionId,
  ) =>
      TalksStreamProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'talksStreamProvider';
}
