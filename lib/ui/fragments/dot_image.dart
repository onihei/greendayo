import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DotImage extends ConsumerWidget {
  const DotImage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, ref) {
    final screenSize = MediaQuery.of(context).size;
    final dotPattern = ref.watch(dotPatternProvider);
    return dotPattern.when(
      data: (data) => CustomPaint(
        painter: _DotPainter(data, screenSize),
        child: child,
      ),
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => const SizedBox.shrink(),
    );
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter(this.dotPattern, this.screenSize);

  final ui.Image dotPattern;
  final ui.Size screenSize;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    paintImage(
        canvas: canvas,
        rect: rect,
        image: dotPattern,
        repeat: ImageRepeat.repeat);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

final dotPatternProvider = FutureProvider((ref) async {
  final paint = Paint()..color = const ui.Color.fromARGB(100, 0, 0, 0);

  final pictureRecorder = ui.PictureRecorder();
  Canvas patternCanvas = Canvas(pictureRecorder);

  for (var y = 0; y < 32; y++) {
    for (var x = 0; x < 32; x++) {
      patternCanvas.drawOval(
        Rect.fromCenter(
            center: Offset(x * 6 + 3, y * 6 + 3), width: 4.5, height: 4.5),
        paint,
      );
    }
  }
  ui.Picture p = pictureRecorder.endRecording();
  return p.toImage(192, 192);
});
