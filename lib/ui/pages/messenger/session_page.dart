import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:greendayo/provider/session_provider.dart';
import 'package:greendayo/ui/pages/messenger/talk_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SessionPage extends ConsumerWidget {
  const SessionPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionFuture = ref.watch(sessionProvider(sessionId));
    return sessionFuture.maybeWhen(
      data: (session) {
        return Consumer(builder: (context, ref, child) {
          final myProfile = ref.watch(myProfileProvider);
          final someone = session.membersExclude(myProfile.userId).single;
          final profileFuture = ref.watch(profileProvider(someone));
          return profileFuture.maybeWhen(
            data: (profile) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(profile.nickname),
                ),
                body: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: TalkSession.loaded(sessionId),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          );
        });
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
