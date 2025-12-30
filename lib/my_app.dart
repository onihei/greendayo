import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/domain/model/user.dart';
import 'package:greendayo/l10n/app_localizations.dart';
import 'package:greendayo/ui/pages/home/home_page.dart';
import 'package:greendayo/ui/pages/profile/profile_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MyApp extends HookConsumerWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('ja')],
      title: 'すしぺろ',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
        textTheme: const TextTheme(
          titleSmall: TextStyle(fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontWeight: FontWeight.w700),
          headlineSmall: TextStyle(fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(fontWeight: FontWeight.w700),
          labelSmall: TextStyle(fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      routeInformationParser: MyRouteInformationParser(),
      routerDelegate: MyRouterDelegate(ref),
    );
  }
}

class MyRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    return routeInformation.uri.toString();
  }

  @override
  RouteInformation? restoreRouteInformation(String configuration) {
    return RouteInformation(uri: Uri.parse(configuration));
  }
}

class MyRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  final WidgetRef ref;

  MyRouterDelegate(this.ref) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedUserId = ref.watch(selectedUserIdProvider);
        return Navigator(
          pages: [
            MaterialPage(
              child: HomePage(),
            ),
            if (selectedUserId != null)
              MaterialPage(
                name: "profile",
                child: ProfilePage(userId: selectedUserId),
              ),
          ],
          onDidRemovePage: (page) {
            if (page.name == "profile") {
              ref.read(selectedUserIdProvider.notifier).clear();
            }
          },
        );
      },
    );
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    final pattern = RegExp(
      r"/profile(?:/(?=\w+))?(\w+)?$",
    );
    final matches = pattern.allMatches(configuration);
    if (matches.isNotEmpty) {
      final userId = matches.first.group(1);
      ref.read(selectedUserIdProvider.notifier).select(userId);
    } else {
      ref.read(selectedUserIdProvider.notifier).clear();
    }
  }

  @override
  String? get currentConfiguration {
    final selectedUserId = ref.watch(selectedUserIdProvider);
    if (selectedUserId != null) {
      return "/profile/$selectedUserId";
    }
    return "/";
  }
}
