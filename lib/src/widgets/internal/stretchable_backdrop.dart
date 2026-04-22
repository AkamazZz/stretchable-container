import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class StretchableBackdrop extends StatelessWidget {
  const StretchableBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: const SizedBox.expand(),
        ),
        ColoredBox(color: Colors.black.withValues(alpha: 0.1)),
      ],
    );
  }
}
