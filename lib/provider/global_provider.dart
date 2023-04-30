import 'dart:async';
import 'dart:typed_data';

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
    ref.invalidate(myProfileSubjectProvider);
    controller.sink.add(user);
  });
  return controller.stream;
});

final myProfileSubjectProvider = Provider<BehaviorSubject<Profile>>((ref) {
  final subject = BehaviorSubject.seeded(Profile.anonymous());
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid != null) {
    ref.read(profileRepository).observe(uid).asyncMap((event) => event.data() ?? Profile.anonymous()).pipe(subject);
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

final avatarProvider = FutureProvider.family<Uint8List, String>((ref, userId) {
  // fixme: ディスクキャッシュに変える
  return FirebaseStorage.instance.ref().child('users/${userId}/photo').getData().then((value) => value!);
});
