import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/domain/model/profile.dart';
import 'package:greendayo/navigation_item_widget.dart';
import 'package:greendayo/ui/fragments/authed_drawer.dart';
import 'package:greendayo/ui/pages/bbs/bbs_page.dart';
import 'package:greendayo/ui/pages/community_page.dart';
import 'package:greendayo/ui/pages/games_page.dart';
import 'package:greendayo/ui/pages/messenger/messenger_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_page.g.dart';

@riverpod
class AppTitle extends _$AppTitle {
  @override
  String? build() {
    return null;
  }

  void setTitle(String? title) {
    state = title;
  }
}

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    ref.watch(myProfileProvider);
    final appTitle = ref.watch(appTitleProvider);
    final scaffoldKey = useRef(GlobalKey<ScaffoldState>());
    final tabIndex = useState(0);
    final navigationItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.forum_outlined),
        activeIcon: Icon(Icons.forum),
        label: '掲示板',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.games_outlined),
        activeIcon: Icon(Icons.games),
        label: 'ゲーム',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.hive_outlined),
        activeIcon: Icon(Icons.hive),
        label: 'チーム',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.email_outlined),
        activeIcon: Icon(Icons.email),
        label: 'メッセージ',
      ),
    ];
    final tabs =
        useState<List<Widget?>>(List.filled(navigationItems.length, null));
    NavigationItemWidget getTab(int index) {
      if (tabs.value[index] == null) {
        switch (index) {
          case 0:
            tabs.value[index] = BbsPage();
            break;
          case 1:
            tabs.value[index] = GamesPage();
            break;
          case 2:
            tabs.value[index] = CommunityPage();
            break;
          case 3:
            tabs.value[index] = MessengerPage();
            break;
        }
      }
      return tabs.value[index] as NavigationItemWidget;
    }

    final tab = getTab(tabIndex.value);

    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          extendBodyBehindAppBar: false,
          key: scaffoldKey.value,
          appBar: AppBar(title: Text(appTitle ?? tab.title)),
          body: tab,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            unselectedIconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.primary,
            ),
            currentIndex: tabIndex.value,
            items: navigationItems,
            onTap: (index) => tabIndex.value = index,
          ),
          floatingActionButton: tab.floatingActionButton,
          drawer: const AuthedDrawer(),
        );
      },
    );
  }
}
