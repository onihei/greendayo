import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:greendayo/provider/sessions_provider.dart';
import 'package:greendayo/tab_config.dart';
import 'package:greendayo/ui/pages/messenger/talk_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _selectedSessionIdProvider = StateProvider<String?>((ref) => null);

class MessengerTabConfig implements TabConfig {
  @override
  String get label => 'メッセージ';

  @override
  Widget get icon => Icon(Icons.email_outlined);

  @override
  Widget get activeIcon => Icon(Icons.email);

  @override
  Function get factoryMethod => MessengerPage.new;

  @override
  Widget? get floatingActionButton => null;
}

class MessengerPage extends ConsumerWidget {
  const MessengerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_selectedSessionIdProvider);

    return Flex(
      direction: Axis.horizontal,
      children: [
        Flexible(
          child: _sessionList(context, ref),
        ),
        Flexible(
          child: sessionId == null ? Container() : TalkSession.loaded(sessionId),
        ),
      ],
    );
  }

  Widget _sessionList(BuildContext context, WidgetRef ref) {
    final result = ref.watch(sessionsStreamProvider);
    return result.maybeWhen(
        data: (value) => ListView.builder(
              itemCount: value.size,
              itemBuilder: (BuildContext context, int index) {
                final doc = value.docs[index];
                return _sessionTile(context, ref, doc);
              },
            ),
        orElse: () => SizedBox.shrink(),
        error: (error, stackTrace) => Center(
              child: SelectableText('error ${error}'),
            ));
  }

  Widget _sessionTile(BuildContext context, WidgetRef ref, QueryDocumentSnapshot<Session> snapshot) {
    final session = snapshot.data();
    final myProfile = ref.watch(myProfileProvider);
    final displayMemberId = session.members.where((id) => id != myProfile.userId).single;
    return InkWell(
      onTap: () {
        ref.read(_selectedSessionIdProvider.notifier).state = snapshot.id;
      },
      child: Consumer(
        builder: (context, ref, child) {
          final profile = ref.watch(profileProvider(displayMemberId));
          final selectedId = ref.watch(_selectedSessionIdProvider);
          final color = snapshot.id == selectedId
              ? Theme.of(context).colorScheme.onBackground.withOpacity(0.1)
              : Colors.transparent;
          return profile.maybeWhen(
            data: (data) => Ink(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    data.photoMiddle,
                    SizedBox(
                      width: 8,
                    ),
                    Text(data.nickname),
                  ],
                ),
              ),
            ),
            orElse: () => SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
