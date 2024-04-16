import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/profile_provider.dart';
import 'package:greendayo/provider/session_provider.dart';
import 'package:greendayo/tab_config.dart';
import 'package:greendayo/ui/pages/messenger/talk_session.dart';
import 'package:greendayo/usecase/talk_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _selectedSessionIdProvider = StateProvider<String?>((ref) => null);

class MessengerTabConfig implements TabConfig {
  @override
  String get label => 'メッセージ';

  @override
  Widget get icon => const Icon(Icons.email_outlined);

  @override
  Widget get activeIcon => const Icon(Icons.email);

  @override
  Function get factoryMethod => MessengerPage.new;

  @override
  Widget? get floatingActionButton => null;
}

final _viewControllerProvider =
    Provider.autoDispose<_ViewController>((ref) => _ViewController(ref));

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  Future<void> deleteSession(sessionId) async {
    await ref.read(talkUseCase).deleteSession(sessionId: sessionId);
  }

  void showSession({required String sessionId, required bool needPush}) {
    ref.read(_selectedSessionIdProvider.notifier).state = sessionId;
    if (needPush) {
      ref.read(targetSessionIdProvider.notifier).state = sessionId;
    }
  }
}

class MessengerPage extends ConsumerWidget {
  const MessengerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = ref.watch(_selectedSessionIdProvider);

    return Builder(
      builder: (context) {
        if (MediaQuery.of(context).size.width > 600) {
          return Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                child: _sessionList(context, ref),
              ),
              const VerticalDivider(),
              Flexible(
                child: sessionId == null
                    ? Container()
                    : TalkSession.loaded(sessionId),
              ),
            ],
          );
        } else {
          return Container(
            child: _sessionList(context, ref),
          );
        }
      },
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
      orElse: () => Container(),
      error: (error, stackTrace) => Center(
        child: SelectableText('error $error'),
      ),
    );
  }

  Widget _sessionTile(BuildContext context, WidgetRef ref,
      QueryDocumentSnapshot<Session> snapshot) {
    final session = snapshot.data();
    final myProfile = ref.watch(myProfileProvider).requireValue;
    final displayMemberId = session.membersExclude(myProfile.userId).single;
    return Consumer(
      builder: (context, ref, child) {
        final profileAsync = ref.watch(profileStreamProvider(displayMemberId));
        return profileAsync.maybeWhen(
          data: (profile) => Builder(
            builder: (context) {
              final needPush = MediaQuery.of(context).size.width <= 600;
              return _sessionTileContent(context, ref,
                  snapshot: snapshot, profile: profile, onTap: () {
                ref.read(_viewControllerProvider).showSession(
                      sessionId: snapshot.id,
                      needPush: needPush,
                    );
              });
            },
          ),
          orElse: () => const ListTile(),
        );
      },
    );
  }

  Widget _sessionTileContent(BuildContext context, WidgetRef ref,
      {required QueryDocumentSnapshot<Session> snapshot,
      required Profile profile,
      required GestureTapCallback onTap}) {
    final selectedId = ref.watch(_selectedSessionIdProvider);

    return ListTile(
      selectedTileColor:
          Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
      selected: snapshot.id == selectedId,
      contentPadding: const EdgeInsets.all(8),
      onTap: onTap,
      leading: profile.photoMiddle,
      title: Text(profile.nickname),
      trailing: PopupMenuButton<String>(
        onSelected: (String s) async {
          if (s == "profile") {
            ref.read(targetUserIdProvider.notifier).state = profile.userId;
          }
          if (s == "delete") {
            if (selectedId == snapshot.id) {
              ref.read(_selectedSessionIdProvider.notifier).state = null;
            }
            await ref.read(_viewControllerProvider).deleteSession(snapshot.id);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(
              value: "profile",
              child: Text("プロフィールを見る"),
            ),
            const PopupMenuItem(
              value: "delete",
              child: Text("この会話を削除する"),
            ),
          ];
        },
      ),
    );
  }
}
