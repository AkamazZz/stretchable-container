import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/stretch_controller.dart';
import '../models/dot_grid_spec.dart';
import '../models/stretch_layout.dart';
import '../models/stretch_physics.dart';
import '../models/stretchable_container_config.dart';
import '../models/stretchable_container_style.dart';
import '../utils/grid_coordinates.dart';
import 'internal/stretchable_backdrop.dart';
import 'internal/stretchable_footer.dart';
import 'internal/stretchable_frame.dart';
import 'stretchable_dot_grid.dart';

class StretchableContainer extends StatefulWidget {
  const StretchableContainer({
    super.key,
    this.layout = const StretchLayout(width: 300, height: 400),
    this.grid = const DotGridSpec(),
    this.physics = StretchPhysics.defaults,
    this.style = const StretchableContainerStyle(),
    @Deprecated('Use leading instead.') this.title,
    this.leading,
    this.trailing,
    this.backgroundImage,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @Deprecated('Use StretchLayout / DotGridSpec / StretchPhysics instead.')
  factory StretchableContainer.fromConfig(
    StretchableContainerConfig config, {
    Key? key,
    String title = 'FOCUS',
    Widget? trailing,
    ImageProvider? backgroundImage,
    StretchableContainerStyle style = const StretchableContainerStyle(),
  }) {
    return StretchableContainer(
      key: key,
      layout: config.toLayout(),
      grid: config.toGridSpec(),
      physics: config.toPhysics(),
      style: style,
      title: title,
      trailing: trailing,
      backgroundImage: backgroundImage,
      semanticsLabel: 'Stretchable container',
      semanticsHint: 'Drag to stretch. Release to snap back.',
    );
  }

  final StretchLayout layout;
  final DotGridSpec grid;
  final StretchPhysics physics;
  final StretchableContainerStyle style;
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final ImageProvider? backgroundImage;
  final String? semanticsLabel;
  final String? semanticsHint;

  @override
  State<StretchableContainer> createState() => _StretchableContainerState();
}

class _StretchableContainerState extends State<StretchableContainer>
    with TickerProviderStateMixin {
  late StretchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _createController(widget.physics);
  }

  @override
  void didUpdateWidget(covariant StretchableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.physics != widget.physics) {
      final previousController = _controller;
      _controller = _createController(widget.physics);
      previousController.dispose();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = _ResolvedStretchableStyle.resolve(
      context,
      widget.style,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolveDimension(
          explicit: widget.layout.width,
          fallback: constraints.maxWidth,
          axisLabel: 'width',
        );
        final height = _resolveDimension(
          explicit: widget.layout.height,
          fallback: constraints.maxHeight,
          axisLabel: 'height',
        );
        final size = Size(width, height);
        final stackWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : width;
        final stackHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : height;

        return StretchableContainerScope(
          controller: _controller,
          child: SizedBox(
            width: stackWidth,
            height: stackHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      image: widget.backgroundImage == null
                          ? null
                          : DecorationImage(
                              image: widget.backgroundImage!,
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                Center(
                  child: ValueListenableBuilder<StretchState>(
                    valueListenable: _controller,
                    builder: (context, state, child) {
                      return Transform.translate(
                        offset: state.offset,
                        child: Transform(
                          alignment: state.transformAlignment,
                          transform: Matrix4.diagonal3Values(
                            state.scaleX,
                            state.scaleY,
                            1,
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: MergeSemantics(
                      child: Semantics(
                        container: true,
                        label: widget.semanticsLabel ?? 'Stretchable container',
                        hint:
                            widget.semanticsHint ??
                            'Drag to stretch. Release to snap back.',
                        onIncrease: () => _controller.semanticNudge(1),
                        onDecrease: () => _controller.semanticNudge(-1),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (details) =>
                              _controller.onPanUpdate(details, size),
                          onPanEnd: _controller.onPanEnd,
                          onPanCancel: _controller.onPanCancel,
                          child: _StretchableContainerBody(
                            width: width,
                            height: height,
                            layout: widget.layout,
                            grid: widget.grid,
                            leading: _buildLeading(resolvedStyle.titleStyle),
                            trailing: widget.trailing,
                            style: resolvedStyle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(TextStyle style) {
    if (widget.leading != null) {
      return widget.leading!;
    }

    return Text(
      widget.title ?? 'FOCUS',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  StretchController _createController(StretchPhysics physics) {
    return StretchController(vsync: this, physics: physics);
  }

  double _resolveDimension({
    required double? explicit,
    required double fallback,
    required String axisLabel,
  }) {
    if (explicit != null) {
      return explicit;
    }

    if (fallback.isFinite) {
      return fallback;
    }

    throw FlutterError(
      'StretchableContainer needs a bounded $axisLabel when layout.$axisLabel is null.',
    );
  }
}

class _StretchableContainerBody extends StatelessWidget {
  const _StretchableContainerBody({
    required this.width,
    required this.height,
    required this.layout,
    required this.grid,
    required this.leading,
    required this.trailing,
    required this.style,
  });

  final double width;
  final double height;
  final StretchLayout layout;
  final DotGridSpec grid;
  final Widget leading;
  final Widget? trailing;
  final _ResolvedStretchableStyle style;

  @override
  Widget build(BuildContext context) {
    const dividerHeight = 1.0;
    final controller = StretchableContainerScope._controllerOf(context);

    return StretchableFrame(
      width: width,
      height: height,
      borderRadius: layout.borderRadius,
      borderColor: style.borderColor,
      shadows: style.shadows,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const StretchableBackdrop(),
          Padding(
            padding: layout.contentPadding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth = constraints.maxWidth;
                final gridHeight =
                    (constraints.maxHeight - layout.footerHeight - dividerHeight)
                        .clamp(0.0, constraints.maxHeight);

                return Column(
                  children: [
                    SizedBox(
                      width: gridWidth,
                      height: gridHeight,
                      child: StretchableDotGrid(
                        width: gridWidth,
                        height: gridHeight,
                        grid: grid,
                        dotColor: style.dotColor,
                        frame: controller.dotGridFrame,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      height: dividerHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    StretchableFooter(
                      height: layout.footerHeight,
                      leading: leading,
                      trailing:
                          trailing ??
                          _CoordinateLabel(
                            grid: grid,
                            width: gridWidth,
                            height: gridHeight,
                            style: style.coordinateStyle,
                          ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CoordinateLabel extends StatelessWidget {
  const _CoordinateLabel({
    required this.grid,
    required this.width,
    required this.height,
    required this.style,
  });

  final DotGridSpec grid;
  final double width;
  final double height;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final listenable = StretchableContainerScope.of(context);

    return ValueListenableBuilder<StretchState>(
      valueListenable: listenable,
      builder: (context, state, child) {
        final label = state.dragLocalPosition == null
            ? 'X: 0 / Y: 0'
            : formatGridCoordinates(
                state.dragLocalPosition!,
                grid: grid,
                width: width,
                height: height,
              );
        return Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        );
      },
    );
  }
}

class StretchableContainerScope extends InheritedNotifier<StretchController> {
  const StretchableContainerScope({
    super.key,
    required StretchController controller,
    required super.child,
  }) : super(notifier: controller);

  static ValueListenable<StretchState> of(BuildContext context) {
    return _controllerOf(context);
  }

  static StretchController _controllerOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<StretchableContainerScope>();
    if (scope == null || scope.notifier == null) {
      throw FlutterError(
        'StretchableContainerScope.of() called outside a StretchableContainer.',
      );
    }

    return scope.notifier!;
  }
}

class _ResolvedStretchableStyle {
  const _ResolvedStretchableStyle({
    required this.dotColor,
    required this.borderColor,
    required this.shadows,
    required this.titleStyle,
    required this.coordinateStyle,
  });

  final Color dotColor;
  final Color borderColor;
  final List<BoxShadow> shadows;
  final TextStyle titleStyle;
  final TextStyle coordinateStyle;

  static _ResolvedStretchableStyle resolve(
    BuildContext context,
    StretchableContainerStyle style,
  ) {
    final theme = Theme.of(context);
    final baseText = theme.textTheme.labelLarge ?? const TextStyle(fontSize: 16);

    return _ResolvedStretchableStyle(
      dotColor: style.dotColor ?? theme.colorScheme.onSurface,
      borderColor: style.borderColor ?? Colors.white.withValues(alpha: 0.2),
      shadows: style.shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
      titleStyle: style.titleStyle ??
          baseText.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
      coordinateStyle: style.coordinateStyle ??
          baseText.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}
