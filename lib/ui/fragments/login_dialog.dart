import 'package:authentication_buttons/authentication_buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginDialog extends Dialog {
  const LoginDialog({super.key});

  @override
  Widget build(context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 24.0,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints.tightFor(width: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("他サービスIDでログイン"),
              const SizedBox(height: 16),
              AuthenticationButton(
                authenticationMethod: AuthenticationMethod.twitter,
                onPressed: () async {
                  final succeed = await signIn(TwitterAuthProvider());
                  if (succeed) {
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 10),
              AuthenticationButton(
                authenticationMethod: AuthenticationMethod.github,
                onPressed: () async {
                  final succeed = await signIn(GithubAuthProvider());
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
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: "do@not.ask",
                      password: "do@not.ask",
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.android),
                  label: const Text('テリーマンとしてログイン'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
