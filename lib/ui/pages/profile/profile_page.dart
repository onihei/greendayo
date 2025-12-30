import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/ui/fragments/profile_photo.dart';
import 'package:greendayo/ui/pages/profile/edit_my_profile_page.dart';
import 'package:greendayo/ui/pages/profile/talk_session_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_page.g.dart';

@riverpod
class _ViewController extends _$ViewController {
  @override
  _ViewController build() {
    return this;
  }

  void back(BuildContext context) {
    Navigator.of(context).pop();
  }

  void doEdit(ValueNotifier<bool> editMyProfile) {
    editMyProfile.value = true;
  }

  void newSession(ValueNotifier<bool> startTalkSession) {
    startTalkSession.value = true;
  }
}

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editMyProfile = useState(false);
    final startTalkSession = useState(false);
    final profileAsync = ref.watch(profileProvider(userId));
    return profileAsync.when(
      data: (profile) => Navigator(
        pages: [
          MaterialPage(
            child: _profilePage(
              context,
              ref,
              profile,
              editMyProfile,
              startTalkSession,
            ),
          ),
          if (editMyProfile.value)
            const MaterialPage(
              child: EditMyProfilePage(),
              name: "edit",
            ),
          if (startTalkSession.value)
            MaterialPage(
              child: TalkSessionPage(profile: profile),
              name: "talk",
            ),
        ],
        onDidRemovePage: (page) {
          if (page.name == "edit") {
            editMyProfile.value = false;
          }
          if (page.name == "talk") {
            startTalkSession.value = false;
          }
        },
      ),
      error: (err, _) => Text(err.toString()),
      loading: () => SizedBox.shrink(),
    );
  }

  Widget _profilePage(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    ValueNotifier<bool> editMyProfile,
    ValueNotifier<bool> startTalkSession,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final myProfile = ref.watch(myProfileProvider).value;
    final isMe = userId == myProfile?.userId;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            vc.back(context);
          },
        ),
        title: Text("プロフィール${isMe ? "(自分)" : ""}"),
        actions: <Widget>[
          if (isMe)
            IconButton(
              onPressed: () {
                vc.doEdit(editMyProfile);
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      floatingActionButton:
          _floatingActionButton(context, ref, startTalkSession),
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
                  ProfilePhoto(profile: profile, size: 120),
                  SizedBox(height: 10),
                  Text(profile.nickname),
                  SizedBox(height: 32),
                  Text(profile.text ?? "こんにちは！私は${profile.nickname}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _floatingActionButton(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> startTalkSession,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final myProfile = ref.watch(myProfileProvider).requireValue;
    final isMe = userId == myProfile.userId;
    if (isMe) {
      return null;
    }
    return FloatingActionButton(
      child: const Icon(Icons.email),
      onPressed: () {
        vc.newSession(startTalkSession);
      },
    );
  }
}
