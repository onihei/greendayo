import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sessionRepository = Provider.autoDispose<SessionRepository>(
    (ref) => _SessionRepositoryImpl(ref));

abstract class SessionRepository {
  Future<Session> get(String sessionId);

  Stream<QuerySnapshot<Session>> observe();

  Future<void> updateTimestamp(String sessionId);

  Future<String> save(Session entity);

  Future<void> delete(String sessionId);
}

final sessionsRef =
    FirebaseFirestore.instance.collection('sessions').withConverter<Session>(
          fromFirestore: (snapshot, _) => Session.fromSnapShot(snapshot),
          toFirestore: (session, _) => session.toJson(),
        );

class _SessionRepositoryImpl implements SessionRepository {
  final Ref ref;

  _SessionRepositoryImpl(this.ref);

  @override
  Future<Session> get(String sessionId) async {
    final doc = await sessionsRef.doc(sessionId).get();
    if (!doc.exists) {
      throw StateError("session not found");
    }
    return doc.data()!;
  }

  @override
  Stream<QuerySnapshot<Session>> observe() {
    final myProfile = ref.read(myProfileProvider).requireValue;
    return sessionsRef
        .orderBy('updatedAt', descending: true)
        .where("members", arrayContains: myProfile.userId)
        .snapshots();
  }

  @override
  Future<void> updateTimestamp(String sessionId) async {
    await sessionsRef
        .doc(sessionId)
        .update({"updatedAt": Timestamp.fromDate(DateTime.now())});
  }

  @override
  Future<String> save(Session entity) async {
    final newDoc = sessionsRef.doc();
    await newDoc.set(entity);
    return newDoc.id;
  }

  @override
  Future<void> delete(String sessionId) async {
    await sessionsRef.doc(sessionId).delete();
  }
}
