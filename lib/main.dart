import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greendayo/firebase_options.dart';
import 'package:greendayo/my_app.dart';
import 'package:greendayo/web/my_url_strategy.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runZonedGuarded<Future<void>>(
    () async {
      usePathUrlStrategy();
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      // 動画の準備が完了するまで表示
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stackTrace) {
      print("Error: $error");
      print("StackTrace: $stackTrace");
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}
