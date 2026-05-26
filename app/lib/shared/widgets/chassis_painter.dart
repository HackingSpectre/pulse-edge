import 'package:flutter/material.dart';

class ChassisPainter extends CustomPainter {
  ChassisPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final w = size.width;
    final h = size.height;

    // Top-right vent cluster.
    canvas.drawRect(Rect.fromLTWH(w - 12, 36, 12, 6), paint);
    canvas.drawRect(Rect.fromLTWH(w - 12, 46, 12, 6), paint);
    canvas.drawRect(Rect.fromLTWH(w - 12, 56, 12, 6), paint);

    // Bottom-left grip blocks.
    canvas.drawRect(Rect.fromLTWH(0, h - 72, 8, 36), paint);
    canvas.drawRect(Rect.fromLTWH(12, h - 72, 8, 36), paint);

    // Bottom-right chamfer.
    final corner = Path()
      ..moveTo(w - 40, h)
      ..lineTo(w, h - 40)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(corner, paint);

    // Top-left notch.
    final notch = Path()
      ..moveTo(0, 0)
      ..lineTo(18, 0)
      ..lineTo(0, 18)
      ..close();
    canvas.drawPath(notch, paint);
  }

  @override
  bool shouldRepaint(covariant ChassisPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
