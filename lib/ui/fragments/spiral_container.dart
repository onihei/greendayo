import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class SpiralContainer extends StatefulWidget {
  const SpiralContainer({super.key});

  @override
  State<SpiralContainer> createState() => _SpiralContainerState();
}

class _SpiralContainerState extends State<SpiralContainer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  Duration _currentTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      setState(() {
        _currentTime = elapsed;
      });
    });
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      assetKey: 'shaders/spiral.frag',
      (BuildContext context, FragmentShader shader, _) => CustomPaint(
        size: MediaQuery.of(context).size,
        painter: FlipShaderPainter(shader, _currentTime),
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

class FlipShaderPainter extends CustomPainter {
  final FragmentShader shader;
  final Duration currentTime;

  FlipShaderPainter(
    this.shader,
    this.currentTime,
  );

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, currentTime.inMilliseconds.toDouble() / 1000);
    final Paint paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
