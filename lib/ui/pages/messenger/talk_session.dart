import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/domain/model/talk.dart';
import 'package:greendayo/domain/usecase/talk_use_case.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/ui/utils/snackbars.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'talk_session.g.dart';

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
        ref,
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
}

class TalkSession extends HookConsumerWidget {
  const TalkSession({super.key, this.userId, this.sessionId});

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
    final animatedStateKey = GlobalKey<AnimatedListState>();

    final scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      });
    });
    return Consumer(
      builder: (context, ref, _) {
        ref.listen(talksStreamProvider(sessionId), (
          previous,
          next,
        ) async {
          final nextList = next.requireValue;
          for (final change in nextList.docChanges) {
            if (change.oldIndex == -1) {
              animatedStateKey.currentState?.insertItem(
                change.newIndex,
                duration: const Duration(milliseconds: 200),
              );
            }
            if (change.newIndex == -1) {
              animatedStateKey.currentState?.removeItem(
                change.oldIndex,
                (context, animation) => const SizedBox.shrink(),
              );
            }
          }
        });

        return AnimatedList(
          key: animatedStateKey,
          controller: scrollController,
          initialItemCount: snapshot.size,
          itemBuilder: (
            BuildContext context,
            int index,
            Animation<double> animation,
          ) {
            final talk = snapshot.docs[index];
            return SizeTransition(
              sizeFactor: animation,
              child: _talkTile(context, ref, talk),
            );
          },
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

  Widget _form(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<String?> currentSessionId,
  ) {
    final vc = ref.watch(_viewControllerProvider);
    final controller = useTextEditingController();
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
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
