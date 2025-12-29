import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/ui/fragments/profile_photo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthedDrawer extends ConsumerWidget {
  const AuthedDrawer({super.key});

  @override
  Widget build(context, ref) {
    final myProfile = ref.watch(myProfileProvider).requireValue;
    return _drawer(context, ref, myProfile);
  }

  Widget _drawer(context, ref, Profile profile) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                ref
                    .read(selectedUserIdProvider.notifier)
                    .select(profile.userId);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ProfilePhoto(profile: profile),
                    const SizedBox(width: 8),
                    Text(profile.nickname),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Divider(),
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text("ログアウト"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
