import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final snackBarController = Provider.autoDispose<ScaffoldMessengerState?>((ref) {
  final context = ref.watch(globalKeyProvider("Scaffold")).currentContext;
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
    if (user == null) {
      ref.read(myProfileProvider.notifier).state = Profile.anonymous();
    } else {
      final profile = await ref.read(profileRepository).createOrGet(user);
      ref.read(myProfileProvider.notifier).state = profile;
    }
    controller.sink.add(user);
  });
  return controller.stream;
});

final myProfileProvider = StateProvider<Profile>((ref) => Profile.anonymous());