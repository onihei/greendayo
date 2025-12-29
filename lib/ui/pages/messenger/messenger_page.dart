import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/domain/model/session.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/domain/usecase/talk_use_case.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/entity/session.dart';
import 'package:greendayo/navigation_item_widget.dart';
import 'package:greendayo/ui/fragments/profile_photo.dart';
import 'package:greendayo/ui/pages/home/home_page.dart';
import 'package:greendayo/ui/pages/messenger/talk_session.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'messenger_page.g.dart';

@riverpod
class _SelectedSessionId extends _$SelectedSessionId {
  @override
  String? build() {
    return null;
  }

  void select(String? sessionId) {
    state = sessionId;
  }
}

@riverpod
Future<String?> _selectedSessionTitle(Ref ref) async {
  final selectedSessionId = ref.watch(_selectedSessionIdProvider);
  if (selectedSessionId == null) {
    return null;
  }
  final session = await ref.read(sessionProvider(selectedSessionId).future);
  final title = await ref.read(_sessionTitleProvider(session).future);
  return title;
}

@riverpod
Future<String?> _sessionTitle(Ref ref, Session session) async {
  final myProfile = ref.read(myProfileProvider).requireValue;
  final displayMemberId = session.membersExclude(myProfile.userId).first;
  final member = await ref.read(profileProvider(displayMemberId).future);
  return member.nickname;
}

@riverpod
class _ViewController extends _$ViewController {
  @override
  _ViewController build() {
    return this;
  }

  Future<void> deleteSession(sessionId) async {
    await ref.read(talkUseCaseProvider).deleteSession(sessionId: sessionId);
  }

  void showSession(
    BuildContext context, {
    required String sessionId,
  }) {
    ref.read(_selectedSessionIdProvider.notifier).select(sessionId);
  }

  void showProfile(BuildContext context, {required String userId}) {
    ref.read(selectedUserIdProvider.notifier).select(userId);
  }
}

class MessengerPage extends HookConsumerWidget implements NavigationItemWidget {
  const MessengerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSessionId = ref.watch(_selectedSessionIdProvider);
    ref.watch(_selectedSessionTitleProvider);
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      Future.microtask(() async {
        final title = await ref.read(_selectedSessionTitleProvider.future);
        ref.read(appTitleProvider.notifier).setTitle(title);
      });
    } else {
      Future.microtask(() async {
        ref.read(appTitleProvider.notifier).setTitle(null);
      });
    }
    return Navigator(
      pages: [
        MaterialPage(
          child: _sessionPage(context, ref),
          name: "sessions",
        ),
        if (selectedSessionId != null && width <= 600)
          MaterialPage(
            child: TalkSession(
              sessionId: selectedSessionId,
            ),
            name: "session",
          ),
      ],
      onDidRemovePage: (page) {
        if (page.name == "session") {
          ref.read(_selectedSessionIdProvider.notifier).select(null);
          ref.read(appTitleProvider.notifier).setTitle(null);
        }
      },
    );
  }

  Widget _sessionPage(
    BuildContext context,
    WidgetRef ref,
  ) {
    final selectedSessionId = ref.watch(_selectedSessionIdProvider);
    if (MediaQuery.of(context).size.width > 600) {
      return Flex(
        direction: Axis.horizontal,
        children: [
          Flexible(child: _sessionList(context, ref)),
          const VerticalDivider(),
          Flexible(
            child: selectedSessionId == null
                ? Container()
                : TalkSession(sessionId: selectedSessionId),
          ),
        ],
      );
    } else {
      return Container(child: _sessionList(context, ref));
    }
  }

  Widget _sessionList(
    BuildContext context,
    WidgetRef ref,
  ) {
    final result = ref.watch(sessionsStreamProvider);
    return result.maybeWhen(
      data: (value) => ListView.builder(
        itemCount: value.size,
        itemBuilder: (BuildContext context, int index) {
          final doc = value.docs[index];
          return _sessionTile(
            context,
            ref,
            doc,
          );
        },
      ),
      orElse: () => Container(),
      error: (error, stackTrace) => Center(
        child: SelectableText('error $error'),
      ),
    );
  }

  Widget _sessionTile(
    BuildContext context,
    WidgetRef ref,
    QueryDocumentSnapshot<Session> snapshot,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final session = snapshot.data();
    final myProfile = ref.watch(myProfileProvider).requireValue;
    final displayMemberId = session.membersExclude(myProfile.userId).first;
    return Consumer(
      builder: (context, ref, child) {
        final profileAsync = ref.watch(profileProvider(displayMemberId));
        return profileAsync.maybeWhen(
          data: (profile) => Builder(
            builder: (context) {
              return _sessionTileContent(
                context,
                ref,
                snapshot: snapshot,
                profile: profile,
                onTap: () {
                  vc.showSession(
                    context,
                    sessionId: snapshot.id,
                  );
                },
              );
            },
          ),
          orElse: () => const ListTile(),
        );
      },
    );
  }

  Widget _sessionTileContent(
    BuildContext context,
    WidgetRef ref, {
    required QueryDocumentSnapshot<Session> snapshot,
    required Profile profile,
    required GestureTapCallback onTap,
  }) {
    final vc = ref.watch(_viewControllerProvider);
    final selectedSessionId = ref.watch(_selectedSessionIdProvider);
    return ListTile(
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.surface.withValues(alpha: 0.1),
      selected: snapshot.id == selectedSessionId,
      contentPadding: const EdgeInsets.all(8),
      onTap: onTap,
      leading: ProfilePhoto(profile: profile),
      title: Text(profile.nickname),
      trailing: PopupMenuButton<String>(
        onSelected: (String s) async {
          if (s == "profile") {
            vc.showProfile(context, userId: profile.userId);
          }
          if (s == "delete") {
            if (selectedSessionId == snapshot.id) {
              ref.read(_selectedSessionIdProvider.notifier).select(null);
            }
            await vc.deleteSession(snapshot.id);
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem(value: "profile", child: Text("プロフィールを見る")),
            const PopupMenuItem(value: "delete", child: Text("この会話を削除する")),
          ];
        },
      ),
    );
  }

  @override
  String get title => 'メッセージ';

  @override
  Widget? get floatingActionButton => null;
}
