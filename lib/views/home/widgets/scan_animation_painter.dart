import 'package:flutter/material.dart';
import 'dart:math' as math;

class ScanCustomPainter extends CustomPainter {
  final int circles;
  final AnimationController _animationController;
  final Color scanColor;
  //position to place the middle of the circle in the animation
  final double setPosition;

  ScanCustomPainter(
    this._animationController, {
    this.circles = 20,
    this.setPosition = 0.0,
    required this.scanColor,
  });
  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.width / 2;
    final dy = size.height - setPosition;

    final offset = Offset(dx, dy);
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = Colors.white.withOpacity(1 - _animationController.value);

    for (var i = 0; i < circles; i++) {
      final double opacity =
          (1.0 - ((_animationController.value + i) / 4.0)).clamp(0.0, 1.0);
      paint.color = scanColor.withOpacity(opacity);
      canvas.drawCircle(
          offset,
          math.sqrt((dx * dx) / 2 * (_animationController.value + i) / 2),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
