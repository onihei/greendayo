import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/tab_config.dart';

class CommunityTabConfig implements TabConfig {
  @override
  String get label => 'サークル';

  @override
  Widget get icon => Icon(Icons.escalator, color: Colors.red);

  @override
  Widget get activeIcon => Icon(Icons.escalator);

  @override
  Function get factoryMethod => CommunityPage.factoryMethod;

  @override
  Widget? get floatingActionButton => null;
}

class CommunityPage extends StatelessWidget {
  static CommunityPage factoryMethod() {
    return CommunityPage();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('サークル'),
    );
  }
}
