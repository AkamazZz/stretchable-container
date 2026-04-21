import 'package:flutter/widgets.dart';

import '../models/stretchable_container_config.dart';

String formatGridCoordinates(
  Offset localPosition,
  StretchableContainerConfig config,
) {
  final usableWidth = config.width - 2 * config.gridPadding;
  final usableHeight = config.gridHeight - 2 * config.gridPadding;

  final stepX = config.gridColumns > 1
      ? usableWidth / (config.gridColumns - 1)
      : usableWidth;
  final stepY = config.gridRows > 1
      ? usableHeight / (config.gridRows - 1)
      : usableHeight;

  final gridX = ((localPosition.dx - config.gridPadding) / stepX)
      .clamp(0, config.gridColumns - 1)
      .round();
  final gridY = ((localPosition.dy - config.gridPadding) / stepY)
      .clamp(0, config.gridRows - 1)
      .round();

  return 'X: $gridX / Y: $gridY';
}
