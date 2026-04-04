import 'package:flutter/material.dart';
import 'package:greendayo/app/navigation_item_widget.dart';
import 'package:greendayo/features/bbs/article_providers.dart';
import 'package:greendayo/features/bbs/bbs_board.dart';
import 'package:greendayo/features/bbs/bbs_controller.dart';
import 'package:greendayo/features/bbs/bbs_form.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BbsPage extends ConsumerWidget implements NavigationItemWidget {
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
    return result.maybeWhen(
      data: (value) => _buildScreen(context, ref),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildScreen(BuildContext context, WidgetRef ref) {
    final vc = ref.watch(bbsControllerProvider);
    final formEnabled = ref.watch(bbsFormEnabledProvider);
    ref.watch(bbsFormProvider);
    return Stack(
      key: vc.formContainerKey,
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        const BbsBoard(),
        if (formEnabled) ...[
          Align(
            alignment: const Alignment(0, -0.2),
            child: const BbsFormWidget(),
          ),
          const BbsEditActions(),
        ],
      ],
    );
  }
}
