import 'package:flutter/material.dart';

import '../models/stretchable_container_config.dart';

class StretchableDotGrid extends StatelessWidget {
  const StretchableDotGrid({
    super.key,
    required this.width,
    required this.height,
    required this.config,
    required this.dragLocalPosition,
    required this.proximityStrength,
  });

  final double width;
  final double height;
  final StretchableContainerConfig config;
  final Offset? dragLocalPosition;
  final double proximityStrength;

  @override
  Widget build(BuildContext context) {
    final dots = <Widget>[];

    final usableWidth = width - 2 * config.gridPadding;
    final usableHeight = height - 2 * config.gridPadding;

    final stepX = config.gridColumns > 1
        ? usableWidth / (config.gridColumns - 1)
        : usableWidth;
    final stepY = config.gridRows > 1
        ? usableHeight / (config.gridRows - 1)
        : usableHeight;

    for (var row = 0; row < config.gridRows; row++) {
      for (var column = 0; column < config.gridColumns; column++) {
        final x = config.gridPadding + column * stepX;
        final y = config.gridPadding + row * stepY;

        var eased = 0.0;
        if (dragLocalPosition != null) {
          final distance = (Offset(x, y) - dragLocalPosition!).distance;
          final tRaw = 1.0 - (distance / config.influenceRadius);
          final t = tRaw.clamp(0.0, 1.0);
          eased = Curves.easeOut.transform(t);
        }

        final grow = config.maxDotGrowth * eased * proximityStrength;
        final dotSize = config.baseDotSize + grow;
        final alpha = (0.45 + 0.55 * eased * proximityStrength).clamp(0.0, 1.0);

        dots.add(
          Positioned(
            left: x - dotSize / 2,
            top: y - dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: alpha),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: dots);
  }
}
