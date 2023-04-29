import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:greendayo/fragments/authed_drawer.dart';
import 'package:greendayo/fragments/header.dart';
import 'package:greendayo/provider/global_provider.dart';
import 'package:greendayo/ui/pages/bbs_page.dart';
import 'package:greendayo/ui/pages/community_page.dart';
import 'package:greendayo/ui/pages/games_page.dart';
import 'package:greendayo/ui/pages/messenger_page.dart';
import 'package:greendayo/ui/pages/profile_edit_page.dart';
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
  final tab = tabBodies[tabIndex] = tabBodies[tabIndex] ?? Function.apply(_tabConfigs[tabIndex].factoryMethod, null);
  return tab;
});

final _myAppViewController = Provider.autoDispose<_MyAppViewController>((ref) => _MyAppViewController(ref));

class _MyAppViewController {
  final Ref ref;

  _MyAppViewController(this.ref);

  void changeTab(index) {
    ref.read(_tabIndexProvider.notifier).state = index;
  }
}

class MyApp extends HookConsumerWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'すしぺろ',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueGrey,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      onGenerateRoute: (settings) => generateRoute(context, settings),
      routes: <String, WidgetBuilder>{
        "/": (_) => _home(),
        "/profileEdit": (_) => ProfileEditPage(),
      },
    );
  }

  Route<dynamic>? generateRoute(context, RouteSettings settings) {
    final path = settings.name ?? "";
    if (path.startsWith("/profile")) {
      if (settings.arguments is String) {
        return MaterialPageRoute(
          builder: (_) {
            return ProfilePage(userId: settings.arguments as String);
          },
          // 引数オブジェクトが渡された場合は、リロードできるようにパスパラメータにして移動
          settings: RouteSettings(name: "/profile/${settings.arguments}"),
        );
      }
      final uri = Uri(path: path);
      if (uri.pathSegments.length != 2) {
        return null;
      }
      // パスパラメータで遷移された場合（ディープリンクなど）
      final userId = uri.pathSegments[1];
      return MaterialPageRoute(
        builder: (_) {
          return ProfilePage(userId: userId);
        },
        settings: settings,
      );
    }
    throw Exception('Route not found');
  }

  Widget _home() {
    return Consumer(builder: (context, ref, child) {
      final user = ref.watch(userProvider);

      final tabIndex = ref.watch(_tabIndexProvider);
      final tab = ref.watch(_tabProvider);
      final scaffoldKey = ref.watch(globalKeyProvider("Scaffold"));
      final authed = user.value != null;
      if (authed) {
        FlutterNativeSplash.remove();
      }
      final appBar = authed
          ? AppBar(
              title: Text(_tabConfigs[tabIndex].label),
            )
          : PreferredSize(
              preferredSize: Size(1000, 200),
              child: Header(),
            );

      final navigationItems = _tabConfigs
          .map((param) => BottomNavigationBarItem(
                icon: param.icon,
                activeIcon: param.activeIcon,
                label: param.label,
              ))
          .toList();

      final bottomNavigationBar = authed
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(
                color: Theme.of(context).colorScheme.primary,
              ),
              currentIndex: tabIndex,
              items: navigationItems,
              onTap: (index) => ref.read(_myAppViewController).changeTab(index),
            )
          : null;

      final floatingActionButton = authed ? _tabConfigs[tabIndex].floatingActionButton : null;
      final drawer = authed ? AuthedDrawer() : null;

      return Scaffold(
        extendBodyBehindAppBar: authed ? false : true,
        key: scaffoldKey,
        appBar: appBar,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: authed ? tab : TopPage(),
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        drawer: drawer,
      );
    });
  }
}
