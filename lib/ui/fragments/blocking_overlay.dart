import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'blocking_overlay.g.dart';

@riverpod
class Blocking extends _$Blocking {
  @override
  bool build() => false;

  Future<void> blockWhile({
    required AsyncCallback operation,
    AsyncValueSetter<Exception>? onError,
  }) async {
    state = true;
    try {
      await operation();
    } on Exception catch (e) {
      if (onError != null) {
        await onError(e);
        return;
      }
      rethrow;
    } finally {
      state = false;
    }
  }

  void reset() {
    state = false;
  }
}

class BlockingOverlay extends ConsumerWidget {
  const BlockingOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocking = ref.watch(blockingProvider);
    return PopScope(
      canPop: !blocking,
      child: Stack(
        children: [
          child,
          if (blocking) ...[
            Positioned.fill(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.26),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
