import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class TabConfig {
  const TabConfig(
    this.label,
    this.icon,
    this.activeIcon,
    this.factoryMethod,
    this.floatingActionButton,
  );

  final String label;
  final Widget icon;
  final Widget activeIcon;
  final Function factoryMethod;
  final Widget? floatingActionButton;
}
