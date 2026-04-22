import 'package:flutter/widgets.dart';

@immutable
class DotGridSpec {
  const DotGridSpec({
    this.rows = 9,
    this.columns = 9,
    this.padding = 20,
    this.baseDotSize = 4,
    this.maxDotGrowth = 12,
    this.influenceRadius = 120,
  }) : assert(rows >= 1, 'rows must be >= 1'),
       assert(columns >= 1, 'columns must be >= 1'),
       assert(padding >= 0, 'padding must be >= 0'),
       assert(baseDotSize >= 0, 'baseDotSize must be >= 0'),
       assert(maxDotGrowth >= 0, 'maxDotGrowth must be >= 0'),
       assert(influenceRadius > 0, 'influenceRadius must be > 0');

  final int rows;
  final int columns;
  final double padding;
  final double baseDotSize;
  final double maxDotGrowth;
  final double influenceRadius;

  DotGridSpec copyWith({
    int? rows,
    int? columns,
    double? padding,
    double? baseDotSize,
    double? maxDotGrowth,
    double? influenceRadius,
  }) {
    return DotGridSpec(
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      padding: padding ?? this.padding,
      baseDotSize: baseDotSize ?? this.baseDotSize,
      maxDotGrowth: maxDotGrowth ?? this.maxDotGrowth,
      influenceRadius: influenceRadius ?? this.influenceRadius,
    );
  }
}
