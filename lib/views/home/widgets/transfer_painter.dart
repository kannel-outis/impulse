import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class TransferPainter extends CustomPainter {
  final Color color;
  final double weight;
  const TransferPainter({required this.color, required this.weight});
  @override
  void paint(Canvas canvas, Size size) {
    final dx = size.width;
    final dy = size.height;
    final paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = weight;
    paint.color = color;
    // canvas.drawCircle(offset, offset.dx, paint);
    final path = Path();
    // canvas.drawRRect(, paint);
    canvas.drawPath(
      dashPath(
        path
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(0, 0, dx, dy),
              const Radius.circular(100),
            ),
          ),
        dashArray: CircularIntervalList<double>(
          <double>[(dx) / 4, (dx * .5) / 5],
        ),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
