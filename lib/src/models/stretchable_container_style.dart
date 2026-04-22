import 'package:flutter/material.dart';

@immutable
class StretchableContainerStyle {
  const StretchableContainerStyle({
    this.dotColor,
    this.borderColor,
    this.shadows,
    this.titleStyle,
    this.coordinateStyle,
  });

  final Color? dotColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final TextStyle? titleStyle;
  final TextStyle? coordinateStyle;

  StretchableContainerStyle copyWith({
    Color? dotColor,
    Color? borderColor,
    List<BoxShadow>? shadows,
    TextStyle? titleStyle,
    TextStyle? coordinateStyle,
  }) {
    return StretchableContainerStyle(
      dotColor: dotColor ?? this.dotColor,
      borderColor: borderColor ?? this.borderColor,
      shadows: shadows ?? this.shadows,
      titleStyle: titleStyle ?? this.titleStyle,
      coordinateStyle: coordinateStyle ?? this.coordinateStyle,
    );
  }
}
