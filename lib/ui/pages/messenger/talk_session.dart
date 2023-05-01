import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/talk.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/talks_provider.dart';
import 'package:greendayo/usecase/talk_use_case.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 現在のセッション
/// メッセージ画面では引数のsessionIdを設定
/// 新規セッション画面では最初はnull. 会話開始後に設定
/// メッセージ -> プロフィール -> 新規セッションの順で表示すると同じプロバイダを参照することになるので
/// userId毎に状態を持てるようにしている。
/// メッセージ画面では userId は null, 新規セッションでは 送信先のuserIdとなる
final _currentSessionIdProvider = StateProvider.autoDispose.family<String?, String?>((ref, userId) => null);

class _FormNotifier extends StateNotifier<TalkForm> {
  _FormNotifier() : super(TalkForm(text: ""));

  void changeText(String text) {
    state = state.copyWith(text: text);
  }

  void clear() {
    state = TalkForm(text: "");
  }
}

final _formProvider = StateNotifierProvider.autoDispose<_FormNotifier, TalkForm>((ref) {
  return _FormNotifier();
});

class TalkForm {
  const TalkForm({required this.text});

  final String text;

  TalkForm copyWith({String? text}) {
    return TalkForm(
      text: text ?? this.text,
    );
  }
}

final _talkSessionViewControllerProvider =
    Provider.autoDispose<_TalkSessionViewController>((ref) => _TalkSessionViewController(ref));

class _TalkSessionViewController {
  final Ref ref;

  _TalkSessionViewController(this.ref);

  Future<void> post({String? destinationUserId}) async {
    final text = ref.read(_formProvider).text;
    if (text.trim().isEmpty) {
      ref.read(snackBarController)?.showSnackBar(
            SnackBar(
              content: Text('空です'),
              duration: const Duration(seconds: 3),
            ),
          );
      return;
    }
    final currentSessionId = ref.read(_currentSessionIdProvider(destinationUserId));
    if (currentSessionId != null) {
      await ref.read(talkUseCase).createTalk(sessionId: currentSessionId, text: text);
    } else if (destinationUserId != null) {
      final newSessionId = await ref.read(talkUseCase).createSession(userId: destinationUserId, text: text);
      ref.read(_currentSessionIdProvider(destinationUserId).notifier).state = newSessionId;
    }
    ref.read(_formProvider.notifier).clear();
  }
}

class TalkSession extends ConsumerWidget {
  const TalkSession._({super.key, this.userId, this.sessionId});

  final String? userId;
  final String? sessionId;

  bool formNeeded() => userId != null || sessionId != null;

  factory TalkSession.createNew(String userId, {key}) {
    return TalkSession._(
      key: key,
      userId: userId,
    );
  }

  factory TalkSession.loaded(String sessionId, {key}) {
    return TalkSession._(
      key: key,
      sessionId: sessionId,
    );
  }

  @override
  Widget build(context, ref) {
    Future.microtask(() {
      ref.read(_currentSessionIdProvider(userId).notifier).state = sessionId;
    });
    return ProviderScope(
      child: Consumer(builder: (context, ref, child) {
        return Column(
          children: [
            Expanded(
              child: _talkList(context, ref),
            ),
            _form(context, ref),
          ],
        );
      }),
    );
  }

  Widget _talkList(BuildContext context, WidgetRef ref) {
    final currentSessionId = ref.watch(_currentSessionIdProvider(userId));

    if (currentSessionId == null) {
      return SizedBox.shrink();
    }
    final talks = ref.watch(talksStreamProvider(currentSessionId));
    return talks.maybeWhen(
        data: (value) => _talkListContent(context, ref, value),
        orElse: () => SizedBox.shrink(),
        error: (error, stackTrace) => Center(
              child: SelectableText('error ${error}'),
            ));
  }

  Widget _talkListContent(BuildContext context, WidgetRef ref, QuerySnapshot<Talk> snapshot) {
    final animatedStateKey = GlobalKey<AnimatedListState>();

    final scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 200), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200), curve: Curves.ease);
        }
      });
    });
    return Consumer(builder: (context, ref, _) {
      final currentSessionId = ref.watch(_currentSessionIdProvider(userId));
      ref.listen(talksStreamProvider(currentSessionId!), (previous, next) async {
        final nextList = next.requireValue;
        for (final change in nextList.docChanges) {
          if (change.oldIndex == -1) {
            animatedStateKey.currentState?.insertItem(change.newIndex, duration: Duration(milliseconds: 200));
          }
          if (change.newIndex == -1) {
            animatedStateKey.currentState?.removeItem(change.oldIndex, (context, animation) => SizedBox.shrink());
          }
        }
      });

      return AnimatedList(
        key: animatedStateKey,
        controller: scrollController,
        initialItemCount: snapshot.size,
        itemBuilder: (BuildContext context, int index, Animation<double> animation) {
          final talk = snapshot.docs[index];
          return SizeTransition(
            sizeFactor: animation,
            child: _talkTile(context, ref, talk),
          );
        },
      );
    });
  }

  Widget _talkTile(BuildContext context, WidgetRef ref, QueryDocumentSnapshot<Talk> snapshot) {
    final talk = snapshot.data();
    final myProfile = ref.watch(myProfileProvider);
    final isMine = talk.sender == myProfile.userId;
    final myContainerColor = Theme.of(context).colorScheme.primaryContainer;
    final otherContainerColor = Theme.of(context).colorScheme.secondaryContainer;
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
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isMine ? myContainerColor : otherContainerColor,
        borderRadius: isMine ? myContainerBorderRadius : otherContainerBorderRadius,
      ),
      child: Text(
        talk.content,
        style: TextStyle(fontSize: 16.0),
      ),
    );

    final List<Widget> messageDetails = [
      Flexible(flex: 7, child: messageContainer),
    ];

    if (isMine) {
      messageDetails.insert(0, Spacer());
    } else {
      messageDetails.add(Spacer());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: messageDetails,
      ),
    );
  }

  Widget _form(BuildContext context, WidgetRef ref) {
    final form = ref.watch(_formProvider);
    final controller = ref.watch(textEditingControllerProvider("TalkForm"));
    Future.microtask(() {
      controller.value = controller.value.copyWith(text: form.text);
    });
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
                onChanged: (input) {
                  ref.read(_formProvider.notifier).changeText(input);
                },
                textInputAction: TextInputAction.send,
              ),
            ),
            IconButton(
                onPressed: () {
                  ref.read(_talkSessionViewControllerProvider).post(destinationUserId: userId);
                },
                icon: Icon(Icons.send)),
          ],
        ),
      ),
    );
  }
}
