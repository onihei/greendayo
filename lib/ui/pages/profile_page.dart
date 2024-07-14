import 'package:web/web.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:greendayo/ui/pages/profile_edit_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _viewControllerProvider =
    Provider.autoDispose<_ViewController>((ref) => _ViewController(ref));

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  void back() {
    ref.read(targetUserIdProvider.notifier).state = null;
  }

  void doEdit() {
    ref.read(editProfileProvider.notifier).state = true;
  }

  void newSession() {
    ref.read(newSessionProvider.notifier).state = true;
  }
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStreamProvider(userId));
    final editProfile = ref.watch(editProfileProvider);
    return profile.when(
      data: (data) => Navigator(
        pages: [
          MaterialPage(child: _profilePage(context, ref, data)),
          if (editProfile)
            const MaterialPage(child: ProfileEditPage(), name: "edit"),
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }
          if (route.settings.name == "edit") {
            if (kIsWeb) {
              html.window.history.back();
            }
            ref.read(editProfileProvider.notifier).state = false;
          }
          return true;
        },
      ),
      error: (err, _) => Text(err.toString()),
      loading: () => SizedBox.shrink(),
    );
  }

  Widget _profilePage(BuildContext context, WidgetRef ref, Profile profile) {
    final myProfile = ref.watch(myProfileProvider).value;
    final isMe = userId == myProfile?.userId;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            ref.read(_viewControllerProvider).back();
          },
        ),
        title: Text("プロフィール${isMe ? "(自分)" : ""}"),
        actions: <Widget>[
          if (isMe)
            IconButton(
              onPressed: () {
                ref.read(_viewControllerProvider).doEdit();
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      floatingActionButton: _floatingActionButton(context, ref),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  profile.photoLarge,
                  SizedBox(
                    height: 10,
                  ),
                  Text(profile.nickname),
                  SizedBox(
                    height: 32,
                  ),
                  Text(profile.text ?? "こんにちは！私は${profile.nickname}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _floatingActionButton(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider).requireValue;
    final isMe = userId == myProfile.userId;
    if (isMe) {
      return null;
    }
    return FloatingActionButton(
      child: const Icon(
        Icons.email,
      ),
      onPressed: () {
        ref.read(_viewControllerProvider).newSession();
      },
    );
  }
}
