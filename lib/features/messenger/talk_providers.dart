import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/messenger/talk.dart';
import 'package:greendayo/features/messenger/talk_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_providers.g.dart';

@riverpod
Stream<QuerySnapshot<Talk>> talksStream(Ref ref, String sessionId) {
  return ref.read(talkRepositoryProvider).observe(sessionId);
}
