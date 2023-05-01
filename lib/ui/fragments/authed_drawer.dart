import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthedDrawer extends ConsumerWidget {
  const AuthedDrawer({super.key});

  @override
  Widget build(context, ref) {
    final myProfile = ref.watch(myProfileProvider);
    return _drawer(context, ref, myProfile);
  }

  Widget _drawer(context, ref, Profile myProfile) {
    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                Navigator.popAndPushNamed(context, "/profile", arguments: myProfile.userId);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    myProfile.photoSmall,
                    SizedBox(
                      width: 8,
                    ),
                    Text(myProfile.nickname),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              child: Divider(),
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(
                      width: 8,
                    ),
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

  Widget iconImage(String? photoUrl) {
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Image.network(photoUrl),
      );
    } else {
      return FaIcon(FontAwesomeIcons.circleUser, color: Colors.grey);
    }
  }
}
