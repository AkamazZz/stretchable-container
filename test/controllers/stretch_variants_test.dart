import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/src/controllers/stretch_controller.dart';
import 'package:stretchable_container/src/models/stretch_physics.dart';

void main() {
  StretchController createController(
    WidgetTester tester, {
    StretchPhysics physics = StretchPhysics.defaults,
  }) {
    final controller = StretchController(vsync: tester, physics: physics);
    addTearDown(controller.dispose);
    return controller;
  }

  testWidgets('linear corner drag reaches max offset on both axes', (
    tester,
  ) async {
    final controller = createController(tester);

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(300, 400),
        globalPosition: const Offset(300, 400),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset, const Offset(20, 20));
  });

  testWidgets('exponential at half drag is about quarter max offset', (
    tester,
  ) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(response: StretchResponse.exponential),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(225, 300),
        globalPosition: const Offset(225, 300),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset.dx, closeTo(5, 1));
    expect(controller.value.offset.dy, closeTo(5, 1));
  });

  testWidgets('rubber-band at full drag stays below max offset', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(response: StretchResponse.rubberBand),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(300, 400),
        globalPosition: const Offset(300, 400),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset.dx, lessThan(20));
    expect(controller.value.offset.dy, lessThan(20));
  });

  testWidgets('logarithmic responds more than linear near center', (
    tester,
  ) async {
    final linear = createController(tester);
    linear.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(165, 220),
        globalPosition: const Offset(165, 220),
      ),
      const Size(300, 400),
    );

    final logarithmic = createController(
      tester,
      physics: StretchPhysics(response: StretchResponse.logarithmic),
    );
    logarithmic.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(165, 220),
        globalPosition: const Offset(165, 220),
      ),
      const Size(300, 400),
    );

    expect(logarithmic.value.offset.dx, greaterThan(linear.value.offset.dx));
    expect(logarithmic.value.offset.dy, greaterThan(linear.value.offset.dy));
  });

  testWidgets('horizontal axis lock zeroes vertical offset', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(axes: StretchAxes.horizontal),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(300, 400),
        globalPosition: const Offset(300, 400),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset.dy, 0);
  });

  testWidgets('vertical axis lock zeroes horizontal offset', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(axes: StretchAxes.vertical),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(300, 400),
        globalPosition: const Offset(300, 400),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset.dx, 0);
  });

  testWidgets('power zero disables stretch', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(power: 0),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(300, 400),
        globalPosition: const Offset(300, 400),
      ),
      const Size(300, 400),
    );

    expect(controller.value.offset, Offset.zero);
  });

  testWidgets('power two saturates sooner than power one', (tester) async {
    final regular = createController(tester);
    regular.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(225, 300),
        globalPosition: const Offset(225, 300),
      ),
      const Size(300, 400),
    );

    final boosted = createController(
      tester,
      physics: StretchPhysics(power: 2),
    );
    boosted.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(225, 300),
        globalPosition: const Offset(225, 300),
      ),
      const Size(300, 400),
    );

    expect(boosted.value.offset.dx, greaterThan(regular.value.offset.dx));
    expect(boosted.value.offset.dy, greaterThan(regular.value.offset.dy));
  });

  testWidgets('edge anchor pins the opposite edge', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(anchor: StretchAnchor.edge),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(260, 200),
        globalPosition: const Offset(260, 200),
      ),
      const Size(300, 400),
    );

    expect(controller.value.transformAlignment, Alignment.centerLeft);
  });

  testWidgets('corner grab pins the opposite corner', (tester) async {
    final controller = createController(
      tester,
      physics: StretchPhysics(anchor: StretchAnchor.cornerGrab),
    );

    controller.onPanUpdate(
      DragUpdateDetails(
        localPosition: const Offset(280, 360),
        globalPosition: const Offset(280, 360),
      ),
      const Size(300, 400),
    );

    expect(controller.value.transformAlignment, const Alignment(-1, -1));
  });
}
