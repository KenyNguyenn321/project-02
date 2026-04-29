import 'dart:math';
import 'package:flutter/material.dart';

// clean chakra swirl logo
class ZenLogo extends StatelessWidget {
  final double size;

  const ZenLogo({
    super.key,
    this.size = 90,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SwirlPainter(),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // start from outer edge (right side)
    double angle = 0;
    double radius = maxRadius;

    path.moveTo(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    // spiral inward smoothly
    while (radius > 4) {
      angle += 0.15;
      radius -= 0.5;

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // optional outer circle (clean border)
    canvas.drawCircle(
      center,
      maxRadius - 2,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}