import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stretchable_container/stretchable_container.dart';

import 'code_preview.dart';
import 'config_model.dart';
import 'controls/color_row.dart';
import 'controls/enum_row.dart';
import 'controls/section.dart';
import 'controls/slider_row.dart';
import 'controls/switch_row.dart';

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  late final PlaygroundConfig _config;

  static const _colorChoices = [
    ColorChoice(label: 'Theme', color: null),
    ColorChoice(label: 'White', color: Colors.white),
    ColorChoice(label: 'Sky', color: Color(0xFF78A8FF)),
    ColorChoice(label: 'Mint', color: Color(0xFF73E0C1)),
    ColorChoice(label: 'Amber', color: Color(0xFFFFC857)),
    ColorChoice(label: 'Coral', color: Color(0xFFFF7F7F)),
    ColorChoice(label: 'Ink', color: Color(0xFF111827)),
  ];

  @override
  void initState() {
    super.initState();
    _config = PlaygroundConfig();
  }

  @override
  void dispose() {
    _config.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _config,
      builder: (context, _) {
        final snippet = buildConfigSnippet(_config);
        return Scaffold(
          appBar: AppBar(
            title: const Text('Stretchable Container Playground'),
            actions: [
              IconButton(
                tooltip: widget.themeMode == ThemeMode.dark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
                onPressed: () {
                  widget.onThemeModeChanged(
                    widget.themeMode == ThemeMode.dark
                        ? ThemeMode.light
                        : ThemeMode.dark,
                  );
                },
                icon: Icon(
                  widget.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
              IconButton(
                tooltip: 'Reset to defaults',
                onPressed: _config.reset,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Copy code',
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await Clipboard.setData(ClipboardData(text: snippet));
                  if (!mounted) {
                    return;
                  }
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Config copied as Dart snippet')),
                  );
                },
                icon: const Icon(Icons.copy_all_outlined),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 720;
              return Column(
                children: [
                  Expanded(
                    flex: compact ? 4 : 5,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compact ? 360 : 420,
                            maxHeight: compact ? 520 : 560,
                          ),
                          child: AspectRatio(
                            aspectRatio: 0.8,
                            child: StretchableContainer(
                              layout: _config.layout,
                              grid: _config.grid,
                              physics: _config.physics,
                              style: _config.style,
                              backgroundImage: _config.backgroundImage,
                              leading: const Text('PLAY'),
                              semanticsLabel:
                                  'Stretchable container playground preview',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: compact ? 6 : 5,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ControlSection(
                          title: 'Physics',
                          initiallyExpanded: true,
                          children: [
                            SliderRow(
                              label: 'Max offset',
                              value: _config.maxOffset,
                              min: 0,
                              max: 80,
                              valueLabel: _config.maxOffset.toStringAsFixed(0),
                              onChanged: (value) =>
                                  _config.update(() => _config.maxOffset = value),
                            ),
                            SliderRow(
                              label: 'Max scale delta',
                              value: _config.maxScaleDelta,
                              min: 0,
                              max: 0.5,
                              valueLabel:
                                  _config.maxScaleDelta.toStringAsFixed(2),
                              onChanged: (value) => _config
                                  .update(() => _config.maxScaleDelta = value),
                            ),
                            EnumRow<SnapMode>(
                              label: 'Snap mode',
                              value: _config.snapMode,
                              options: const [
                                EnumOption(
                                  value: SnapMode.curve,
                                  label: 'Curve',
                                ),
                                EnumOption(
                                  value: SnapMode.spring,
                                  label: 'Spring',
                                ),
                              ],
                              onChanged: (value) =>
                                  _config.update(() => _config.snapMode = value),
                            ),
                            if (_config.snapMode == SnapMode.curve)
                              SliderRow(
                                label: 'Snap duration',
                                value: _config.snapDurationMs,
                                min: 0,
                                max: 500,
                                divisions: 50,
                                valueLabel:
                                    '${_config.snapDurationMs.round()} ms',
                                onChanged: (value) => _config
                                    .update(() => _config.snapDurationMs = value),
                              ),
                            if (_config.snapMode == SnapMode.spring) ...[
                              SliderRow(
                                label: 'Spring mass',
                                value: _config.springMass,
                                min: 0.5,
                                max: 2,
                                valueLabel:
                                    _config.springMass.toStringAsFixed(2),
                                onChanged: (value) =>
                                    _config.update(() => _config.springMass = value),
                              ),
                              SliderRow(
                                label: 'Spring stiffness',
                                value: _config.springStiffness,
                                min: 80,
                                max: 400,
                                valueLabel:
                                    _config.springStiffness.toStringAsFixed(0),
                                onChanged: (value) => _config
                                    .update(() => _config.springStiffness = value),
                              ),
                              SliderRow(
                                label: 'Spring damping',
                                value: _config.springDamping,
                                min: 12,
                                max: 40,
                                valueLabel:
                                    _config.springDamping.toStringAsFixed(1),
                                onChanged: (value) => _config
                                    .update(() => _config.springDamping = value),
                              ),
                            ],
                            SliderRow(
                              label: 'Snap duration scale',
                              value: _config.snapDurationScale,
                              min: 0.25,
                              max: 2,
                              valueLabel:
                                  _config.snapDurationScale.toStringAsFixed(2),
                              onChanged: (value) => _config.update(
                                () => _config.snapDurationScale = value,
                              ),
                            ),
                            SliderRow(
                              label: 'Power',
                              value: _config.power,
                              min: 0,
                              max: 2,
                              valueLabel: _config.power.toStringAsFixed(2),
                              onChanged: (value) =>
                                  _config.update(() => _config.power = value),
                            ),
                            EnumRow<StretchResponse>(
                              label: 'Response',
                              value: _config.response,
                              options: const [
                                EnumOption(
                                  value: StretchResponse.linear,
                                  label: 'Linear',
                                ),
                                EnumOption(
                                  value: StretchResponse.exponential,
                                  label: 'Exponential',
                                ),
                                EnumOption(
                                  value: StretchResponse.rubberBand,
                                  label: 'Rubber',
                                ),
                                EnumOption(
                                  value: StretchResponse.logarithmic,
                                  label: 'Logarithmic',
                                ),
                              ],
                              onChanged: (value) =>
                                  _config.update(() => _config.response = value),
                            ),
                            EnumRow<StretchAxes>(
                              label: 'Axes',
                              value: _config.axes,
                              options: const [
                                EnumOption(
                                  value: StretchAxes.both,
                                  label: 'Both',
                                ),
                                EnumOption(
                                  value: StretchAxes.horizontal,
                                  label: 'Horizontal',
                                ),
                                EnumOption(
                                  value: StretchAxes.vertical,
                                  label: 'Vertical',
                                ),
                              ],
                              onChanged: (value) =>
                                  _config.update(() => _config.axes = value),
                            ),
                            EnumRow<StretchAnchor>(
                              label: 'Anchor',
                              value: _config.anchor,
                              options: const [
                                EnumOption(
                                  value: StretchAnchor.center,
                                  label: 'Center',
                                ),
                                EnumOption(
                                  value: StretchAnchor.edge,
                                  label: 'Edge',
                                ),
                                EnumOption(
                                  value: StretchAnchor.cornerGrab,
                                  label: 'Corner',
                                ),
                              ],
                              onChanged: (value) =>
                                  _config.update(() => _config.anchor = value),
                            ),
                            SwitchRow(
                              label: 'Haptics enabled',
                              value: _config.hapticsEnabled,
                              onChanged: (value) => _config
                                  .update(() => _config.hapticsEnabled = value),
                            ),
                          ],
                        ),
                        ControlSection(
                          title: 'Dot Grid',
                          children: [
                            SliderRow(
                              label: 'Rows',
                              value: _config.rows.toDouble(),
                              min: 1,
                              max: 16,
                              divisions: 15,
                              valueLabel: _config.rows.toString(),
                              onChanged: (value) =>
                                  _config.update(() => _config.rows = value.round()),
                            ),
                            SliderRow(
                              label: 'Columns',
                              value: _config.columns.toDouble(),
                              min: 1,
                              max: 16,
                              divisions: 15,
                              valueLabel: _config.columns.toString(),
                              onChanged: (value) => _config
                                  .update(() => _config.columns = value.round()),
                            ),
                            SliderRow(
                              label: 'Padding',
                              value: _config.gridPadding,
                              min: 0,
                              max: 60,
                              valueLabel:
                                  _config.gridPadding.toStringAsFixed(0),
                              onChanged: (value) =>
                                  _config.update(() => _config.gridPadding = value),
                            ),
                            SliderRow(
                              label: 'Base dot size',
                              value: _config.baseDotSize,
                              min: 0,
                              max: 12,
                              valueLabel:
                                  _config.baseDotSize.toStringAsFixed(1),
                              onChanged: (value) =>
                                  _config.update(() => _config.baseDotSize = value),
                            ),
                            SliderRow(
                              label: 'Max dot growth',
                              value: _config.maxDotGrowth,
                              min: 0,
                              max: 30,
                              valueLabel:
                                  _config.maxDotGrowth.toStringAsFixed(1),
                              onChanged: (value) =>
                                  _config.update(() => _config.maxDotGrowth = value),
                            ),
                            SliderRow(
                              label: 'Influence radius',
                              value: _config.influenceRadius,
                              min: 20,
                              max: 240,
                              valueLabel:
                                  _config.influenceRadius.toStringAsFixed(0),
                              onChanged: (value) => _config
                                  .update(() => _config.influenceRadius = value),
                            ),
                          ],
                        ),
                        ControlSection(
                          title: 'Layout',
                          children: [
                            SwitchRow(
                              label: 'Fixed size (300×400)',
                              value: _config.fixedSize,
                              onChanged: (value) =>
                                  _config.update(() => _config.fixedSize = value),
                            ),
                            SliderRow(
                              label: 'Border radius',
                              value: _config.borderRadius,
                              min: 0,
                              max: 80,
                              valueLabel:
                                  _config.borderRadius.toStringAsFixed(0),
                              onChanged: (value) =>
                                  _config.update(() => _config.borderRadius = value),
                            ),
                            SliderRow(
                              label: 'Footer height',
                              value: _config.footerHeight,
                              min: 24,
                              max: 80,
                              valueLabel:
                                  _config.footerHeight.toStringAsFixed(0),
                              onChanged: (value) =>
                                  _config.update(() => _config.footerHeight = value),
                            ),
                            SliderRow(
                              label: 'Content padding',
                              value: _config.contentPadding,
                              min: 0,
                              max: 32,
                              valueLabel:
                                  _config.contentPadding.toStringAsFixed(0),
                              onChanged: (value) => _config
                                  .update(() => _config.contentPadding = value),
                            ),
                          ],
                        ),
                        ControlSection(
                          title: 'Style',
                          children: [
                            ColorRow(
                              label: 'Dot color',
                              value: _config.dotColor,
                              choices: _colorChoices,
                              onChanged: (value) =>
                                  _config.update(() => _config.dotColor = value),
                            ),
                            ColorRow(
                              label: 'Border color',
                              value: _config.borderColor,
                              choices: _colorChoices,
                              onChanged: (value) => _config
                                  .update(() => _config.borderColor = value),
                            ),
                            SliderRow(
                              label: 'Title font size',
                              value: _config.titleFontSize ?? 16,
                              min: 12,
                              max: 20,
                              valueLabel: _config.titleFontSize == null
                                  ? 'Theme'
                                  : _config.titleFontSize!.toStringAsFixed(1),
                              onChanged: (value) => _config
                                  .update(() => _config.titleFontSize = value),
                            ),
                            TextButton(
                              onPressed: () => _config
                                  .update(() => _config.titleFontSize = null),
                              child: const Text('Use theme title style'),
                            ),
                            SliderRow(
                              label: 'Coordinate font size',
                              value: _config.coordinateFontSize ?? 16,
                              min: 12,
                              max: 20,
                              valueLabel: _config.coordinateFontSize == null
                                  ? 'Theme'
                                  : _config.coordinateFontSize!.toStringAsFixed(1),
                              onChanged: (value) => _config.update(
                                () => _config.coordinateFontSize = value,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _config
                                  .update(() => _config.coordinateFontSize = null),
                              child: const Text('Use theme coordinate style'),
                            ),
                            SwitchRow(
                              label: 'Enable shadows',
                              value: _config.shadowsEnabled,
                              onChanged: (value) => _config
                                  .update(() => _config.shadowsEnabled = value),
                            ),
                            EnumRow<BackgroundMode>(
                              label: 'Background',
                              value: _config.backgroundMode,
                              options: const [
                                EnumOption(
                                  value: BackgroundMode.none,
                                  label: 'None',
                                ),
                                EnumOption(
                                  value: BackgroundMode.darkSolid,
                                  label: 'Dark solid',
                                ),
                                EnumOption(
                                  value: BackgroundMode.photo,
                                  label: 'Photo',
                                ),
                              ],
                              onChanged: (value) => _config
                                  .update(() => _config.backgroundMode = value),
                            ),
                          ],
                        ),
                        ControlSection(
                          title: 'Code Preview',
                          children: [
                            buildCodePreview(_config, Theme.of(context).textTheme),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
