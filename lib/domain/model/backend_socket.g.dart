// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend_socket.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(backendSocket)
const backendSocketProvider = BackendSocketProvider._();

final class BackendSocketProvider
    extends $FunctionalProvider<Socket, Socket, Socket> with $Provider<Socket> {
  const BackendSocketProvider._()
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

String _$backendSocketHash() => r'fe3def2249f4999f51ac4832f08bf4f33d71fb67';
