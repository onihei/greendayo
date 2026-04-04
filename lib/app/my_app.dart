import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/features/auth/user_provider.dart';
import 'package:greendayo/features/home/home_page.dart';
import 'package:greendayo/features/profile/profile_page.dart';
import 'package:greendayo/features/top/top_page.dart';
import 'package:greendayo/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _theme = ThemeData(
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
);

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
      darkTheme: _theme,
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

  /// ディープリンクで /profile/:id にアクセスされたが未認証だった場合に保持する
  String? _pendingDeepLinkUserId;

  MyRouterDelegate(this.ref) : navigatorKey = GlobalKey<NavigatorState>();

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final userAsync = ref.watch(userProvider);
        return userAsync.when(
          data: (user) => _buildNavigator(ref, user),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildNavigator(WidgetRef ref, firebase_auth.User? user) {
    if (user == null) {
      FlutterNativeSplash.remove();
      return Navigator(
        key: navigatorKey,
        pages: [
          MaterialPage(
            child: TopPage(userId: _pendingDeepLinkUserId),
          ),
        ],
        onDidRemovePage: (_) {},
      );
    }

    // 認証済み: ディープリンクのpending userIdがあれば反映
    if (_pendingDeepLinkUserId != null) {
      final userId = _pendingDeepLinkUserId;
      _pendingDeepLinkUserId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedUserIdProvider.notifier).select(userId);
      });
    }

    FlutterNativeSplash.remove();
    final selectedUserId = ref.watch(selectedUserIdProvider);
    return Navigator(
      key: navigatorKey,
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
  }

  @override
  Future<void> setNewRoutePath(String configuration) async {
    final pattern = RegExp(r"/profile(?:/(?=\w+))?(\w+)?$");
    final matches = pattern.allMatches(configuration);
    if (matches.isNotEmpty) {
      final userId = matches.first.group(1);
      _pendingDeepLinkUserId = userId;
      ref.read(selectedUserIdProvider.notifier).select(userId);
    } else {
      _pendingDeepLinkUserId = null;
      ref.read(selectedUserIdProvider.notifier).clear();
    }
  }

  @override
  String? get currentConfiguration {
    final userAsync = ref.read(userProvider);
    final user = userAsync.value;
    if (user == null) {
      return "/";
    }
    final selectedUserId = ref.read(selectedUserIdProvider);
    if (selectedUserId != null) {
      return "/profile/$selectedUserId";
    }
    return "/";
  }
}
