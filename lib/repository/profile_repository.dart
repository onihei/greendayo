import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final profilesRef = FirebaseFirestore.instance.collection('profiles').withConverter<Profile>(
      fromFirestore: (snapshot, _) => Profile.fromSnapShot(snapshot),
      toFirestore: (profile, _) => profile.toJson(),
    );

final profileRepository = Provider.autoDispose<ProfileRepository>((ref) => _ProfileRepositoryImpl(ref));

abstract class ProfileRepository {
  Future<Profile> get(String userId);

  Stream<DocumentSnapshot<Profile>> observe(String userId);

  Future<Profile> createOrGet(User user);

  Future<String> save(Profile entity);

  Future<void> uploadMyProfilePhoto(String contentType, Uint8List bytes);
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
  Stream<DocumentSnapshot<Profile>> observe(String userId) => profilesRef.doc(userId).snapshots();

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

    await _uploadPhoto(user.uid, user.photoURL);
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

  @override
  Future<void> uploadMyProfilePhoto(String contentType, Uint8List bytes) async {
    final myProfile = ref.read(myProfileProvider);
    final storageRef = FirebaseStorage.instance.ref().child('users/${myProfile.userId}/photo');
    final uploadTask = storageRef.putData(
      bytes,
      SettableMetadata(
        contentType: contentType
      ),
    );
    await uploadTask;
    ref.invalidate(avatarProvider(myProfile.userId));
  }

  Future<void> _uploadPhoto(String userId, String? url) async {
    http.Response data;
    try {
      data = await http.get(Uri.parse(url!));
      if (data.statusCode != 200) {
        throw StateError("load photo error:${data.statusCode}");
      }
    } catch (e) {
      final url = await FirebaseStorage.instance.ref().child('default_avatar.png').getDownloadURL();
      data = await http.get(Uri.parse(url));
    }
    final storageRef = FirebaseStorage.instance.ref().child('users/${userId}/photo');
    final uploadTask = storageRef.putData(
      data.bodyBytes,
      SettableMetadata(
        contentType: data.headers['content-type'],
      ),
    );
    await uploadTask;
  }
}
