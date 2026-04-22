import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../models/stretch_physics.dart';

@immutable
class DotGridFrame {
  const DotGridFrame({
    required this.dragLocalPosition,
    required this.proximityStrength,
  });

  final Offset? dragLocalPosition;
  final double proximityStrength;
}

@immutable
class StretchState {
  const StretchState({
    required this.offset,
    required this.dragLocalPosition,
    required this.isDragging,
    required this.snapProgress,
    required this.transformAlignment,
    required this.maxOffset,
    required this.maxScaleDelta,
  });

  const StretchState.rest({
    required double maxOffset,
    required double maxScaleDelta,
  }) : this(
         offset: Offset.zero,
         dragLocalPosition: null,
         isDragging: false,
         snapProgress: 0,
         transformAlignment: Alignment.center,
         maxOffset: maxOffset,
         maxScaleDelta: maxScaleDelta,
       );

  final Offset offset;
  final Offset? dragLocalPosition;
  final bool isDragging;
  final double snapProgress;
  final Alignment transformAlignment;
  final double maxOffset;
  final double maxScaleDelta;

  double get scaleX => _axisScale(offset.dx);
  double get scaleY => _axisScale(offset.dy);
  double get proximityStrength => isDragging ? 1.0 : snapProgress.clamp(0.0, 1.0);

  StretchState copyWith({
    Offset? offset,
    Offset? dragLocalPosition,
    bool? isDragging,
    bool clearDragLocalPosition = false,
    double? snapProgress,
    Alignment? transformAlignment,
    double? maxOffset,
    double? maxScaleDelta,
  }) {
    return StretchState(
      offset: offset ?? this.offset,
      dragLocalPosition: clearDragLocalPosition
          ? null
          : (dragLocalPosition ?? this.dragLocalPosition),
      isDragging: isDragging ?? this.isDragging,
      snapProgress: snapProgress ?? this.snapProgress,
      transformAlignment: transformAlignment ?? this.transformAlignment,
      maxOffset: maxOffset ?? this.maxOffset,
      maxScaleDelta: maxScaleDelta ?? this.maxScaleDelta,
    );
  }

  double _axisScale(double axisOffset) {
    if (maxOffset == 0) {
      return 1.0;
    }

    return 1.0 + (axisOffset.abs() / maxOffset * maxScaleDelta);
  }
}

