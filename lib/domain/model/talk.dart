import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/repository/talk_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk.g.dart';

@riverpod
Stream<QuerySnapshot<Talk>> talksStream(Ref ref, String sessionId) {
  return ref.read(talkRepositoryProvider(sessionId)).observe();
}
