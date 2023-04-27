import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greendayo/entity/article.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/repository/article_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

final socketProvider = Provider.autoDispose<Socket>((ref) {
  // final uri = Platform.isAndroid ? "http://10.0.2.2:10005": "http://localhost:10005";
  final uri = "https://susipero.com";
//  final uri = "http://localhost:10005";
  final userId = ref.watch(myProfileProvider.select((value) => value.userId));
  final socket = io(
      uri,
      OptionBuilder()
          .setQuery({'userId': userId})
          .setTransports(['websocket'])
          .setPath("/greendayo.io/")
          .disableAutoConnect()
          .build());
  socket.connect();
  ref.onDispose(() {
    socket.dispose();
  });
  return socket;
});
