import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/messenger/session.dart';
import 'package:greendayo/features/messenger/session_repository.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_providers.g.dart';

@riverpod
Stream<QuerySnapshot<Session>> sessionsStream(Ref ref) {
  final myProfile = ref.watch(myProfileProvider).requireValue;
  return ref.read(sessionRepositoryProvider).observe(userId: myProfile.userId);
}

@riverpod
Future<Session> session(Ref ref, String sessionId) {
  return ref.read(sessionRepositoryProvider).get(sessionId);
}
