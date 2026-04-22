import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/stretchable_container.dart';
import 'package:stretchable_container/src/controllers/stretch_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rest golden', (tester) async {
    await _pumpHarness(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/rest.png'),
    );
  });

  testWidgets('drag corner golden', (tester) async {
    await _pumpHarness(tester);
    await _dragToBottomRight(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/drag_corner.png'),
    );
  });

  testWidgets('mid snap golden', (tester) async {
    await _pumpHarness(tester);
    final gesture = await _startDrag(tester);
    await gesture.moveTo(_bottomRight(tester));
    await tester.pump();
    await gesture.up();
    _controllerOf(tester).debugSetSnapValue(0.5);
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mid_snap.png'),
    );
  });

  testWidgets('mid snap curve golden', (tester) async {
    await _pumpHarness(
      tester,
      physics: StretchPhysics(snapMode: SnapMode.curve),
    );
    final gesture = await _startDrag(tester);
    await gesture.moveTo(_bottomRight(tester));
    await tester.pump();
    await gesture.up();
    _controllerOf(tester).debugSetSnapValue(0.5);
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mid_snap_curve.png'),
    );
  });

  testWidgets('exponential corner golden', (tester) async {
    await _pumpHarness(
      tester,
      physics: StretchPhysics(response: StretchResponse.exponential),
    );
    await _dragToBottomRight(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/exponential_corner.png'),
    );
  });

  testWidgets('horizontal right-edge golden', (tester) async {
    await _pumpHarness(
      tester,
      physics: StretchPhysics(
        axes: StretchAxes.horizontal,
        response: StretchResponse.exponential,
      ),
    );
    final gesture = await _startDrag(tester);
    final center = tester.getCenter(find.byType(GestureDetector));
    await gesture.moveTo(Offset(_bottomRight(tester).dx, center.dy));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/horizontal_right_edge.png'),
    );
  });
}

Future<void> _pumpHarness(
  WidgetTester tester, {
  StretchPhysics physics = StretchPhysics.defaults,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 500));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: Center(
          child: StretchableContainer(
            layout: const StretchLayout(width: 300, height: 400),
            physics: physics,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<TestGesture> _startDrag(WidgetTester tester) {
  return tester.startGesture(_topLeft(tester) + const Offset(20, 20));
}

Future<void> _dragToBottomRight(WidgetTester tester) async {
  final gesture = await _startDrag(tester);
  await gesture.moveTo(_bottomRight(tester));
  await tester.pump();
}

Offset _topLeft(WidgetTester tester) {
  return tester.getTopLeft(find.byType(GestureDetector));
}

Offset _bottomRight(WidgetTester tester) {
  return tester.getBottomRight(find.byType(GestureDetector)) -
      const Offset(20, 20);
}

StretchController _controllerOf(WidgetTester tester) {
  final context = tester.element(find.byType(GestureDetector));
  return StretchableContainerScope.of(context) as StretchController;
}
