import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final profilesRef = FirebaseFirestore.instance.collection('profiles').withConverter<Profile>(
      fromFirestore: (snapshot, _) => Profile.fromSnapShot(snapshot),
      toFirestore: (profile, _) => profile.toJson(),
    );

final profileRepository = Provider.autoDispose<ProfileRepository>((ref) => _ProfileRepositoryImpl(ref));

abstract class ProfileRepository {
  Future<Profile> get(String userId);

  Future<Profile> createOrGet(User user);

  Future<String> save(Profile entity);
}

class _ProfileRepositoryImpl implements ProfileRepository {
  final Ref ref;

  _ProfileRepositoryImpl(this.ref);

  @override
  Future<Profile> get(String userId) async {
    final doc = await profilesRef.doc(userId).get();
    if (!doc.exists) {
      throw StateError("profile not found");
    }
    return doc.data()!;
  }

  @override
  Future<Profile> createOrGet(User user) async {
    final doc = await profilesRef.doc(user.uid).get();
    if (doc.exists) {
      return doc.data()!;
    }
    final profile = Profile(
      userId: user.uid,
      nickname: user.displayName ?? "名無し",
      photoUrl: user.photoURL,
    );
    save(profile);
    return profile;
  }

  @override
  Future<String> save(Profile entity) async {
    // documentIdをuserIdとする
    final newDoc = profilesRef.doc(entity.userId);
    await newDoc.set(entity);
    return newDoc.id;
  }
}