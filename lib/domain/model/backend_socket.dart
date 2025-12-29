import 'package:greendayo/domain/model/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'backend_socket.g.dart';

@riverpod
Socket backendSocket(ref) {
  // final uri = Platform.isAndroid ? "http://10.0.2.2:10005": "http://localhost:10005";
  final uri = "https://susipero.com";
  //  final uri = "http://localhost:10005";
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
