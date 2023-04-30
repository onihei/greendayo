import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/entity/profile.dart';
import 'package:greendayo/repository/profile_repository.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rxdart/rxdart.dart';

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
    Future(() async {
      subject.sink.add(await ref.read(profileRepository).get(uid));
    });
  }
  return subject;
});

final myProfileProvider = Provider<Profile>((ref) {
  final behaviorSubject = ref.watch(myProfileSubjectProvider);
  behaviorSubject.doOnData((newProfileState) {
    ref.invalidateSelf();
  });
  return behaviorSubject.value;
});

final avatarProvider = FutureProvider.family<Uint8List, String>((ref, userId) {
  // fixme: ディスクキャッシュに変える
  return FirebaseStorage.instance.ref().child('users/${userId}/photo').getData().then((value) => value!);
});
