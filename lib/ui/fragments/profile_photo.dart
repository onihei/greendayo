import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePhoto extends ConsumerWidget {
  final Profile profile;
  final double size;
  const ProfilePhoto({super.key, required this.profile, this.size = 48.0});

  @override
  Widget build(context, ref) {
    final profilePhotoUrlAsync =
        ref.watch(profilePhotoUrlProvider(profile.userId));
    return ClipRRect(
      key: ValueKey(size),
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        child: profilePhotoUrlAsync.when(
          data: (url) => CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          error: (error, _) => Icon(Icons.account_circle, size: size),
          loading: () => CircularProgressIndicator(),
        ),
      ),
    );
  }
}
