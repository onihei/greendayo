import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/messenger/session.dart';
import 'package:greendayo/features/messenger/talk.dart';
import 'package:greendayo/shared/firebase/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_repository.g.dart';

@riverpod
TalkRepository talkRepository(Ref ref) => TalkRepository(
      ref.read(firestoreProvider),
    );

class TalkRepository {
  final FirebaseFirestore _firestore;

  TalkRepository(this._firestore);

  CollectionReference<Session> get _sessionsRef =>
      _firestore.collection('sessions').withConverter<Session>(
            fromFirestore: (snapshot, _) => Session.fromJson({
              ...snapshot.data()!,
              'updatedAt': snapshot.get('updatedAt')
            }),
            toFirestore: (session, _) {
              final json = session.toJson();
              json['updatedAt'] = Timestamp.fromDate(session.updatedAt);
              return json;
            },
          );

  CollectionReference<Talk> _talksRef(String sessionId) {
    return _sessionsRef
        .doc(sessionId)
        .collection("talks")
        .withConverter<Talk>(
          fromFirestore: (snapshot, _) => Talk.fromJson({
            ...snapshot.data()!,
            'createdAt': snapshot.get('createdAt')
          }),
          toFirestore: (talk, _) {
            final json = talk.toJson();
            json['createdAt'] = Timestamp.fromDate(talk.createdAt);
            return json;
          },
        );
  }

  Stream<QuerySnapshot<Talk>> observe(String sessionId) {
    return _talksRef(sessionId).orderBy('createdAt').snapshots();
  }

  Future<String> save(String sessionId, Talk entity) async {
    final newDoc = _talksRef(sessionId).doc();
    await newDoc.set(entity);
    return newDoc.id;
  }
}
