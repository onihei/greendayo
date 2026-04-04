import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:greendayo/app/navigation_item_widget.dart';
import 'package:greendayo/features/bbs/article_providers.dart';
import 'package:greendayo/features/bbs/bbs_board.dart';
import 'package:greendayo/features/bbs/bbs_controller.dart';
import 'package:greendayo/features/bbs/bbs_form.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BbsPage extends HookConsumerWidget implements NavigationItemWidget {
  const BbsPage({super.key});

  @override
  String get title => '掲示板';

  @override
  Widget? get floatingActionButton => Consumer(
        builder: (context, ref, child) {
          final enabled = ref.watch(bbsFormEnabledProvider);
          final button = FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              ref.read(bbsControllerProvider).startCreate();
            },
          );
          return Visibility(visible: !enabled, child: button);
        },
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(articlesStreamProvider);
    final formContainerKey = useRef(GlobalKey());
    final formKey = useRef(GlobalKey());
    return result.maybeWhen(
      data: (value) => _buildScreen(
        context,
        ref,
        formContainerKey: formContainerKey.value,
        formKey: formKey.value,
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildScreen(
    BuildContext context,
    WidgetRef ref, {
    required GlobalKey formContainerKey,
    required GlobalKey formKey,
  }) {
    final formEnabled = ref.watch(bbsFormEnabledProvider);
    ref.watch(bbsFormProvider);
    return Stack(
      key: formContainerKey,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        const BbsBoard(),
        if (formEnabled) ...[
          Align(
            alignment: const Alignment(0, -0.2),
            child: BbsFormWidget(formKey: formKey),
          ),
          BbsEditActions(
            formContainerKey: formContainerKey,
            formKey: formKey,
          ),
        ],
      ],
    );
  }
}
