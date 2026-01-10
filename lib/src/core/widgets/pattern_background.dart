import 'package:flutter/material.dart';

class PatternBackground extends StatelessWidget {
  final Widget child;
  const PatternBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DotPainter(),
      child: child,
    );
  }
}

class DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color(0xFFE0E5EC) // Very subtle grey dot
      ..style = PaintingStyle.fill;

    // Draw dots every 30 pixels
    for (double x = 0; x < size.width; x += 30) {
      for (double y = 0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}