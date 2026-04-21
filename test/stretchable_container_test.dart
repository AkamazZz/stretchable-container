import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/stretchable_container.dart';

void main() {
  testWidgets('renders stretchable container title', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StretchableContainer(title: 'FOCUS')),
      ),
    );

    expect(find.text('FOCUS'), findsOneWidget);
    expect(find.text('X: 0 / Y: 0'), findsOneWidget);
  });
}
