import 'package:flutter/widgets.dart';

import '../models/dot_grid_spec.dart';

@immutable
class GridGeometry {
  const GridGeometry({
    required this.padding,
    required this.stepX,
    required this.stepY,
    required this.points,
  });

  final double padding;
  final double stepX;
  final double stepY;
  final List<Offset> points;
}

GridGeometry calculateGridGeometry({
  required double width,
  required double height,
  required double padding,
  required int rows,
  required int columns,
}) {
  final usableWidth = width - 2 * padding;
  final usableHeight = height - 2 * padding;

  final stepX = columns > 1 ? usableWidth / (columns - 1) : usableWidth;
  final stepY = rows > 1 ? usableHeight / (rows - 1) : usableHeight;

  final points = List<Offset>.generate(rows * columns, (index) {
    final row = index ~/ columns;
    final column = index % columns;
    final x = padding + column * stepX;
    final y = padding + row * stepY;
    return Offset(x, y);
  }, growable: false);

  return GridGeometry(
    padding: padding,
    stepX: stepX,
    stepY: stepY,
    points: points,
  );
}

String formatGridCoordinates(
  Offset localPosition, {
  required DotGridSpec grid,
  required double width,
  required double height,
}) {
  final geometry = calculateGridGeometry(
    width: width,
    height: height,
    padding: grid.padding,
    rows: grid.rows,
    columns: grid.columns,
  );

  final normalizedX = geometry.stepX == 0
      ? 0.0
      : (localPosition.dx - geometry.padding) / geometry.stepX;
  final normalizedY = geometry.stepY == 0
      ? 0.0
      : (localPosition.dy - geometry.padding) / geometry.stepY;

  final gridX = normalizedX.clamp(0, grid.columns - 1).round();
  final gridY = normalizedY.clamp(0, grid.rows - 1).round();

  return 'X: $gridX / Y: $gridY';
}
