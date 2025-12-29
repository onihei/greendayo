import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DotImage extends ConsumerWidget {
  const DotImage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ShaderBuilder(
      assetKey: 'shaders/dots.frag',
      (BuildContext context, FragmentShader shader, _) => CustomPaint(
        painter: _DotPainter(shader),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final FragmentShader shader;
  _DotPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, 3.0); // dot radius
    shader.setFloat(1, 8.0); // dot spacing
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
