import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/provider/top_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

final _headerViewControllerProvider = Provider.autoDispose<_HeaderViewController>((ref) => _HeaderViewController(ref));

class _HeaderViewController {
  final Ref ref;

  _HeaderViewController(this.ref);

  void scrollTo(key) {
    final scrollController = ref.read(scrollControllerProvider);
    final appBarKey = ref.read(globalKeyProvider("AppBar"));
    final containerKey = ref.read(globalKeyProvider("TopPage"));
    final targetKey = ref.read(globalKeyProvider(key));
    final appBarRenderObject = appBarKey.currentContext?.findRenderObject() as RenderBox?;
    final containerRenderObject = containerKey.currentContext?.findRenderObject() as RenderBox?;
    final targetRenderObject = targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (appBarRenderObject != null && containerRenderObject != null && targetRenderObject != null) {
      final appBarHeight = appBarRenderObject.size.height;
      final position = targetRenderObject.localToGlobal(Offset.zero, ancestor: containerRenderObject).dy - appBarHeight;
      scrollController.animateTo(position, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  Future<bool> signIn(authProvider) async {
    try {
      final userCredential = await _signIn(authProvider);
      return userCredential.user != null;
    } catch (e) {
      print(e);
      // 認証を完了せずに終了した場合など
      return false;
    }
  }

  Future<UserCredential> _signIn(authProvider) async {
    if (kIsWeb) {
      return await FirebaseAuth.instance.signInWithPopup(authProvider);
    } else {
      return await FirebaseAuth.instance.signInWithProvider(authProvider);
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
    double opacity = scrollPosition < screenSize.height * 0.95 ? scrollPosition / (screenSize.height * 0.95) : 1;

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
                    child: Text(
                      'すしぺろについて',
                    ),
                  ),
                  SizedBox(width: screenSize.width / 50),
                  TextButton(
                    onPressed: () {
                      ref.read(_headerViewControllerProvider).scrollTo("Game");
                    },
                    child: Text(
                      'ゲーム',
                    ),
                  ),
                  SizedBox(width: screenSize.width / 50),
                  TextButton(
                    onPressed: () {
                      ref.read(_headerViewControllerProvider).scrollTo("Job");
                    },
                    child: Text(
                      '仕事の依頼',
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                await showDialog(context: context, builder: (context) => _loginDialog(context, ref));
              },
              child: Text(
                'ログイン',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Dialog _loginDialog(context, ref) {
    return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(width: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("他サービスIDでログイン"),
                const SizedBox(height: 16),
                SocialLoginButton(
                  buttonType: SocialLoginButtonType.twitter,
                  onPressed: () async {
                    final succeed = await ref.read(_headerViewControllerProvider).signIn(TwitterAuthProvider());
                    if (succeed) {
                      Navigator.pop(context);
                    }
                  },
                ),
                const SizedBox(height: 10),
                SocialLoginButton(
                  buttonType: SocialLoginButtonType.github,
                  onPressed: () async {
                    final succeed = await ref.read(_headerViewControllerProvider).signIn(GithubAuthProvider());
                    if (succeed) {
                      Navigator.pop(context);
                    }
                  },
                ),
                // if (kDebugMode) ...[
                ...[
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await FirebaseAuth.instance
                          .signInWithEmailAndPassword(email: "do@not.ask", password: "do@not.ask");
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.android),
                    label: Text('デバッグ用の匿名ログイン'),
                  ),
                ]
              ],
            ),
          ),
        ));
  }
}
