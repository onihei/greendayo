import 'package:flutter/material.dart';
import 'package:greendayo/navigation_item_widget.dart';

class GamesPage extends StatelessWidget implements NavigationItemWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 400),
      ),
    );
  }

  @override
  String get title => 'ゲーム';

  @override
  Widget? get floatingActionButton => null;
}
