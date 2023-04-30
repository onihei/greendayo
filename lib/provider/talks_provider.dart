import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/repository/talk_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final talksStreamProvider = StreamProvider.autoDispose.family<QuerySnapshot<Talk>, String>((ref, sessionId) {
  return ref.read(talkRepository(sessionId)).observe();
});
