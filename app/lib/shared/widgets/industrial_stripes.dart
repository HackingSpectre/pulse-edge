import 'package:flutter/material.dart';

class IndustrialStripePainter extends CustomPainter {
  IndustrialStripePainter({
    required this.color,
    this.slantRight = false,
    this.strokeWidth = 1.0,
    this.step = 6.0,
  });

  final Color color;
  final bool slantRight;
  final double strokeWidth;
  final double step;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));

    if (slantRight) {
      for (double i = -height; i < width + height; i += step) {
        canvas.drawLine(Offset(i, 0), Offset(i + height, height), paint);
      }
    } else {
      for (double i = width + height; i > -height; i -= step) {
        canvas.drawLine(Offset(i, 0), Offset(i - height, height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant IndustrialStripePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.slantRight != slantRight ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.step != step;
  }
}
