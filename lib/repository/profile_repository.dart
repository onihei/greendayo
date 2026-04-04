import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@riverpod
class ProfileRepository extends _$ProfileRepository {
  @override
  ProfileRepository build() {
    return this;
  }

  Future<Profile> get(String userId) async {
    final doc = await _profilesRef.doc(userId).get();
    if (!doc.exists) {
      throw StateError("profile not found");
    }
    return doc.data()!;
  }

  Stream<DocumentSnapshot<Profile>> observe(String userId) =>
      _profilesRef.doc(userId).snapshots();

  Future<Profile> createOrGet(User user) async {
    final doc = await _profilesRef.doc(user.uid).get();
    if (doc.exists) {
      return doc.data()!;
    }
    final profile = Profile(
      userId: user.uid,
      nickname: user.displayName ?? "名無し",
      photoUrl: user.photoURL,
    );

    await _uploadPhoto(user.uid, user.photoURL);
    await save(profile);
    return profile;
  }

  Future<String> save(Profile entity) async {
    // documentIdをuserIdとする
    final newDoc = _profilesRef.doc(entity.userId);
    await newDoc.set(entity);
    return newDoc.id;
  }

  Future<void> uploadMyProfilePhoto(String contentType, Uint8List bytes) async {
    final myProfile = await ref.read(myProfileProvider.future);
    final storagePath = 'users/${myProfile.userId}/photo';
    final uri =
        Uri.parse('$_storageBaseUrl/storage/upload/$storagePath');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'photo',
        contentType: MediaType.parse(contentType),
      ));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw StateError('Upload failed: ${response.statusCode}');
    }
    ref.invalidate(profilePhotoUrlProvider(myProfile.userId));
  }

  Future<void> _uploadPhoto(String userId, String? url) async {
    http.Response data;
    try {
      data = await http.get(Uri.parse(url!));
      if (data.statusCode != 200) {
        throw StateError("load photo error:${data.statusCode}");
      }
    } catch (e) {
      // OAuth写真が取得できない場合はスキップ（UIでフォールバックアイコン表示）
      return;
    }
    final storagePath = 'users/$userId/photo';
    final uri =
        Uri.parse('$_storageBaseUrl/storage/upload/$storagePath');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        data.bodyBytes,
        filename: 'photo',
        contentType: MediaType.parse(
            data.headers['content-type'] ?? 'image/png'),
      ));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw StateError('Upload failed: ${response.statusCode}');
    }
  }
}

// const _storageBaseUrl = 'http://localhost:10005';
const _storageBaseUrl = 'https://susipero.com';

final _profilesRef =
    FirebaseFirestore.instance.collection('profiles').withConverter<Profile>(
          fromFirestore: (snapshot, _) => Profile.fromSnapShot(snapshot),
          toFirestore: (profile, _) => profile.toJson(),
        );