class StretchController extends ChangeNotifier
    implements ValueListenable<StretchState> {
  StretchController({
    required TickerProvider vsync,
    required StretchPhysics physics,
  }) : _animationController = AnimationController(
         duration: physics.snapDuration,
         vsync: vsync,
       ),
       _value = StretchState.rest(
         maxOffset: physics.maxOffset,
         maxScaleDelta: physics.maxScaleDelta,
       ) {
    _physics = physics;
    _animationController.addListener(_handleAnimationTick);
    _animationController.addStatusListener(_handleAnimationStatusChange);
    _dotGridFrame = _DotGridFrameListenable(
      const DotGridFrame(dragLocalPosition: null, proximityStrength: 0),
    );
  }

  final AnimationController _animationController;
  late StretchPhysics _physics;
  late final _DotGridFrameListenable _dotGridFrame;
  StretchState _value;
  Offset _snapStartOffset = Offset.zero;
  double _snapVelocity = 0;

  ValueListenable<DotGridFrame> get dotGridFrame => _dotGridFrame;
  @visibleForTesting
  bool get isAnimating => _animationController.isAnimating;

  @override
  StretchState get value => _value;

  void updatePhysics(StretchPhysics physics) {
    _debugAssertNotInBuild('updatePhysics');
    _physics = physics;
    _animationController.duration = physics.snapDuration;
    _replaceValue(
      _value.copyWith(
        maxOffset: physics.maxOffset,
        maxScaleDelta: physics.maxScaleDelta,
      ),
      notify: false,
    );
  }

  void onPanUpdate(DragUpdateDetails details, Size size) {
    _debugAssertNotInBuild('onPanUpdate');
    final isDragStart = !_value.isDragging;
    if (!_value.isDragging && _animationController.isAnimating) {
      _animationController.stop();
    }

    final dragLocalPosition = _clampToSize(details.localPosition, size);
    final resolvedAnchor = _AnchorResolver.resolve(
      dragLocalPosition,
      size,
      _physics.anchor,
    );
    final offset = _applyAxes(
      _applyResponse(resolvedAnchor.direction, _physics),
      _physics.axes,
    );

    _replaceValue(
      _value.copyWith(
        offset: offset,
        dragLocalPosition: dragLocalPosition,
        isDragging: true,
        snapProgress: 0,
        transformAlignment: resolvedAnchor.alignment,
      ),
    );

    if (isDragStart && _physics.hapticsEnabled) {
      unawaited(HapticFeedback.selectionClick());
    }
  }

  void onPanEnd([DragEndDetails? details]) {
    _debugAssertNotInBuild('onPanEnd');
    _startSnapBack(details);
  }

  void onPanCancel() {
    _debugAssertNotInBuild('onPanCancel');
    _startSnapBack();
  }

  void _startSnapBack([DragEndDetails? details]) {
    _snapStartOffset = _value.offset;
    _snapVelocity = _normalizedVelocity(details);
    _replaceValue(
      _value.copyWith(
        isDragging: false,
        snapProgress: _value.offset == Offset.zero ? 0 : 1,
      ),
    );

    if (_snapStartOffset == Offset.zero) {
      _maybeTriggerSnapCompleteHaptic();
      return;
    }

    _animationController.stop();
    _animationController.value = 0;

    if (_physics.snapMode == SnapMode.spring) {
      final simulation = SpringSimulation(
        _physics.resolvedSpringDescription,
        0,
        1,
        _snapVelocity,
      );
      _animationController.animateWith(simulation);
      return;
    }

    _animationController.forward();
  }

  void _handleAnimationTick() {
    if (_value.isDragging) {
      return;
    }

    final animationValue = _animationController.value;
    final t = _physics.snapMode == SnapMode.spring
        ? 1 - animationValue
        : 1 - _physics.snapCurve.transform(animationValue);
    _replaceValue(
      _value.copyWith(
        offset: Offset(_snapStartOffset.dx * t, _snapStartOffset.dy * t),
        snapProgress: t,
      ),
    );
  }

  void _handleAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _maybeTriggerSnapCompleteHaptic();
    }
  }

  void _replaceValue(StretchState newValue, {bool notify = true}) {
    _value = newValue;
    _dotGridFrame.value = DotGridFrame(
      dragLocalPosition: newValue.dragLocalPosition,
      proximityStrength: newValue.proximityStrength,
    );

    if (notify) {
      notifyListeners();
    }
  }

  void semanticNudge(double direction) {
    _debugAssertNotInBuild('semanticNudge');
    final nudgedOffset = Offset(
      (_value.offset.dx + direction * (_physics.maxOffset / 2)).clamp(
        -_physics.maxOffset,
        _physics.maxOffset,
      ),
      _value.offset.dy,
    );
    _replaceValue(
      _value.copyWith(
        offset: nudgedOffset,
        isDragging: false,
        snapProgress: 1,
        transformAlignment: Alignment.centerLeft,
      ),
    );
    _startSnapBack();
  }

  @visibleForTesting
  void debugSetSnapValue(double value) {
    _animationController.value = value.clamp(0.0, 1.0);
    _handleAnimationTick();
  }

  void _debugAssertNotInBuild(String methodName) {
    assert(() {
      final phase = SchedulerBinding.instance.schedulerPhase;
      if (phase == SchedulerPhase.persistentCallbacks ||
          phase == SchedulerPhase.postFrameCallbacks) {
        throw FlutterError(
          'StretchController.$methodName was called during the build phase. '
          'Move this call into a gesture callback or a post-frame callback.',
        );
      }
      return true;
    }());
  }

  Offset _clampToSize(Offset localPosition, Size size) {
    return Offset(
      localPosition.dx.clamp(0.0, size.width),
      localPosition.dy.clamp(0.0, size.height),
    );
  }

  Offset _applyResponse(Offset direction, StretchPhysics physics) {
    if (physics.power == 0 || physics.maxOffset == 0) {
      return Offset.zero;
    }

    final scaledDirection = direction * physics.power;
    switch (physics.response) {
      case StretchResponse.linear:
        return Offset(
          (scaledDirection.dx * physics.maxOffset).clamp(
            -physics.maxOffset,
            physics.maxOffset,
          ),
          (scaledDirection.dy * physics.maxOffset).clamp(
            -physics.maxOffset,
            physics.maxOffset,
          ),
        );
      case StretchResponse.exponential:
        return _mapPerAxis(
          scaledDirection,
          physics.maxOffset,
          (value) => value * value,
        );
      case StretchResponse.rubberBand:
        return _mapPerAxis(
          scaledDirection,
          physics.maxOffset,
          (value) => 1 - (1 / (1 + (value * 1.2))),
        );
      case StretchResponse.logarithmic:
        final denominator = math.log(4);
        return _mapPerAxis(
          scaledDirection,
          physics.maxOffset,
          (value) => math.log(1 + value * 3) / denominator,
        );
    }
  }

  Offset _mapPerAxis(
    Offset direction,
    double maxOffset,
    double Function(double value) transform,
  ) {
    double mapAxis(double axis) {
      final sign = axis.sign;
      final magnitude = axis.abs().clamp(0.0, 1.0);
      return sign * transform(magnitude).clamp(0.0, 1.0) * maxOffset;
    }

    return Offset(mapAxis(direction.dx), mapAxis(direction.dy));
  }

  Offset _applyAxes(Offset offset, StretchAxes axes) {
    switch (axes) {
      case StretchAxes.both:
        return offset;
      case StretchAxes.horizontal:
        return Offset(offset.dx, 0);
      case StretchAxes.vertical:
        return Offset(0, offset.dy);
    }
  }

  double _normalizedVelocity(DragEndDetails? details) {
    if (details == null || _physics.maxOffset == 0) {
      return 0;
    }

    return (details.velocity.pixelsPerSecond.distance / (_physics.maxOffset * 40))
        .clamp(-5.0, 5.0);
  }

  void _maybeTriggerSnapCompleteHaptic() {
    if (_physics.hapticsEnabled && !_value.isDragging) {
      unawaited(HapticFeedback.lightImpact());
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_handleAnimationTick);
    _animationController.removeStatusListener(_handleAnimationStatusChange);
    _animationController.dispose();
    _dotGridFrame.dispose();
    super.dispose();
  }
}

