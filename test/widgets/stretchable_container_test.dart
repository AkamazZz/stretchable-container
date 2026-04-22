import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/stretchable_container.dart';
import 'package:stretchable_container/src/painters/stretchable_dot_grid_painter.dart';

void main() {
  testWidgets('renders the default footer title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StretchableContainer()),
      ),
    );

    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('X: 0 / Y: 0'), findsOneWidget);
  });

  testWidgets('renders a custom leading widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StretchableContainer(
            leading: Text('CUSTOM'),
          ),
        ),
      ),
    );

    expect(find.text('CUSTOM'), findsOneWidget);
  });

  testWidgets('renders a custom trailing widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StretchableContainer(
            trailing: Text('TRAIL'),
          ),
        ),
      ),
    );

    expect(find.text('TRAIL'), findsOneWidget);
    expect(find.text('X: 0 / Y: 0'), findsNothing);
  });

  testWidgets('renders inside Expanded with unconstrained layout config', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: StretchableContainer(layout: StretchLayout()),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(StretchableContainer), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gesture detector is hit testable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StretchableContainer()),
      ),
    );

    expect(find.byType(GestureDetector), findsOneWidget);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GestureDetector)),
    );
    await tester.pump();

    expect(find.textContaining('X:'), findsOneWidget);
    await gesture.up();
  });

  testWidgets('uses the theme onSurface color for dots by default', (
    tester,
  ) async {
    final theme = ThemeData(
      colorScheme: const ColorScheme.light(
        onSurface: Color(0xFF123456),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: const Scaffold(body: StretchableContainer()),
      ),
    );

    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(StretchableContainer),
        matching: find.byType(CustomPaint),
      ),
    );

    final painter = customPaint.painter!;
    expect((painter as StretchableDotGridPainter).dotColor, theme.colorScheme.onSurface);
  });

  testWidgets('exposes configured semantics label and hint', (tester) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StretchableContainer(
            semanticsLabel: 'Card stretch',
            semanticsHint: 'Drag it',
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Card stretch' &&
            widget.properties.hint == 'Drag it',
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('triggers haptic feedback once on drag start', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    addTearDown(() {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StretchableContainer(
            physics: StretchPhysics(hapticsEnabled: true),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(GestureDetector)),
    );
    await gesture.moveBy(const Offset(20, 20));
    await tester.pump();
    await gesture.up();

    expect(
      calls.where((call) => call.method.contains('HapticFeedback.vibrate')),
      isNotEmpty,
    );
  });

  testWidgets('rebuild storms do not trigger framework errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _RebuildStormHarness()));

    for (var index = 0; index < 20; index++) {
      await tester.tap(find.byKey(const Key('storm-button')));
      await tester.pump();
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('animated parent size changes do not trigger framework errors', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: _AnimatedSizeHarness()));

    await tester.tap(find.byKey(const Key('animate-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });
}

class _RebuildStormHarness extends StatefulWidget {
  const _RebuildStormHarness();

  @override
  State<_RebuildStormHarness> createState() => _RebuildStormHarnessState();
}

class _RebuildStormHarnessState extends State<_RebuildStormHarness> {
  var _tick = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('$_tick'),
          Expanded(child: Container(color: Colors.black12, child: const StretchableContainer(layout: StretchLayout()))),
          TextButton(
            key: const Key('storm-button'),
            onPressed: () => setState(() => _tick++),
            child: const Text('rebuild'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedSizeHarness extends StatefulWidget {
  const _AnimatedSizeHarness();

  @override
  State<_AnimatedSizeHarness> createState() => _AnimatedSizeHarnessState();
}

class _AnimatedSizeHarnessState extends State<_AnimatedSizeHarness> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            key: const Key('animate-button'),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: const Text('animate'),
          ),
          Expanded(
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _expanded ? 360 : 300,
                height: _expanded ? 460 : 400,
                child: const StretchableContainer(layout: StretchLayout()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
