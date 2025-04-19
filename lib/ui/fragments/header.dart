import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/top_provider.dart';
import 'package:greendayo/ui/fragments/login_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _headerViewControllerProvider =
    Provider.autoDispose<_HeaderViewController>(
      (ref) => _HeaderViewController(ref),
    );

class _HeaderViewController {
  final Ref ref;

  _HeaderViewController(this.ref);

  void scrollTo(key) {
    final scrollController = ref.read(scrollControllerProvider);
    final appBarKey = ref.read(globalKeyProvider("AppBar"));
    final containerKey = ref.read(globalKeyProvider("TopPage"));
    final targetKey = ref.read(globalKeyProvider(key));
    final appBarRenderObject =
        appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final containerRenderObject =
        containerKey.currentContext?.findRenderObject() as RenderBox?;
    final targetRenderObject =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (appBarRenderObject != null &&
        containerRenderObject != null &&
        targetRenderObject != null) {
      final appBarHeight = appBarRenderObject.size.height;
      final position =
          targetRenderObject
              .localToGlobal(Offset.zero, ancestor: containerRenderObject)
              .dy -
          appBarHeight;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}

class Header extends HookConsumerWidget {
  const Header({super.key});

  @override
  Widget build(context, ref) {
    final screenSize = MediaQuery.of(context).size;
    final globalKey = ref.watch(globalKeyProvider("AppBar"));
    final scrollPosition = ref.watch(scrollPositionProvider) + 200;
    double opacity =
        scrollPosition < screenSize.height * 0.95
            ? scrollPosition / (screenSize.height * 0.95)
            : 1;

    return Container(
      key: globalKey,
      color: Theme.of(context).primaryColor.withOpacity(opacity),
      child: Padding(
        padding: EdgeInsets.all(screenSize.width / 70),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      ref.read(_headerViewControllerProvider).scrollTo("About");
                    },
                    child: const Text('すしぺろについて'),
                  ),
                  SizedBox(width: screenSize.width / 50),
                  TextButton(
                    onPressed: () {
                      ref.read(_headerViewControllerProvider).scrollTo("Game");
                    },
                    child: const Text('ゲーム'),
                  ),
                  SizedBox(width: screenSize.width / 50),
                  TextButton(
                    onPressed: () {
                      ref.read(_headerViewControllerProvider).scrollTo("Job");
                    },
                    child: const Text('仕事の依頼'),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (context) => LoginDialog(),
                );
              },
              child: const Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
