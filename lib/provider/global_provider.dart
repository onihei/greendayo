import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final textEditingControllerProvider = Provider.autoDispose
    .family<TextEditingController, String>((ref, key) {
      final controller = TextEditingController();
      ref.onDispose(() {
        controller.dispose();
      });
      return controller;
    });

final snackBarController = Provider.autoDispose<ScaffoldMessengerState?>((ref) {
  final context = ref.watch(globalKeyProvider("Scaffold")).currentContext;
  if (context != null) {
    return ScaffoldMessenger.maybeOf(context);
  }
});

final globalKeyProvider = Provider.autoDispose.family<GlobalKey, String>((
  ref,
  key,
) {
  return GlobalKey();
});

final userProvider = StreamProvider<User?>((ref) async* {
  yield FirebaseAuth.instance.currentUser;
  await for (User? user in FirebaseAuth.instance.authStateChanges()) {
    yield user;
  }
});

final myProfileProvider = StreamProvider<Profile>((ref) async* {
  final current = FirebaseAuth.instance.currentUser;
  if (current != null) {
    yield await ref.read(profileRepository).get(current.uid);
  }
  await for (User? user in FirebaseAuth.instance.authStateChanges()) {
    if (user != null) {
      yield await ref.read(profileRepository).get(user.uid);
    }
  }
});

final targetUserIdProvider = StateProvider<String?>((ref) => null);
final editProfileProvider = StateProvider<bool>((ref) => false);
final newSessionProvider = StateProvider<bool>((ref) => false);
final targetSessionIdProvider = StateProvider<String?>((ref) => null);

final avatarProvider = FutureProvider.family<String, String>((ref, userId) {
  return FirebaseStorage.instance
      .ref()
      .child('users/$userId/photo')
      .getDownloadURL();
});
