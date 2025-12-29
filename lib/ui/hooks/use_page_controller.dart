import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

PageController usePageController({
  ScrollControllerCallback? onAttach,
  ScrollControllerCallback? onDetach,
  List<Object?>? keys,
}) {
  return use(
    _PageControllerHook(
      onAttach: onAttach,
      onDetach: onDetach,
      keys: keys,
    ),
  );
}

class _PageControllerHook extends Hook<PageController> {
  const _PageControllerHook({
    this.onAttach,
    this.onDetach,
    super.keys,
  });

  final ScrollControllerCallback? onAttach;
  final ScrollControllerCallback? onDetach;

  @override
  HookState<PageController, Hook<PageController>> createState() =>
      _PageControllerHookState();
}

class _PageControllerHookState
    extends HookState<PageController, _PageControllerHook> {
  late final controller = PageController(
    onAttach: hook.onAttach,
    onDetach: hook.onDetach,
  );

  @override
  PageController build(BuildContext context) => controller;

  @override
  void dispose() => controller.dispose();

  @override
  String get debugLabel => 'usePageController';
}
