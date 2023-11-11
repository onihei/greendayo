import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final scrollPositionProvider = StateProvider<double>((ref) => 0);

final scrollControllerProvider = Provider.autoDispose<ScrollController>((ref) {
  final controller = ScrollController();
  controller.addListener(() {
    ref.read(scrollPositionProvider.notifier).state =
        controller.position.pixels;
  });
  ref.onDispose(() => controller.dispose());
  return controller;
});
