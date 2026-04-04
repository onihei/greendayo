import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/features/messenger/session.dart';
import 'package:greendayo/shared/exceptions/app_exception.dart';
import 'package:greendayo/shared/firebase/firebase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_repository.g.dart';

@riverpod
SessionRepository sessionRepository(Ref ref) => SessionRepository(
      ref.read(firestoreProvider),
    );

class SessionRepository {
  final FirebaseFirestore _firestore;

  SessionRepository(this._firestore);

  CollectionReference<Session> get _sessionsRef =>
      _firestore.collection('sessions').withConverter<Session>(
            fromFirestore: (snapshot, _) => Session.fromJson({
              ...snapshot.data()!,
              'updatedAt':
                  (snapshot.get('updatedAt') as Timestamp).toDate(),
            }),
            toFirestore: (session, _) {
              final json = session.toJson();
              json['updatedAt'] = Timestamp.fromDate(session.updatedAt);
              return json;
            },
          );

  Future<Session> get(String sessionId) async {
    final doc = await _sessionsRef.doc(sessionId).get();
    if (!doc.exists) {
      throw AppException(ErrorKind.notFound, 'セッションが見つかりません');
    }
    return doc.data()!;
  }

  Stream<QuerySnapshot<Session>> observe({required String userId}) {
    return _sessionsRef
        .orderBy('updatedAt', descending: true)
        .where("members", arrayContains: userId)
        .snapshots();
  }

  Future<void> updateTimestamp(String sessionId) async {
    await _sessionsRef.doc(sessionId).update({
      "updatedAt": Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<String> save(Session entity) async {
    final newDoc = _sessionsRef.doc();
    await newDoc.set(entity);
    return newDoc.id;
  }

  Future<void> delete(String sessionId) async {
    await _sessionsRef.doc(sessionId).delete();
  }
}
