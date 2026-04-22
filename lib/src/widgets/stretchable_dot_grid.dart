import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/stretch_controller.dart';
import '../models/dot_grid_spec.dart';
import '../painters/stretchable_dot_grid_painter.dart';
import '../utils/grid_coordinates.dart';

class StretchableDotGrid extends StatefulWidget {
  const StretchableDotGrid({
    super.key,
    required this.width,
    required this.height,
    required this.grid,
    required this.dotColor,
    required this.frame,
  });

  final double width;
  final double height;
  final DotGridSpec grid;
  final Color dotColor;
  final ValueListenable<DotGridFrame> frame;

  @override
  State<StretchableDotGrid> createState() => _StretchableDotGridState();
}

class _StretchableDotGridState extends State<StretchableDotGrid> {
  late List<Offset> _points;
  late StretchableDotGridPainter _painter;

  @override
  void initState() {
    super.initState();
    _recomputePoints();
    _rebuildPainter();
  }

  @override
  void didUpdateWidget(covariant StretchableDotGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.grid.padding != widget.grid.padding ||
        oldWidget.grid.rows != widget.grid.rows ||
        oldWidget.grid.columns != widget.grid.columns) {
      _recomputePoints();
      _rebuildPainter();
    }

    if (oldWidget.grid.baseDotSize != widget.grid.baseDotSize ||
        oldWidget.grid.maxDotGrowth != widget.grid.maxDotGrowth ||
        oldWidget.grid.influenceRadius != widget.grid.influenceRadius ||
        oldWidget.dotColor != widget.dotColor ||
        oldWidget.frame != widget.frame) {
      _rebuildPainter();
    }
  }

  void _recomputePoints() {
    _points = calculateGridGeometry(
      width: widget.width,
      height: widget.height,
      padding: widget.grid.padding,
      rows: widget.grid.rows,
      columns: widget.grid.columns,
    ).points;
  }

  void _rebuildPainter() {
    _painter = StretchableDotGridPainter(
      frame: widget.frame,
      points: _points,
      baseDotSize: widget.grid.baseDotSize,
      maxDotGrowth: widget.grid.maxDotGrowth,
      influenceRadius: widget.grid.influenceRadius,
      dotColor: widget.dotColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(
        painter: _painter,
        isComplex: true,
        willChange: true,
      ),
    );
  }
}
