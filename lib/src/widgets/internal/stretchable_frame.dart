import 'package:flutter/material.dart';

class StretchableFrame extends StatelessWidget {
  const StretchableFrame({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.borderColor,
    required this.shadows,
    required this.child,
  });

  final double width;
  final double height;
  final double borderRadius;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      ),
    );
  }
}
