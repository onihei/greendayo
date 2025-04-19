import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/repository/session_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final talkRepository = Provider.autoDispose.family<TalkRepository, String?>((
  ref,
  sessionId,
) {
  return _TalkRepositoryImpl(ref, sessionId: sessionId);
});

abstract class TalkRepository {
  Stream<QuerySnapshot<Talk>> observe();

  Future<String> save(Talk entity);
}

CollectionReference<Talk> talksRef(String sessionId) {
  return sessionsRef
      .doc(sessionId)
      .collection("talks")
      .withConverter<Talk>(
        fromFirestore: (snapshot, _) => Talk.fromSnapShot(snapshot),
        toFirestore: (talk, _) => talk.toJson(),
      );
}

class _TalkRepositoryImpl implements TalkRepository {
  final Ref ref;
  final String? sessionId;

  _TalkRepositoryImpl(this.ref, {required this.sessionId});

  @override
  Stream<QuerySnapshot<Talk>> observe() {
    return talksRef(sessionId!).orderBy('createdAt').snapshots();
  }

  @override
  Future<String> save(Talk entity) async {
    if (sessionId == null) {
      return "";
    }

    final newDoc = talksRef(sessionId!).doc();
    await newDoc.set(entity);
    return newDoc.id;
  }
}
