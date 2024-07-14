import 'dart:ui';

import 'package:flutter/material.dart';

class ShowyButton extends StatefulWidget {
  final Widget? child;
  final VoidCallback? onPressed;

  const ShowyButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  State<ShowyButton> createState() => _ShowyButtonState();
}

class _ShowyButtonState extends State<ShowyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Tween<double> tween;
  late Animation<double> animation;

  @override
  void initState() {
    controller =
        AnimationController(duration: Duration(seconds: 3), vsync: this);
    tween = Tween<double>(begin: 0, end: 359);
    animation = controller.drive(tween);
    controller.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Stack(
            alignment: AlignmentDirectional.topCenter,
            children: [
              Container(
                width: 400,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.topRight,
                    colors: _generateGradientColors(animation.value),
                    stops: _generateGradientStops(),
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: const [0.4, 1],
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 392,
                    height: 96,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: FilledButton(
                      onPressed: widget.onPressed,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.black,
                        disabledForegroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        textStyle:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                      child: widget.child,
                    ),
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      width: 360,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: _generateGradientColors(animation.value),
                          stops: _generateGradientStops(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  List<Color> _generateGradientColors(double offset) {
    // Generate colors with hue changing gradually
    List<Color> colors = [];
    final int divisions = 10; // Number of color divisions
    for (int i = 0; i < divisions; i++) {
      double hue = (360 / divisions) * i;
      hue += offset;
      if (hue > 360) {
        hue -= 360;
      }
      final Color color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
      colors.add(color);
    }
    // Add the first color again to complete the loop
    colors.add(colors[0]);
    return colors;
  }

  List<double> _generateGradientStops() {
    // Generate gradient stops
    final int divisions = 10; // Number of color divisions
    List<double> stops = [];
    for (int i = 0; i <= divisions; i++) {
      stops.add(i / divisions);
    }
    return stops;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
