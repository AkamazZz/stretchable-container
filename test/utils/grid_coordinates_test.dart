import 'package:flutter_test/flutter_test.dart';
import 'package:stretchable_container/src/models/dot_grid_spec.dart';
import 'package:stretchable_container/src/utils/grid_coordinates.dart';

void main() {
  test('calculateGridGeometry handles a 1x1 grid', () {
    final geometry = calculateGridGeometry(
      width: 100,
      height: 120,
      padding: 10,
      rows: 1,
      columns: 1,
    );

    expect(geometry.stepX, 80);
    expect(geometry.stepY, 100);
    expect(geometry.points, const [Offset(10, 10)]);
  });

  test('calculateGridGeometry creates evenly spaced 3x3 points', () {
    final geometry = calculateGridGeometry(
      width: 100,
      height: 100,
      padding: 10,
      rows: 3,
      columns: 3,
    );

    expect(geometry.points, hasLength(9));
    expect(geometry.stepX, 40);
    expect(geometry.stepY, 40);
    expect(geometry.points.first, const Offset(10, 10));
    expect(geometry.points.last, const Offset(90, 90));
  });

  test('calculateGridGeometry tolerates oversized padding', () {
    final geometry = calculateGridGeometry(
      width: 20,
      height: 20,
      padding: 15,
      rows: 2,
      columns: 2,
    );

    expect(geometry.points, hasLength(4));
  });

  test('formatGridCoordinates resolves the top-left cell', () {
    const grid = DotGridSpec(rows: 3, columns: 3, padding: 20);

    expect(
      formatGridCoordinates(
        const Offset(20, 20),
        grid: grid,
        width: 200,
        height: 200,
      ),
      'X: 0 / Y: 0',
    );
  });

  test('formatGridCoordinates resolves the bottom-right cell', () {
    const grid = DotGridSpec(rows: 3, columns: 3, padding: 20);

    expect(
      formatGridCoordinates(
        const Offset(180, 180),
        grid: grid,
        width: 200,
        height: 200,
      ),
      'X: 2 / Y: 2',
    );
  });

  test('formatGridCoordinates clamps positions outside the usable area', () {
    const grid = DotGridSpec(rows: 3, columns: 3, padding: 20);

    expect(
      formatGridCoordinates(
        const Offset(-100, 400),
        grid: grid,
        width: 200,
        height: 200,
      ),
      'X: 0 / Y: 2',
    );
  });
}
