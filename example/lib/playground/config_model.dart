import 'package:flutter/material.dart';
import 'package:stretchable_container/stretchable_container.dart';

enum BackgroundMode { none, darkSolid, photo }

const sampleBackgroundImageUrl =
    'https://images.unsplash.com/photo-1505832018823-50331d70d237?q=80&w=1980';

class PlaygroundConfig extends ChangeNotifier {
  PlaygroundConfig();

  static const StretchLayout _defaultLayout = StretchLayout(
    width: 300,
    height: 400,
  );
  static const DotGridSpec _defaultGrid = DotGridSpec();
  static const StretchableContainerStyle _defaultStyle =
      StretchableContainerStyle();

  bool fixedSize = false;
  BackgroundMode backgroundMode = BackgroundMode.darkSolid;
  double borderRadius = _defaultLayout.borderRadius;
  double footerHeight = _defaultLayout.footerHeight;
  double contentPadding = 16;

  int rows = _defaultGrid.rows;
  int columns = _defaultGrid.columns;
  double gridPadding = _defaultGrid.padding;
  double baseDotSize = _defaultGrid.baseDotSize;
  double maxDotGrowth = _defaultGrid.maxDotGrowth;
  double influenceRadius = _defaultGrid.influenceRadius;

  double maxOffset = StretchPhysics.defaults.maxOffset;
  double maxScaleDelta = StretchPhysics.defaults.maxScaleDelta;
  SnapMode snapMode = StretchPhysics.defaults.snapMode;
  double snapDurationMs = StretchPhysics.defaults.snapDuration.inMilliseconds
      .toDouble();
  double power = StretchPhysics.defaults.power;
  StretchResponse response = StretchPhysics.defaults.response;
  StretchAxes axes = StretchPhysics.defaults.axes;
  StretchAnchor anchor = StretchPhysics.defaults.anchor;
  bool hapticsEnabled = StretchPhysics.defaults.hapticsEnabled;
  double springMass = StretchPhysics.defaultSpringDescription.mass;
  double springStiffness = StretchPhysics.defaultSpringDescription.stiffness;
  double springDamping = StretchPhysics.defaultSpringDescription.damping;
  double snapDurationScale = StretchPhysics.defaults.snapDurationScale;

  Color? dotColor = _defaultStyle.dotColor;
  Color? borderColor = _defaultStyle.borderColor;
  bool shadowsEnabled = true;
  double? titleFontSize;
  double? coordinateFontSize;

  void update(VoidCallback mutate) {
    mutate();
    notifyListeners();
  }

  void reset() {
    fixedSize = false;
    backgroundMode = BackgroundMode.darkSolid;
    borderRadius = _defaultLayout.borderRadius;
    footerHeight = _defaultLayout.footerHeight;
    contentPadding = 16;
    rows = _defaultGrid.rows;
    columns = _defaultGrid.columns;
    gridPadding = _defaultGrid.padding;
    baseDotSize = _defaultGrid.baseDotSize;
    maxDotGrowth = _defaultGrid.maxDotGrowth;
    influenceRadius = _defaultGrid.influenceRadius;
    maxOffset = StretchPhysics.defaults.maxOffset;
    maxScaleDelta = StretchPhysics.defaults.maxScaleDelta;
    snapMode = StretchPhysics.defaults.snapMode;
    snapDurationMs = StretchPhysics.defaults.snapDuration.inMilliseconds
        .toDouble();
    power = StretchPhysics.defaults.power;
    response = StretchPhysics.defaults.response;
    axes = StretchPhysics.defaults.axes;
    anchor = StretchPhysics.defaults.anchor;
    hapticsEnabled = StretchPhysics.defaults.hapticsEnabled;
    springMass = StretchPhysics.defaultSpringDescription.mass;
    springStiffness = StretchPhysics.defaultSpringDescription.stiffness;
    springDamping = StretchPhysics.defaultSpringDescription.damping;
    snapDurationScale = StretchPhysics.defaults.snapDurationScale;
    dotColor = null;
    borderColor = null;
    shadowsEnabled = true;
    titleFontSize = null;
    coordinateFontSize = null;
    notifyListeners();
  }

  StretchLayout get layout => StretchLayout(
        width: fixedSize ? 300 : null,
        height: fixedSize ? 400 : null,
        borderRadius: borderRadius,
        contentPadding: EdgeInsets.all(contentPadding),
        footerHeight: footerHeight,
      );

  DotGridSpec get grid => DotGridSpec(
        rows: rows,
        columns: columns,
        padding: gridPadding,
        baseDotSize: baseDotSize,
        maxDotGrowth: maxDotGrowth,
        influenceRadius: influenceRadius,
      );

  StretchPhysics get physics => StretchPhysics(
        maxOffset: maxOffset,
        maxScaleDelta: maxScaleDelta,
        snapMode: snapMode,
        snapDuration: Duration(milliseconds: snapDurationMs.round()),
        springDescription: SpringDescription(
          mass: springMass,
          stiffness: springStiffness,
          damping: springDamping,
        ),
        snapDurationScale: snapDurationScale,
        hapticsEnabled: hapticsEnabled,
        response: response,
        axes: axes,
        anchor: anchor,
        power: power,
      );

  StretchableContainerStyle get style => StretchableContainerStyle(
        dotColor: dotColor,
        borderColor: borderColor,
        shadows: shadowsEnabled
            ? null
            : const <BoxShadow>[],
        titleStyle: titleFontSize == null
            ? null
            : TextStyle(fontSize: titleFontSize),
        coordinateStyle: coordinateFontSize == null
            ? null
            : TextStyle(fontSize: coordinateFontSize),
      );

  ImageProvider? get backgroundImage => switch (backgroundMode) {
        BackgroundMode.photo => const NetworkImage(sampleBackgroundImageUrl),
        _ => null,
      };
}
