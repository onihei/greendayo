import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greendayo/features/profile/profile.dart';
import 'package:greendayo/shared/config.dart';
import 'package:greendayo/shared/exceptions/app_exception.dart';
import 'package:greendayo/shared/firebase/firebase_providers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_repository.g.dart';

@riverpod
ProfileRepository profileRepository(Ref ref) => ProfileRepository(
      ref.read(firestoreProvider),
      ref.read(httpClientProvider),
    );

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final http.Client _httpClient;

  ProfileRepository(this._firestore, this._httpClient);

  CollectionReference<Profile> get _profilesRef =>
      _firestore.collection('profiles').withConverter<Profile>(
            fromFirestore: (snapshot, _) =>
                Profile.fromJson(snapshot.id, snapshot.data()!),
            toFirestore: (profile, _) => profile.toJson(),
          );

  Future<Profile> get(String userId) async {
    final doc = await _profilesRef.doc(userId).get();
    if (!doc.exists) {
      throw AppException(ErrorKind.notFound, 'プロフィールが見つかりません');
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
    final newDoc = _profilesRef.doc(entity.userId);
    await newDoc.set(entity);
    return newDoc.id;
  }

  Future<void> uploadPhoto({
    required String userId,
    required String contentType,
    required Uint8List bytes,
  }) async {
    final storagePath = 'users/$userId/photo';
    final uri = Uri.parse('$storageBaseUrl/storage/upload/$storagePath');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'photo',
        contentType: MediaType.parse(contentType),
      ));
    final response = await _httpClient.send(request);
    if (response.statusCode != 200) {
      throw AppException(
          ErrorKind.server, 'アップロードに失敗しました: ${response.statusCode}');
    }
  }

  Future<void> _uploadPhoto(String userId, String? url) async {
    http.Response data;
    try {
      data = await _httpClient.get(Uri.parse(url!));
      if (data.statusCode != 200) {
        throw AppException(
            ErrorKind.network, '写真の取得に失敗しました: ${data.statusCode}');
      }
    } catch (e) {
      if (e is AppException) rethrow;
      return;
    }
    final storagePath = 'users/$userId/photo';
    final uri = Uri.parse('$storageBaseUrl/storage/upload/$storagePath');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        data.bodyBytes,
        filename: 'photo',
        contentType:
            MediaType.parse(data.headers['content-type'] ?? 'image/png'),
      ));
    final response = await _httpClient.send(request);
    if (response.statusCode != 200) {
      throw AppException(
          ErrorKind.server, 'アップロードに失敗しました: ${response.statusCode}');
    }
  }
}
