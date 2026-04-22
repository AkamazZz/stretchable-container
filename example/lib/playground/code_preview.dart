import 'package:flutter/material.dart';
import 'package:stretchable_container/stretchable_container.dart';

import 'config_model.dart';

String buildConfigSnippet(PlaygroundConfig config) {
  const defaultLayout = StretchLayout(width: 300, height: 400);
  const defaultGrid = DotGridSpec();
  final defaultPhysics = StretchPhysics.defaults;
  const defaultStyle = StretchableContainerStyle();

  final sections = <String>[];

  final layoutFields = <String>[];
  if (config.fixedSize != true) {
    layoutFields.add('width: null');
    layoutFields.add('height: null');
  }
  if (config.borderRadius != defaultLayout.borderRadius) {
    layoutFields.add('borderRadius: ${config.borderRadius.toStringAsFixed(0)}');
  }
  if (config.footerHeight != defaultLayout.footerHeight) {
    layoutFields.add('footerHeight: ${config.footerHeight.toStringAsFixed(0)}');
  }
  if (config.contentPadding != 16) {
    layoutFields
        .add('contentPadding: EdgeInsets.all(${_formatDouble(config.contentPadding)})');
  }
  if (layoutFields.isNotEmpty) {
    sections.add(_section('layout', 'StretchLayout', layoutFields));
  }

  final gridFields = <String>[];
  if (config.rows != defaultGrid.rows) {
    gridFields.add('rows: ${config.rows}');
  }
  if (config.columns != defaultGrid.columns) {
    gridFields.add('columns: ${config.columns}');
  }
  if (config.gridPadding != defaultGrid.padding) {
    gridFields.add('padding: ${_formatDouble(config.gridPadding)}');
  }
  if (config.baseDotSize != defaultGrid.baseDotSize) {
    gridFields.add('baseDotSize: ${_formatDouble(config.baseDotSize)}');
  }
  if (config.maxDotGrowth != defaultGrid.maxDotGrowth) {
    gridFields.add('maxDotGrowth: ${_formatDouble(config.maxDotGrowth)}');
  }
  if (config.influenceRadius != defaultGrid.influenceRadius) {
    gridFields.add('influenceRadius: ${_formatDouble(config.influenceRadius)}');
  }
  if (gridFields.isNotEmpty) {
    sections.add(_section('grid', 'DotGridSpec', gridFields));
  }

  final physicsFields = <String>[];
  if (config.maxOffset != defaultPhysics.maxOffset) {
    physicsFields.add('maxOffset: ${_formatDouble(config.maxOffset)}');
  }
  if (config.maxScaleDelta != defaultPhysics.maxScaleDelta) {
    physicsFields
        .add('maxScaleDelta: ${_formatDouble(config.maxScaleDelta)}');
  }
  if (config.snapMode != defaultPhysics.snapMode) {
    physicsFields.add('snapMode: SnapMode.${config.snapMode.name}');
  }
  if (config.snapMode == SnapMode.curve &&
      config.snapDurationMs != defaultPhysics.snapDuration.inMilliseconds) {
    physicsFields.add(
      'snapDuration: Duration(milliseconds: ${config.snapDurationMs.round()})',
    );
  }
  if (config.power != defaultPhysics.power) {
    physicsFields.add('power: ${_formatDouble(config.power)}');
  }
  if (config.response != defaultPhysics.response) {
    physicsFields
        .add('response: StretchResponse.${config.response.name}');
  }
  if (config.axes != defaultPhysics.axes) {
    physicsFields.add('axes: StretchAxes.${config.axes.name}');
  }
  if (config.anchor != defaultPhysics.anchor) {
    physicsFields.add('anchor: StretchAnchor.${config.anchor.name}');
  }
  if (config.hapticsEnabled != defaultPhysics.hapticsEnabled) {
    physicsFields.add('hapticsEnabled: ${config.hapticsEnabled}');
  }
  if (config.springMass != StretchPhysics.defaultSpringDescription.mass ||
      config.springStiffness !=
          StretchPhysics.defaultSpringDescription.stiffness ||
      config.springDamping != StretchPhysics.defaultSpringDescription.damping) {
    physicsFields.add(
      'springDescription: SpringDescription('
      'mass: ${_formatDouble(config.springMass)}, '
      'stiffness: ${_formatDouble(config.springStiffness)}, '
      'damping: ${_formatDouble(config.springDamping)})',
    );
  }
  if (config.snapDurationScale != defaultPhysics.snapDurationScale) {
    physicsFields
        .add('snapDurationScale: ${_formatDouble(config.snapDurationScale)}');
  }
  if (physicsFields.isNotEmpty) {
    sections.add(_section('physics', 'StretchPhysics', physicsFields));
  }

  final styleFields = <String>[];
  if (config.dotColor != defaultStyle.dotColor) {
    styleFields.add(
      config.dotColor == null
          ? 'dotColor: null'
          : 'dotColor: ${_colorLiteral(config.dotColor!)}',
    );
  }
  if (config.borderColor != defaultStyle.borderColor) {
    styleFields.add(
      config.borderColor == null
          ? 'borderColor: null'
          : 'borderColor: ${_colorLiteral(config.borderColor!)}',
    );
  }
  if (!config.shadowsEnabled) {
    styleFields.add('shadows: const <BoxShadow>[]');
  }
  if (config.titleFontSize != null) {
    styleFields.add(
      'titleStyle: TextStyle(fontSize: ${_formatDouble(config.titleFontSize!)})',
    );
  }
  if (config.coordinateFontSize != null) {
    styleFields.add(
      'coordinateStyle: TextStyle(fontSize: ${_formatDouble(config.coordinateFontSize!)})',
    );
  }
  if (styleFields.isNotEmpty) {
    sections.add(_section('style', 'StretchableContainerStyle', styleFields));
  }

  if (config.backgroundMode == BackgroundMode.photo) {
    sections.add(
      "backgroundImage: const NetworkImage(sampleBackgroundImageUrl)",
    );
  }
  if (config.backgroundMode == BackgroundMode.none) {
    sections.add('backgroundImage: null');
  }

  sections.add("semanticsLabel: 'Stretchable container playground preview'");

  return 'StretchableContainer(\n${sections.map((line) => '  $line').join('\n')}\n)';
}

Widget buildCodePreview(PlaygroundConfig config, TextTheme textTheme) {
  final snippet = buildConfigSnippet(config);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
    ),
    child: SelectableText(
      snippet,
      style: textTheme.bodySmall?.copyWith(
        fontFamily: 'monospace',
        height: 1.45,
      ),
    ),
  );
}

String _section(String name, String constructor, List<String> fields) {
  if (fields.length == 1 && !fields.first.contains('\n')) {
    return '$name: $constructor(${fields.first}),';
  }

  final buffer = StringBuffer('$name: $constructor(\n');
  for (final field in fields) {
    buffer.writeln('    $field,');
  }
  buffer.write('  ),');
  return buffer.toString();
}

String _formatDouble(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

String _colorLiteral(Color color) {
  final hex = color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase();
  return 'const Color(0x$hex)';
}
