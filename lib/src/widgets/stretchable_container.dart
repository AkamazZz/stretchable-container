import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/stretchable_container_config.dart';
import '../utils/grid_coordinates.dart';
import 'stretchable_dot_grid.dart';

class StretchableContainer extends StatefulWidget {
  const StretchableContainer({
    super.key,
    this.config = const StretchableContainerConfig(),
    this.title = 'FOCUS',
    this.backgroundImage,
  });

  final StretchableContainerConfig config;
  final String title;
  final ImageProvider? backgroundImage;

  @override
  State<StretchableContainer> createState() => _StretchableContainerState();
}

class _StretchableContainerState extends State<StretchableContainer>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  double _offsetX = 0;
  double _offsetY = 0;
  bool _isDragging = false;
  Offset? _dragLocalPosition;
  double _animationStartX = 0;
  double _animationStartY = 0;

  StretchableContainerConfig get _config => widget.config;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.addListener(() {
      if (_isDragging) {
        return;
      }

      setState(() {
        _offsetX = _animationStartX * (1 - _animation.value);
        _offsetY = _animationStartY * (1 - _animation.value);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;

      final dx = details.localPosition.dx.clamp(0.0, _config.width);
      final dy = details.localPosition.dy.clamp(0.0, _config.height);
      _dragLocalPosition = Offset(dx, dy);

      final centerX = _config.width / 2;
      final centerY = _config.height / 2;
      final directionX = (dx - centerX) / centerX;
      final directionY = (dy - centerY) / centerY;

      _offsetX = (directionX * _config.maxOffset).clamp(
        -_config.maxOffset,
        _config.maxOffset,
      );
      _offsetY = (directionY * _config.maxOffset).clamp(
        -_config.maxOffset,
        _config.maxOffset,
      );
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _animationStartX = _offsetX;
      _animationStartY = _offsetY;
    });

    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final proximityStrength = _isDragging ? 1.0 : (1.0 - _animation.value);

    return Stack(
      children: [
        DecoratedBox(
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
        AnimatedPositioned(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          left: size.width / 2 - _config.width / 2 + _offsetX,
          top: size.height / 2 - _config.height / 2 + _offsetY,
          child: Transform(
            alignment: Alignment(
              _offsetX > 0 ? -0.5 : 0.5,
              _offsetY > 0 ? -0.5 : 0.5,
            ),
            transform: Matrix4.identity()
              ..scaleByDouble(
                1.0 +
                    (_offsetX.abs() /
                        _config.maxOffset *
                        _config.maxScaleDelta),
                1.0 +
                    (_offsetY.abs() /
                        _config.maxOffset *
                        _config.maxScaleDelta),
                1.0,
                1.0,
              ),
            child: GestureDetector(
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Container(
                width: _config.width,
                height: _config.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_config.borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_config.borderRadius),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: const SizedBox.expand(),
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.1)),
                      Padding(
                        padding: _config.contentPadding,
                        child: Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) =>
                                    StretchableDotGrid(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      config: _config,
                                      dragLocalPosition: _dragLocalPosition,
                                      proximityStrength: proximityStrength,
                                    ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              height: 1,
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
                            SizedBox(
                              height: _config.footerHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _dragLocalPosition != null
                                              ? formatGridCoordinates(
                                                  _dragLocalPosition!,
                                                  _config,
                                                )
                                              : 'X: 0 / Y: 0',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
