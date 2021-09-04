import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greendayo/tab_config.dart';

class PokepeTabConfig implements TabConfig {
  @override
  String get label => 'ぽけぺ';

  @override
  Widget get icon => Icon(Icons.settings, color: Colors.red);

  @override
  Widget get activeIcon => Icon(Icons.settings);

  @override
  Function get factoryMethod => PokepePage.factoryMethod;

  @override
  Widget? get floatingActionButton => null;
}

class PokepePage extends StatelessWidget {
  static PokepePage factoryMethod() {
    return PokepePage();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('pokepe'),
    );
  }
}
