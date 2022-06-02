import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greendayo/my_app.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAABCUV2tq4jvJJfxDv_n0iTIrV8asKuvw",
          authDomain: "yamyam-ac34b.firebaseapp.com",
          projectId: "yamyam-ac34b",
          storageBucket: "yamyam-ac34b.appspot.com",
          messagingSenderId: "853677427401",
          appId: "1:853677427401:web:d51bf2dbf8ec5cd2eedb18",
          measurementId: "G-WN5GNRYG5Y"));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
