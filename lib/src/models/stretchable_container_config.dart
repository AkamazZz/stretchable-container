import 'package:flutter/widgets.dart';

@immutable
class StretchableContainerConfig {
  const StretchableContainerConfig({
    this.width = 300,
    this.height = 400,
    this.borderRadius = 40,
    this.gridRows = 9,
    this.gridColumns = 9,
    this.gridPadding = 20,
    this.baseDotSize = 4,
    this.maxDotGrowth = 12,
    this.influenceRadius = 120,
    this.maxOffset = 20,
    this.maxScaleDelta = 0.15,
    this.contentPadding = const EdgeInsets.all(16),
    this.footerHeight = 40,
  });

  final double width;
  final double height;
  final double borderRadius;
  final int gridRows;
  final int gridColumns;
  final double gridPadding;
  final double baseDotSize;
  final double maxDotGrowth;
  final double influenceRadius;
  final double maxOffset;
  final double maxScaleDelta;
  final EdgeInsets contentPadding;
  final double footerHeight;

  double get gridHeight => height - footerHeight - contentPadding.vertical;
}
