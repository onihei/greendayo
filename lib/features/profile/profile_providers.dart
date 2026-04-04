import 'package:greendayo/features/auth/user_provider.dart';
import 'package:greendayo/features/profile/profile.dart';
import 'package:greendayo/features/profile/profile_repository.dart';
import 'package:greendayo/shared/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_providers.g.dart';

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
    return await ref.read(profileRepositoryProvider).createOrGet(user);
  } else {
    throw Exception('No authenticated user');
  }
}

@riverpod
String profilePhotoUrl(Ref ref, String uid) {
  return '$storageBaseUrl/storage/users/$uid/photo';
}
