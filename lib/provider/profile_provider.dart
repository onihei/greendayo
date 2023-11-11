import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final profileStreamProvider =
    StreamProvider.autoDispose.family<Profile, String>((ref, userId) {
  return ref
      .read(profileRepository)
      .observe(userId)
      .asyncMap((event) => event.data() ?? Profile.anonymous());
});