class _ResolvedAnchor {
  const _ResolvedAnchor({
    required this.direction,
    required this.alignment,
  });

  final Offset direction;
  final Alignment alignment;
}

class _AnchorResolver {
  static _ResolvedAnchor resolve(
    Offset localPosition,
    Size size,
    StretchAnchor anchor,
  ) {
    switch (anchor) {
      case StretchAnchor.center:
        final center = Offset(size.width / 2, size.height / 2);
        final direction = Offset(
          center.dx == 0 ? 0 : (localPosition.dx - center.dx) / center.dx,
          center.dy == 0 ? 0 : (localPosition.dy - center.dy) / center.dy,
        );
        return _ResolvedAnchor(
          direction: direction,
          alignment: Alignment(
            direction.dx > 0 ? -0.5 : 0.5,
            direction.dy > 0 ? -0.5 : 0.5,
          ),
        );
      case StretchAnchor.edge:
        final left = localPosition.dx;
        final right = size.width - localPosition.dx;
        final top = localPosition.dy;
        final bottom = size.height - localPosition.dy;
        final minDistance = math.min(math.min(left, right), math.min(top, bottom));
        if (minDistance == left || minDistance == right) {
          final horizontal = size.width == 0
              ? 0.0
              : ((localPosition.dx / size.width) * 2) - 1;
          return _ResolvedAnchor(
            direction: Offset(horizontal, 0),
            alignment: Alignment(horizontal >= 0 ? -1 : 1, 0),
          );
        }
        final vertical = size.height == 0
            ? 0.0
            : ((localPosition.dy / size.height) * 2) - 1;
        return _ResolvedAnchor(
          direction: Offset(0, vertical),
          alignment: Alignment(0, vertical >= 0 ? -1 : 1),
        );
      case StretchAnchor.cornerGrab:
        final center = Offset(size.width / 2, size.height / 2);
        final direction = Offset(
          center.dx == 0 ? 0 : (localPosition.dx - center.dx) / center.dx,
          center.dy == 0 ? 0 : (localPosition.dy - center.dy) / center.dy,
        );
        return _ResolvedAnchor(
          direction: direction,
          alignment: Alignment(
            direction.dx >= 0 ? -1 : 1,
            direction.dy >= 0 ? -1 : 1,
          ),
        );
    }
  }
}

class _DotGridFrameListenable extends ChangeNotifier
    implements ValueListenable<DotGridFrame> {
  _DotGridFrameListenable(this._value);

  DotGridFrame _value;

  @override
  DotGridFrame get value => _value;

  set value(DotGridFrame next) {
    if (_value.dragLocalPosition == next.dragLocalPosition &&
        _value.proximityStrength == next.proximityStrength) {
      return;
    }

    _value = next;
    notifyListeners();
  }
}
