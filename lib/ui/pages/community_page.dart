import 'package:flutter/material.dart';
import 'package:greendayo/tab_config.dart';

class CommunityTabConfig implements TabConfig {
  @override
  String get label => 'ファミリー';

  @override
  Widget get icon => Icon(Icons.hive_outlined);

  @override
  Widget get activeIcon => Icon(Icons.hive);

  @override
  Function get factoryMethod => CommunityPage.new;

  @override
  Widget? get floatingActionButton => null;
}

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('チーム'));
  }
}
