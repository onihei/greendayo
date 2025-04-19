import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _viewControllerProvider = Provider.autoDispose<_ViewController>(
  (ref) => _ViewController(ref),
);

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  void showProfile(BuildContext context, Profile profile) {
    Navigator.pop(context);
    ref.read(targetUserIdProvider.notifier).state = profile.userId;
  }
}

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
                ref.read(_viewControllerProvider).showProfile(context, profile);
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    profile.photoSmall,
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

  Widget iconImage(String? photoUrl) {
    if (photoUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Image.network(photoUrl),
      );
    } else {
      return const FaIcon(FontAwesomeIcons.circleUser, color: Colors.grey);
    }
  }
}
