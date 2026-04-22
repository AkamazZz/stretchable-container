import 'package:flutter/widgets.dart';

@immutable
class StretchLayout {
  const StretchLayout({
    this.width,
    this.height,
    this.borderRadius = 40,
    this.contentPadding = const EdgeInsets.all(16),
    this.footerHeight = 40,
  }) : assert(width == null || width > 0, 'width must be positive'),
       assert(height == null || height > 0, 'height must be positive'),
       assert(borderRadius >= 0, 'borderRadius must be >= 0'),
       assert(footerHeight >= 0, 'footerHeight must be >= 0');

  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double footerHeight;

  StretchLayout copyWith({
    double? width,
    double? height,
    double? borderRadius,
    EdgeInsets? contentPadding,
    double? footerHeight,
  }) {
    return StretchLayout(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      footerHeight: footerHeight ?? this.footerHeight,
    );
  }
}
