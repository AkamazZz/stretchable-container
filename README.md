## Stretchable Container

Flutter package for a frosted draggable container with a reactive dot grid.

## Structure

`lib/stretchable_container.dart` exposes the public API only.

`lib/src/widgets/stretchable_container.dart` contains the main widget and interaction state.

`lib/src/models/` contains layout, grid, physics, and style configuration values.

`lib/src/widgets/stretchable_dot_grid.dart` contains the internal grid rendering.

`lib/src/utils/grid_coordinates.dart` contains coordinate formatting logic.

## Usage

```dart
import 'package:flutter/material.dart';
import 'package:stretchable_container/stretchable_container.dart';

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: StretchableContainer(),
    );
  }
}
```

The runnable sample app lives under `example/`. Run it with `cd example && flutter run`.
