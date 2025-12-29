import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

@riverpod
Stream<QuerySnapshot<Session>> sessionsStream(Ref ref) {
  return ref.read(sessionRepositoryProvider).observe();
}

@riverpod
Future<Session> session(Ref ref, String sessionId) {
  return ref.read(sessionRepositoryProvider).get(sessionId);
}
