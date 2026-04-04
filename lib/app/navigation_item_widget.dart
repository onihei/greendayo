import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class NavigationItemWidget extends Widget {
  const NavigationItemWidget(
      {super.key, required this.title, this.floatingActionButton});

  final String title;

  final Widget? floatingActionButton;
}
