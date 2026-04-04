import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greendayo/firebase_options.dart';
import 'package:greendayo/app/my_app.dart';
import 'package:greendayo/shared/web/my_url_strategy.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await runZonedGuarded<Future<void>>(
    () async {
      usePathUrlStrategy();
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exception}');
        debugPrint('${details.stack}');
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('PlatformError: $error');
        debugPrint('$stack');
        return true;
      };

      runApp(
        const ProviderScope(
          child: MyApp(),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint("Error: $error");
      debugPrint("StackTrace: $stackTrace");
    },
  );
}
