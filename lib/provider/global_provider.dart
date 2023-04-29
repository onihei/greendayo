import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final snackBarController = Provider.autoDispose<ScaffoldMessengerState?>((ref) {
  final context = ref
      .watch(globalKeyProvider("Scaffold"))
      .currentContext;
  if (context != null) {
    return ScaffoldMessenger.maybeOf(context);
  }
});

final globalKeyProvider = Provider.autoDispose.family<GlobalKey, String>((ref, key) {
  return GlobalKey();
});

final userProvider = StreamProvider<User?>((ref) {
  final controller = StreamController<User?>();
  controller.sink.add(FirebaseAuth.instance.currentUser);
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    controller.sink.add(user);
  });
  return controller.stream;
});

StateProvider<Profile> myProfileProvider = StateProvider<Profile>((ref) {
  Future.microtask(() {
    final user = ref.watch(userProvider);
    user.when(
        data: (data) {
          if (data != null) {
            ref.read(profileRepository).createOrGet(data).then((value) {
              ref.read(myProfileProvider.notifier).state = value;
            });
          }
        },
        error: (err, _) {},
        loading: () {});
  });
  return Profile.anonymous();
});

final avatarProvider = FutureProvider.family<Uint8List, String>((ref, userId) {
  // fixme: ディスクキャッシュに変える
  return FirebaseStorage.instance.ref().child('users/${userId}/photo').getData().then((value) => value!);
});
