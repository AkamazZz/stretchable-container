## Stretchable Container

Flutter package for a frosted draggable container with a reactive dot grid.

## Structure

`lib/stretchable_container.dart` exposes the public API only.

`lib/src/widgets/stretchable_container.dart` contains the main widget and interaction state.

`lib/src/models/stretchable_container_config.dart` contains configurable sizing and behavior values.

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
