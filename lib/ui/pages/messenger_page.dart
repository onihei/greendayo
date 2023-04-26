import 'package:flutter/material.dart';
import 'package:greendayo/tab_config.dart';

class MessengerTabConfig implements TabConfig {
  @override
  String get label => 'メッセージ';

  @override
  Widget get icon => Icon(Icons.email_outlined);

  @override
  Widget get activeIcon => Icon(Icons.email);

  @override
  Function get factoryMethod => MessengerPage.new;

  @override
  Widget? get floatingActionButton => null;
}

class MessengerPage extends StatelessWidget {
  const MessengerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('メッセージ'),
    );
  }
}
