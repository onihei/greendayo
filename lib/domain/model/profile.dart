import 'package:firebase_storage/firebase_storage.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile.g.dart';

@riverpod
Future<Profile> profile(Ref ref, String uid) async {
  final profile = await ref.read(profileRepositoryProvider).get(uid);
  return profile;
}

/// 自分のプロフィールを取得するProvider
/// ユーザーが認証されていない場合は例外をスローする
/// Home 画面で watch するので、以降の機能では requiredValue を使う
@riverpod
Future<Profile> myProfile(Ref ref) async {
  final user = await ref.watch(userProvider.future);
  if (user != null) {
    return await ref.watch(profileProvider(user.uid).future);
  } else {
    throw Exception('No authenticated user');
  }
}

@riverpod
Future<String> profilePhotoUrl(Ref ref, String uid) async {
  return FirebaseStorage.instance
      .ref()
      .child('users/$uid/photo')
      .getDownloadURL();
}
