import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/features/auth/user_provider.dart';
import 'package:greendayo/features/bbs/article.dart';
import 'package:greendayo/features/bbs/article_providers.dart';
import 'package:greendayo/features/bbs/bbs_controller.dart';
import 'package:greendayo/features/bbs/bbs_form.dart';
import 'package:greendayo/shared/ui/article_photo.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BbsBoard extends HookConsumerWidget {
  const BbsBoard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(articlesStreamProvider).requireValue;
    final papers = snapshot.docs.map((articleDoc) {
      final article = articleDoc.data();
      return Consumer(builder: (context, ref, child) {
        final screenOffset = ref.watch(bbsOffsetProvider);
        return Positioned(
          left: screenOffset.dx + article.left.toDouble(),
          top: screenOffset.dy + article.top.toDouble(),
          child: _ArticleCard(snapshot: articleDoc),
        );
      });
    }).toList();
    final panStarted = useRef<Offset?>(null);
    final scaleStarted = useRef<double>(1.0);
    return GestureDetector(
      onScaleStart: (detail) {
        panStarted.value = ref.read(bbsOffsetProvider);
        scaleStarted.value = ref.read(bbsScaleProvider);
      },
      onScaleUpdate: (details) {
        final panStartedValue = panStarted.value;
        if (panStartedValue == null) {
          return;
        }
        if (details.pointerCount == 1) {
          final offset = ref.read(bbsOffsetProvider);
          ref.read(bbsOffsetProvider.notifier).setOffset(offset.translate(
                details.focalPointDelta.dx / scaleStarted.value,
                details.focalPointDelta.dy / scaleStarted.value,
              ));
        } else {
          final newScale = scaleStarted.value * details.scale;
          ref.read(bbsOffsetProvider.notifier).setOffset(panStartedValue);
          ref.read(bbsScaleProvider.notifier).setScale(newScale);
        }
      },
      onScaleEnd: (details) {
        panStarted.value = null;
        ref.read(bbsFormProvider.notifier).shake();
      },
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Consumer(builder: (context, ref, child) {
          final scale = ref.watch(bbsScaleProvider);
          return Transform.scale(
            scale: scale,
            child: Stack(clipBehavior: Clip.none, children: papers),
          );
        }),
      ),
    );
  }
}

class _ArticleCard extends ConsumerWidget {
  final QueryDocumentSnapshot<Article> snapshot;

  const _ArticleCard({required this.snapshot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(bbsControllerProvider);
    final article = snapshot.data();
    return PopupMenuButton<String>(
      position: PopupMenuPosition.under,
      onSelected: (s) async {
        if (s == "profile") {
          vc.showProfile(article.createdBy);
        }
        if (s == "delete") {
          await vc.deleteArticle(context, docId: snapshot.id);
        }
      },
      itemBuilder: (BuildContext context) {
        final user = ref.read(userProvider).value;
        return [
          const PopupMenuItem(value: "profile", child: Text("プロフィールを見る")),
          if (user != null)
            const PopupMenuItem(value: "delete", child: Text("削除する")),
        ];
      },
      child: article.isPhoto
          ? _photoContent(context, article)
          : _textContent(context, article),
    );
  }

  Widget _photoContent(BuildContext context, Article article) {
    final content = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      width: article.width.toDouble(),
      height: article.width.toDouble() + 16,
      decoration: photoBoxDecoration(context),
      child: ArticlePhoto(article: article),
    );
    final rotation = article.rotation ?? 0;
    return Transform.rotate(angle: rotation, child: content);
  }

  Widget _textContent(BuildContext context, Article article) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: article.width.toDouble(),
      decoration: textBoxDecoration(
        context,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.content),
          Row(children: [const Spacer(), Text(article.signature)]),
        ],
      ),
    );
  }
}
