import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/stretchable_container.dart';

void main() {
  test('StretchLayout rejects negative width', () {
    expect(() => StretchLayout(width: -1), throwsAssertionError);
  });

  test('DotGridSpec rejects zero rows', () {
    expect(() => DotGridSpec(rows: 0), throwsAssertionError);
  });

  test('DotGridSpec rejects zero columns', () {
    expect(() => DotGridSpec(columns: 0), throwsAssertionError);
  });

  test('DotGridSpec rejects non-positive influence radius', () {
    expect(() => DotGridSpec(influenceRadius: 0), throwsAssertionError);
  });

  test('StretchPhysics rejects negative max offset', () {
    expect(() => StretchPhysics(maxOffset: -1), throwsAssertionError);
  });

  test('StretchPhysics rejects invalid power', () {
    expect(() => StretchPhysics(power: 3), throwsAssertionError);
  });

  test('StretchPhysics rejects zero snap duration scale', () {
    expect(
      () => StretchPhysics(snapDurationScale: 0),
      throwsAssertionError,
    );
  });

  test('StretchableContainerStyle accepts nullable inputs', () {
    expect(const StretchableContainerStyle(), isA<StretchableContainerStyle>());
  });
}
