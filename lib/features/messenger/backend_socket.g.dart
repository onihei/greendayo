// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_socket.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backendSocket)
final backendSocketProvider = BackendSocketProvider._();

final class BackendSocketProvider
    extends $FunctionalProvider<Socket, Socket, Socket> with $Provider<Socket> {
  BackendSocketProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'backendSocketProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$backendSocketHash();

  @$internal
  @override
  $ProviderElement<Socket> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Socket create(Ref ref) {
    return backendSocket(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Socket value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Socket>(value),
    );
  }
}

String _$backendSocketHash() => r'09eac11085b988a9a7c3214aef61168b44a92088';
