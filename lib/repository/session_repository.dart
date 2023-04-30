import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sessionRepository = Provider.autoDispose<SessionRepository>((ref) => _SessionRepositoryImpl(ref));

abstract class SessionRepository {
  Stream<QuerySnapshot<Session>> observe();
}

final sessionsRef = FirebaseFirestore.instance.collection('sessions').withConverter<Session>(
      fromFirestore: (snapshot, _) => Session.fromSnapShot(snapshot),
      toFirestore: (session, _) => session.toJson(),
    );

class _SessionRepositoryImpl implements SessionRepository {
  final Ref ref;

  _SessionRepositoryImpl(this.ref);

  @override
  Stream<QuerySnapshot<Session>> observe() {
    final myProfile = ref.watch(myProfileProvider);
    return sessionsRef
        .orderBy('updatedAt', descending: true)
        .where("members", arrayContains: myProfile.userId)
        .snapshots();
  }
}
