import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_repository.g.dart';

@riverpod
class TalkRepository extends _$TalkRepository {
  @override
  SessionTalkRepository build(String sessionId) {
    return SessionTalkRepository(sessionId);
  }
}

class SessionTalkRepository {
  final String sessionId;

  SessionTalkRepository(this.sessionId);

  Stream<QuerySnapshot<Talk>> observe() {
    return _talksRef(sessionId).orderBy('createdAt').snapshots();
  }

  Future<String> save(Talk entity) async {
    final newDoc = _talksRef(sessionId).doc();
    await newDoc.set(entity);
    return newDoc.id;
  }
}

final _sessionsRef =
    FirebaseFirestore.instance.collection('sessions').withConverter<Session>(
          fromFirestore: (snapshot, _) => Session.fromSnapShot(snapshot),
          toFirestore: (session, _) => session.toJson(),
        );

CollectionReference<Talk> _talksRef(String sessionId) {
  return _sessionsRef.doc(sessionId).collection("talks").withConverter<Talk>(
        fromFirestore: (snapshot, _) => Talk.fromSnapShot(snapshot),
        toFirestore: (talk, _) => talk.toJson(),
      );
}
