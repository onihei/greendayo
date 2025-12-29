import 'package:flutter/material.dart';
import 'package:greendayo/navigation_item_widget.dart';

class CommunityPage extends StatelessWidget implements NavigationItemWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('チーム'));
  }

  @override
  String get title => 'チーム';

  @override
  Widget? get floatingActionButton => null;
}
