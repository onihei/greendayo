import 'package:flutter/material.dart';
import 'package:greendayo/ui/pages/messenger/talk_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewSessionPage extends ConsumerWidget {
  const NewSessionPage({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("新しい会話")),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: TalkSession.createNew(userId),
      ),
    );
  }
}
