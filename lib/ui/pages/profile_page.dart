import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(myProfileProvider);
    final profile = ref.watch(profileProvider(userId));
    final isMe = userId == myProfile.userId;

    return profile.when(
      data: (data) => Scaffold(
        appBar: AppBar(
          title: Text("プロフィール${isMe ? "(自分)" : ""}"),
          actions: <Widget>[
            if (isMe)
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/profileEdit");
                },
                icon: Icon(Icons.edit),
              ),
          ],
        ),
        body: Container(
          color: Theme.of(context).colorScheme.background,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: 400),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    data.photoLarge,
                    Text(data.nickname),
                    SizedBox(
                      height: 40,
                    ),
                    Text(data.text ?? "こんにちは！私は${data.nickname}"),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      error: (err, _) => Text(err.toString()),
      loading: () => SizedBox.shrink(),
    );
  }
}