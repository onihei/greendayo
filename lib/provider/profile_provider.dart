import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final profileProvider = FutureProvider.autoDispose.family<Profile, String>((ref, userId) async {
  final repository = ref.read(profileRepository);
  final profile = await repository.get(userId);
  return profile;
});
