import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/stretch_controller.dart';

class StretchableDotGridPainter extends CustomPainter {
  StretchableDotGridPainter({
    required this.frame,
    required this.points,
    required this.baseDotSize,
    required this.maxDotGrowth,
    required this.influenceRadius,
    required this.dotColor,
  }) : super(repaint: frame);

  final ValueListenable<DotGridFrame> frame;

  final List<Offset> points;
  final double baseDotSize;
  final double maxDotGrowth;
  final double influenceRadius;
  final Color dotColor;

  final Paint _paint = Paint()..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final dotGridFrame = frame.value;
    final dragLocalPosition = dotGridFrame.dragLocalPosition;
    final proximityStrength = dotGridFrame.proximityStrength;

    for (final point in points) {
      var eased = 0.0;

      if (dragLocalPosition != null) {
        final distance = (point - dragLocalPosition).distance;
        final tRaw = 1.0 - (distance / influenceRadius);
        final t = tRaw.clamp(0.0, 1.0);
        eased = Curves.easeOut.transform(t);
      }

      final grow = maxDotGrowth * eased * proximityStrength;
      final radius = (baseDotSize + grow) / 2;
      final alpha = (0.45 + 0.55 * eased * proximityStrength).clamp(0.0, 1.0);

      _paint.color = Color.fromARGB(
        (alpha * 255).round(),
        (dotColor.r * 255).round().clamp(0, 255),
        (dotColor.g * 255).round().clamp(0, 255),
        (dotColor.b * 255).round().clamp(0, 255),
      );
      canvas.drawCircle(point, radius, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant StretchableDotGridPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.baseDotSize != baseDotSize ||
        oldDelegate.maxDotGrowth != maxDotGrowth ||
        oldDelegate.influenceRadius != influenceRadius ||
        oldDelegate.frame != frame ||
        oldDelegate.dotColor != dotColor;
  }
}
