import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/features/profile/profile.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePhoto extends ConsumerWidget {
  final Profile profile;
  final double size;
  const ProfilePhoto({super.key, required this.profile, this.size = 48.0});

  @override
  Widget build(context, ref) {
    final url = ref.watch(profilePhotoUrlProvider(profile.userId));
    return ClipRRect(
      key: ValueKey(size),
      borderRadius: BorderRadius.circular(size),
      child: SizedBox(
        width: size,
        height: size,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Icon(Icons.account_circle, size: size),
        ),
      ),
    );
  }
}
