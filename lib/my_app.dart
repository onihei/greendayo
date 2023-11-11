import 'dart:html' as html;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/ui/fragments/authed_drawer.dart';
import 'package:greendayo/ui/fragments/header.dart';
import 'package:greendayo/ui/pages/bbs_page.dart';
import 'package:greendayo/ui/pages/community_page.dart';
import 'package:greendayo/ui/pages/games_page.dart';
import 'package:greendayo/ui/pages/messenger/messenger_page.dart';
import 'package:greendayo/ui/pages/messenger/new_session_page.dart';
import 'package:greendayo/ui/pages/messenger/session_page.dart';
import 'package:greendayo/ui/pages/profile_page.dart';
import 'package:greendayo/ui/pages/top_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _tabConfigs = [
  BbsTabConfig(),
  GamesTabConfig(),
  MessengerTabConfig(),
  CommunityTabConfig(),
];

final _tabIndexProvider = StateProvider<int>((ref) => 0);
final _tabBodiesProvider = Provider<Map<int, Widget?>>((ref) => {});
final _tabProvider = Provider<Widget>((ref) {
  final tabIndex = ref.watch(_tabIndexProvider);
  final tabBodies = ref.watch(_tabBodiesProvider);
  final tab = tabBodies[tabIndex] = tabBodies[tabIndex] ??
      Function.apply(_tabConfigs[tabIndex].factoryMethod, null);
  return tab;
});

final _viewControllerProvider =
    Provider.autoDispose<_ViewController>((ref) => _ViewController(ref));

class _ViewController {
  final Ref ref;

  _ViewController(this.ref);

  void changeTab(index) {
    ref.read(_tabIndexProvider.notifier).state = index;
  }
}

class MyApp extends HookConsumerWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja'),
      ],
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
      RouteInformation routeInformation) async {
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
    return Consumer(builder: (context, ref, child) {
      final user = ref.watch(userProvider);
      final myProfile = ref.watch(myProfileProvider);
      final targetUserId = ref.watch(targetUserIdProvider);
      final newSession = ref.watch(newSessionProvider);
      final targetSessionId = ref.watch(targetSessionIdProvider);
      return Navigator(
        pages: [
          MaterialPage(
            child: user.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (user) {
                if (user == null) {
                  FlutterNativeSplash.remove();
                  return _top();
                }
                return myProfile.maybeWhen(
                  loading: () => const SizedBox.shrink(),
                  orElse: () {
                    return _top();
                  },
                  data: (_) {
                    FlutterNativeSplash.remove();
                    return _home();
                  },
                );
              },
            ),
          ),
          if (targetUserId != null)
            MaterialPage(
              name: "profile",
              child: ProfilePage(
                userId: targetUserId,
              ),
            ),
          if (newSession && targetUserId != null)
            MaterialPage(
              name: "newSession",
              child: NewSessionPage(
                userId: targetUserId,
              ),
            ),
          if (targetSessionId != null)
            MaterialPage(
              name: "session",
              child: SessionPage(
                sessionId: targetSessionId,
              ),
            ),
        ],
        onPopPage: (route, result) {
          if (route.settings.name == "profile") {
            if (kIsWeb) {
              html.window.history.back();
            }
            ref.read(targetUserIdProvider.notifier).state = null;
          }
          if (route.settings.name == "newSession") {
            if (kIsWeb) {
              html.window.history.back();
            }
            ref.read(newSessionProvider.notifier).state = false;
          }
          if (route.settings.name == "session") {
            if (kIsWeb) {
//              html.window.history.back();
            }
            ref.read(targetSessionIdProvider.notifier).state = null;
          }
          return route.didPop(result);
        },
      );
    });
  }

  Widget _top() {
    return const Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(1000, 200),
        child: Header(),
      ),
      body: TopPage(),
    );
  }

  Widget _home() {
    return Consumer(builder: (context, ref, child) {
      final tabIndex = ref.watch(_tabIndexProvider);
      final tab = ref.watch(_tabProvider);
      final scaffoldKey = ref.watch(globalKeyProvider("Scaffold"));

      final navigationItems = _tabConfigs
          .map((param) => BottomNavigationBarItem(
                icon: param.icon,
                activeIcon: param.activeIcon,
                label: param.label,
              ))
          .toList();

      return Scaffold(
        extendBodyBehindAppBar: false,
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(_tabConfigs[tabIndex].label),
        ),
        body: tab,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
          ),
          unselectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
          ),
          currentIndex: tabIndex,
          items: navigationItems,
          onTap: (index) => ref.read(_viewControllerProvider).changeTab(index),
        ),
        floatingActionButton: _tabConfigs[tabIndex].floatingActionButton,
        drawer: const AuthedDrawer(),
      );
    });
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    final pattern =
        RegExp("/profile(?:/(?=\\w+))?(\\w+)?(/new-session|/edit)?\$");
    final matches = pattern.allMatches(configuration);
    if (matches.isNotEmpty) {
      final userId = matches.first.group(1);
      ref.read(targetUserIdProvider.notifier).state = userId;
      final group2 = matches.first.group(2);
      final newSession = group2 == "/new-session";
      final edit = group2 == "/edit";
      final myUser = await ref.read(userProvider.future);
      if (edit && myUser?.uid == userId) {
        ref.read(editProfileProvider.notifier).state = true;
      } else {
        ref.read(editProfileProvider.notifier).state = false;
      }
      ref.read(newSessionProvider.notifier).state = false;
      if (newSession && myUser?.uid != userId) {
        ref.read(newSessionProvider.notifier).state = true;
      }
    } else {
      ref.read(targetUserIdProvider.notifier).state = null;
    }
  }

  @override
  String? get currentConfiguration {
    final targetUserId = ref.watch(targetUserIdProvider);
    final editProfile = ref.watch(editProfileProvider);
    final newSession = ref.watch(newSessionProvider);
    if (targetUserId != null) {
      var func = "";
      if (editProfile) {
        func = "/edit";
      }
      if (newSession) {
        func = "/new-session";
      }
      return "/profile/$targetUserId$func";
    }
    return "/";
  }
}
