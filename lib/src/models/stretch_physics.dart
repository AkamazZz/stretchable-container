import 'package:flutter/widgets.dart';

enum SnapMode { curve, spring }

enum StretchResponse { linear, exponential, rubberBand, logarithmic }

enum StretchAxes { both, horizontal, vertical }

enum StretchAnchor { center, edge, cornerGrab }

@immutable
class StretchPhysics {
  static final SpringDescription defaultSpringDescription = SpringDescription(
    mass: 1,
    stiffness: 180,
    damping: 22,
  );

  static const StretchPhysics defaults = StretchPhysics._internal(
    maxOffset: 20,
    maxScaleDelta: 0.15,
    snapMode: SnapMode.spring,
    snapDuration: Duration(milliseconds: 200),
    snapCurve: Curves.easeInOut,
    springDescription: null,
    snapDurationScale: 1.0,
    hapticsEnabled: false,
    response: StretchResponse.linear,
    axes: StretchAxes.both,
    anchor: StretchAnchor.center,
    power: 1.0,
  );

  factory StretchPhysics({
    double maxOffset = 20,
    double maxScaleDelta = 0.15,
    SnapMode snapMode = SnapMode.spring,
    Duration snapDuration = const Duration(milliseconds: 200),
    Curve snapCurve = Curves.easeInOut,
    SpringDescription? springDescription,
    double snapDurationScale = 1.0,
    bool hapticsEnabled = false,
    StretchResponse response = StretchResponse.linear,
    StretchAxes axes = StretchAxes.both,
    StretchAnchor anchor = StretchAnchor.center,
    double power = 1.0,
  }) {
    assert(maxOffset >= 0, 'maxOffset must be >= 0');
    assert(maxScaleDelta >= 0, 'maxScaleDelta must be >= 0');
    assert(snapDuration >= Duration.zero, 'snapDuration must be >= 0');
    assert(snapDurationScale > 0, 'snapDurationScale must be > 0');
    if (springDescription != null) {
      assert(
        springDescription.mass > 0,
        'springDescription.mass must be > 0',
      );
      assert(
        springDescription.stiffness > 0,
        'springDescription.stiffness must be > 0',
      );
      assert(
        springDescription.damping > 0,
        'springDescription.damping must be > 0',
      );
    }
    assert(power >= 0 && power <= 2, 'power must be between 0 and 2');

    return StretchPhysics._internal(
      maxOffset: maxOffset,
      maxScaleDelta: maxScaleDelta,
      snapMode: snapMode,
      snapDuration: snapDuration,
      snapCurve: snapCurve,
      springDescription: springDescription,
      snapDurationScale: snapDurationScale,
      hapticsEnabled: hapticsEnabled,
      response: response,
      axes: axes,
      anchor: anchor,
      power: power,
    );
  }

  const StretchPhysics._internal({
    required this.maxOffset,
    required this.maxScaleDelta,
    required this.snapMode,
    required this.snapDuration,
    required this.snapCurve,
    required this.springDescription,
    required this.snapDurationScale,
    required this.hapticsEnabled,
    required this.response,
    required this.axes,
    required this.anchor,
    required this.power,
  });

  final double maxOffset;
  final double maxScaleDelta;
  final SnapMode snapMode;
  final Duration snapDuration;
  final Curve snapCurve;
  final SpringDescription? springDescription;
  final double snapDurationScale;
  final bool hapticsEnabled;
  final StretchResponse response;
  final StretchAxes axes;
  final StretchAnchor anchor;
  final double power;

  SpringDescription get resolvedSpringDescription =>
      springDescription ?? defaultSpringDescription;

  StretchPhysics copyWith({
    double? maxOffset,
    double? maxScaleDelta,
    SnapMode? snapMode,
    Duration? snapDuration,
    Curve? snapCurve,
    SpringDescription? springDescription,
    double? snapDurationScale,
    bool? hapticsEnabled,
    StretchResponse? response,
    StretchAxes? axes,
    StretchAnchor? anchor,
    double? power,
  }) {
    return StretchPhysics(
      maxOffset: maxOffset ?? this.maxOffset,
      maxScaleDelta: maxScaleDelta ?? this.maxScaleDelta,
      snapMode: snapMode ?? this.snapMode,
      snapDuration: snapDuration ?? this.snapDuration,
      snapCurve: snapCurve ?? this.snapCurve,
      springDescription: springDescription ?? this.springDescription,
      snapDurationScale: snapDurationScale ?? this.snapDurationScale,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      response: response ?? this.response,
      axes: axes ?? this.axes,
      anchor: anchor ?? this.anchor,
      power: power ?? this.power,
    );
  }
}
