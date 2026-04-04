import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/features/messenger/talk.dart';
import 'package:greendayo/features/messenger/talk_providers.dart';
import 'package:greendayo/features/messenger/talk_use_case.dart';
import 'package:greendayo/features/profile/profile_providers.dart';
import 'package:greendayo/shared/utils/snackbars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_session_widget.g.dart';

@riverpod
class _ViewController extends _$ViewController {
  @override
  _ViewController build() {
    return this;
  }

  Future<void> post(
    BuildContext context, {
    String? destinationUserId,
    required ValueNotifier<String?> currentSessionId,
    required String text,
  }) async {
    final useCase = ref.watch(talkUseCaseProvider);
    if (text.trim().isEmpty) {
      showSnackBar(
        context,
        content: Text('テキストを入力してください'),
        duration: Duration(seconds: 1),
      );
      return;
    }
    final sessionId = currentSessionId.value;
    if (sessionId != null) {
      await useCase.createTalk(
        sessionId: sessionId,
        text: text,
      );
    } else if (destinationUserId != null) {
      final newSessionId = await useCase.createSession(
        userId: destinationUserId,
        text: text,
      );
      currentSessionId.value = newSessionId;
    }
  }

  Future<void> back(
    BuildContext context,
  ) async {
    Navigator.of(context).pop();
  }
}

class TalkSessionWidget extends HookConsumerWidget {
  const TalkSessionWidget({super.key, this.userId, this.sessionId});

  final String? userId;
  final String? sessionId;

  bool formNeeded() => userId != null || sessionId != null;

  @override
  Widget build(context, ref) {
    final currentSessionId = useState<String?>(sessionId);
    useEffect(() {
      currentSessionId.value = sessionId;
      return null;
    }, [sessionId]);
    return Column(
      children: [
        Expanded(child: _talkList(context, ref, currentSessionId)),
        _form(context, ref, currentSessionId),
      ],
    );
  }

  Widget _talkList(BuildContext context, WidgetRef ref,
      ValueNotifier<String?> currentSessionId) {
    final sessionId = currentSessionId.value;
    if (sessionId == null) {
      return Container();
    }
    final talks = ref.watch(talksStreamProvider(sessionId));
    return talks.maybeWhen(
      data: (value) => _talkListContent(context, ref, value, currentSessionId),
      orElse: () => Container(),
      error: (error, stackTrace) => Center(
        child: SelectableText('error $error'),
      ),
    );
  }

  Widget _talkListContent(
    BuildContext context,
    WidgetRef ref,
    QuerySnapshot<Talk> snapshot,
    ValueNotifier<String?> currentSessionId,
  ) {
    final sessionId = currentSessionId.value;
    if (sessionId == null) {
      return Container();
    }
    return _AnimatedTalkList(
      sessionId: sessionId,
      initialSnapshot: snapshot,
    );
  }

  Widget _form(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> currentSessionId,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final controller = useTextEditingController();
    Widget? backButton;
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      backButton = IconButton(
        onPressed: () async {
          await vc.back(
            context,
          );
        },
        icon: const Icon(Icons.arrow_back),
      );
    }
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (backButton != null) backButton,
            Expanded(
              child: TextField(
                keyboardType: TextInputType.multiline,
                controller: controller,
                maxLines: null,
                textInputAction: TextInputAction.send,
              ),
            ),
            IconButton(
              onPressed: () async {
                await vc.post(
                  context,
                  destinationUserId: userId,
                  currentSessionId: currentSessionId,
                  text: controller.text,
                );
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTalkList extends HookConsumerWidget {
  const _AnimatedTalkList({
    required this.sessionId,
    required this.initialSnapshot,
  });

  final String sessionId;
  final QuerySnapshot<Talk> initialSnapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedStateKey = useRef(GlobalKey<AnimatedListState>());
    final scrollController = useScrollController();

    useEffect(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      });
      return null;
    }, [initialSnapshot]);

    ref.listen(talksStreamProvider(sessionId), (previous, next) {
      final nextList = next.requireValue;
      for (final change in nextList.docChanges) {
        if (change.oldIndex == -1) {
          animatedStateKey.value.currentState?.insertItem(
            change.newIndex,
            duration: const Duration(milliseconds: 200),
          );
        }
        if (change.newIndex == -1) {
          animatedStateKey.value.currentState?.removeItem(
            change.oldIndex,
            (context, animation) => const SizedBox.shrink(),
          );
        }
      }
    });

    return AnimatedList(
      key: animatedStateKey.value,
      controller: scrollController,
      initialItemCount: initialSnapshot.size,
      itemBuilder: (
        BuildContext context,
        int index,
        Animation<double> animation,
      ) {
        final talk = initialSnapshot.docs[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _talkTile(context, ref, talk),
        );
      },
    );
  }

  Widget _talkTile(
    BuildContext context,
    WidgetRef ref,
    QueryDocumentSnapshot<Talk> snapshot,
  ) {
    final talk = snapshot.data();
    final myProfile = ref.watch(myProfileProvider).requireValue;
    final isMine = talk.sender == myProfile.userId;
    final myContainerColor = Theme.of(context).colorScheme.primaryContainer;
    final otherContainerColor =
        Theme.of(context).colorScheme.secondaryContainer;
    const myContainerBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(30.0),
      bottomLeft: Radius.circular(30.0),
      bottomRight: Radius.circular(30.0),
    );
    const otherContainerBorderRadius = BorderRadius.only(
      topRight: Radius.circular(30.0),
      bottomLeft: Radius.circular(30.0),
      bottomRight: Radius.circular(30.0),
    );

    final Widget messageContainer = Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isMine ? myContainerColor : otherContainerColor,
        borderRadius:
            isMine ? myContainerBorderRadius : otherContainerBorderRadius,
      ),
      child: Text(talk.content, style: const TextStyle(fontSize: 16.0)),
    );

    final List<Widget> messageDetails = [
      Flexible(flex: 7, child: messageContainer),
    ];

    if (isMine) {
      messageDetails.insert(0, const Spacer());
    } else {
      messageDetails.add(const Spacer());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messageDetails,
      ),
    );
  }
}
