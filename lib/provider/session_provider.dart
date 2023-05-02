import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sessionsStreamProvider = StreamProvider.autoDispose<QuerySnapshot<Session>>((ref) {
  return ref.read(sessionRepository).observe();
});

final sessionProvider = FutureProvider.autoDispose.family<Session, String>((ref, sessionId) {
  return ref.read(sessionRepository).get(sessionId);
});
