import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/features/auth/login_dialog.dart';
import 'package:greendayo/features/auth/user_provider.dart';
import 'package:greendayo/features/profile/profile.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:greendayo/shared/ui/profile_photo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthedDrawer extends ConsumerWidget {
  const AuthedDrawer({super.key});

  @override
  Widget build(context, ref) {
    final user = ref.watch(userProvider).value;
    if (user == null) {
      return _guestDrawer(context);
    }
    final myProfile = ref.watch(myProfileProvider).requireValue;
    return _drawer(context, ref, myProfile);
  }

  Widget _guestDrawer(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.person_outline),
                  const SizedBox(width: 8),
                  const Text('ゲスト'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Divider(),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => const LoginDialog(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.login),
                    SizedBox(width: 8),
                    Text("ログイン"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
