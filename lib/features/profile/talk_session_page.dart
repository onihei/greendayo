import 'package:flutter/material.dart';
import 'package:greendayo/features/messenger/talk_session_widget.dart';
import 'package:greendayo/features/profile/profile.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TalkSessionPage extends ConsumerWidget {
  const TalkSessionPage({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(profile.nickname)),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: TalkSessionWidget(userId: profile.userId),
      ),
    );
  }
}
