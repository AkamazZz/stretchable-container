import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/src/controllers/stretch_controller.dart';
import 'package:stretchable_container/src/models/stretch_physics.dart';

void main() {
  group('StretchController', () {
    testWidgets('starts at rest', (tester) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      expect(controller.value.offset, Offset.zero);
      expect(controller.value.scaleX, 1);
      expect(controller.value.scaleY, 1);
      expect(controller.value.isDragging, isFalse);
    });

    testWidgets('dragging to center-right edge reaches max horizontal offset', (
      tester,
    ) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 200),
          globalPosition: const Offset(300, 200),
        ),
        const Size(300, 400),
      );

      expect(controller.value.offset.dx, 20);
      expect(controller.value.offset.dy, 0);
    });

    testWidgets('dragging to bottom-right corner reaches max offset on both axes', (
      tester,
    ) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );

      expect(controller.value.offset, const Offset(20, 20));
    });

    testWidgets('drag positions clamp to the widget bounds', (tester) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(999, -100),
          globalPosition: const Offset(999, -100),
        ),
        const Size(300, 400),
      );

      expect(controller.value.dragLocalPosition, const Offset(300, 0));
      expect(controller.value.offset, const Offset(20, -20));
    });

    testWidgets('onPanEnd flips isDragging off and snaps back after the duration', (
      tester,
    ) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );

      controller.onPanEnd(DragEndDetails(primaryVelocity: 0));

      expect(controller.value.isDragging, isFalse);
      expect(controller.value.offset, const Offset(20, 20));

      controller.debugSetSnapValue(1);

      expect(controller.value.offset.dx, closeTo(0, 0.001));
      expect(controller.value.offset.dy, closeTo(0, 0.001));
    });

    testWidgets('a new drag stops an in-flight snap without jumping', (
      tester,
    ) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics.defaults,
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );
      controller.onPanEnd(DragEndDetails());

      controller.debugSetSnapValue(0.5);
      final midSnapOffset = controller.value.offset;

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );

      expect(controller.value.isDragging, isTrue);
      expect(controller.value.offset.dx, greaterThanOrEqualTo(midSnapOffset.dx));
      expect(controller.value.offset.dy, greaterThanOrEqualTo(midSnapOffset.dy));
    });

    testWidgets('spring mode starts an active animation', (tester) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics(snapMode: SnapMode.spring),
      );

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );

      controller.onPanEnd(DragEndDetails());

      expect(controller.isAnimating, isTrue);
      controller.dispose();
    });

    testWidgets('curve mode reaches zero at snap duration', (tester) async {
      final controller = StretchController(
        vsync: tester,
        physics: StretchPhysics(snapMode: SnapMode.curve),
      );
      addTearDown(controller.dispose);

      controller.onPanUpdate(
        DragUpdateDetails(
          localPosition: const Offset(300, 400),
          globalPosition: const Offset(300, 400),
        ),
        const Size(300, 400),
      );
      controller.onPanEnd(DragEndDetails());
      controller.debugSetSnapValue(1);

      expect(controller.value.offset, const Offset(0, 0));
    });
  });
}
