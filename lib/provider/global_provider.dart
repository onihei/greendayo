import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final textEditingControllerProvider = Provider.autoDispose.family<TextEditingController, String>((ref, key) {
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

final globalKeyProvider = Provider.autoDispose.family<GlobalKey, String>((ref, key) {
  return GlobalKey();
});

final userProvider = StreamProvider<User?>((ref) {
  final controller = StreamController<User?>();
  controller.sink.add(FirebaseAuth.instance.currentUser);
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      final profile = await ref.read(profileRepository).createOrGet(user);
      ref.read(myProfileSubjectProvider).sink.add(profile);
    } else {
      ref.read(myProfileSubjectProvider).sink.add(Profile.anonymous());
    }
    controller.sink.add(user);
  });
  return controller.stream;
});

final myProfileSubjectProvider = Provider<BehaviorSubject<Profile>>((ref) {
  final subject = BehaviorSubject.seeded(Profile.anonymous());
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    ref.read(profileRepository).observe(uid).map((event) => event.data() ?? Profile.anonymous()).listen((event) {
      subject.sink.add(event);
    });
  }
  ref.onDispose(() async {
    await subject.drain();
    await subject.close();
  });
  return subject;
});

final myProfileProvider = Provider.autoDispose<Profile>((ref) {
  final behaviorSubject = ref.watch(myProfileSubjectProvider);
  behaviorSubject.listen((newProfileState) {
    ref.invalidateSelf();
  });
  return behaviorSubject.value;
});

final avatarProvider = FutureProvider.family<String, String>((ref, userId) {
  return FirebaseStorage.instance.ref().child('users/$userId/photo').getDownloadURL();
});
