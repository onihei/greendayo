import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'backend_socket.g.dart';

@riverpod
Socket backendSocket(Ref ref) {
  final uri = "https://susipero.com";
  final userId = ref.watch(myProfileProvider).requireValue.userId;
  final socket = io(
    uri,
    OptionBuilder()
        .setQuery({'userId': userId})
        .setTransports(['websocket'])
        .setPath("/greendayo.io/")
        .disableAutoConnect()
        .build(),
  );
  socket.connect();
  ref.onDispose(() {
    socket.dispose();
  });
  return socket;
}
