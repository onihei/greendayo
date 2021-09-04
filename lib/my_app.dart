import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greendayo/ui/pages/bbs_page.dart';
import 'package:greendayo/ui/pages/community_page.dart';
import 'package:greendayo/ui/pages/pokepe_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _tabConfigs = [
  BbsTabConfig(),
  PokepeTabConfig(),
  CommunityTabConfig(),
];

final _tabIndex = StateProvider.autoDispose<int>((ref) => 0);
final _tabs = StateProvider.autoDispose<Map<int, Widget?>>((ref) => {});
final _tab = StateProvider.autoDispose<StatelessWidget>((ref) {
  final tabIndex = ref.watch(_tabIndex).state;
  final tabs = ref.watch(_tabs).state;
  final tab = tabs[tabIndex] = tabs[tabIndex] ??
      Function.apply(_tabConfigs[tabIndex].factoryMethod, null);
  return tab;
});

final _scaffoldKeyProvider = StateProvider.autoDispose<GlobalKey?>((ref) => null);

final snackBarController =
Provider.autoDispose<ScaffoldMessengerState?>((ref) {
  final context = ref.read(_scaffoldKeyProvider).state?.currentContext;
  if (context != null) {
    return ScaffoldMessenger.maybeOf(context);
  }
});

final _myAppViewController =
    Provider.autoDispose((ref) => _MyAppViewController(ref.read));

class _MyAppViewController {
  final Reader read;

  _MyAppViewController(this.read);

  void changeTab(index) {
    read(_tabIndex).state = index;
  }
}

class MyApp extends HookWidget {
  final _keyScaffold = GlobalKey();
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    final tabIndex = useProvider(_tabIndex).state;
    final tab = useProvider(_tab).state;
    useProvider(_scaffoldKeyProvider);
    Future.microtask(() => context.read(_scaffoldKeyProvider).state = _keyScaffold);

    final navigationItems = _tabConfigs
        .map((param) => BottomNavigationBarItem(
              icon: param.icon,
              activeIcon: param.activeIcon,
              label: param.label,
            ))
        .toList();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: Scaffold(
        key: _keyScaffold,
        appBar: AppBar(title: Text(_tabConfigs[tabIndex].label)),
        body: tab,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.yellow,
          currentIndex: tabIndex,
          items: navigationItems,
          onTap: (index) => context.read(_myAppViewController).changeTab(index),
        ),
        floatingActionButton: _tabConfigs[tabIndex].floatingActionButton,
      ),
      routes: <String, WidgetBuilder>{},
    );
  }
}
