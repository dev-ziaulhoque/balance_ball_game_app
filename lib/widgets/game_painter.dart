import 'dart:math';
import 'package:flutter/material.dart';

class GamePainter extends CustomPainter {
  final Offset ballPosition;
  final double ballRadius;
  final double innerRingRatio;
  final double middleRingRatio;
  final double outerRingRatio;
  final bool windActive;

  GamePainter({
    required this.ballPosition,
    required this.ballRadius,
    required this.innerRingRatio,
    required this.middleRingRatio,
    required this.outerRingRatio,
    required this.windActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width / 2, size.height / 2) * 0.9;

    _drawRings(canvas, center, maxRadius);

    if (windActive) {
      _drawWindIndicator(canvas, center, maxRadius);
    }

    _drawBall(canvas, center);
  }

  void _drawRings(Canvas canvas, Offset center, double maxRadius) {
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green.withOpacity(0.4);

    canvas.drawCircle(
      center,
      maxRadius * innerRingRatio,
      ringPaint,
    );

    canvas.drawCircle(
      center,
      maxRadius * middleRingRatio,
      ringPaint,
    );

    canvas.drawCircle(
      center,
      maxRadius * outerRingRatio,
      ringPaint..strokeWidth = 3.0..color = Colors.green.withOpacity(0.6),
    );
  }

  void _drawWindIndicator(Canvas canvas, Offset center, double maxRadius) {
    final windPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final windRadius = maxRadius * outerRingRatio + 10;
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final x = center.dx + cos(angle) * windRadius;
      final y = center.dy + sin(angle) * windRadius;

      canvas.drawCircle(
        Offset(x, y),
        4,
        windPaint,
      );
    }
  }

  void _drawBall(Canvas canvas, Offset center) {
    final ballCenter = center + ballPosition;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(
      ballCenter + const Offset(2, 2),
      ballRadius,
      shadowPaint,
    );

    final ballPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(ballCenter, ballRadius, ballPaint);

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      ballCenter + Offset(-ballRadius * 0.3, -ballRadius * 0.3),
      ballRadius * 0.4,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(GamePainter oldDelegate) {
    return oldDelegate.ballPosition != ballPosition ||
        oldDelegate.windActive != windActive;
  }
}