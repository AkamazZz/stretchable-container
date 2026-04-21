# Lib Reorganization Spec

## Context

The package currently has a small `lib` surface, with implementation files already shifted into:

- `lib/src/models`
- `lib/src/utils`
- `lib/src/widgets`

The requested target organization is a `lib/src` structure centered around:

- `controllers`
- `models`
- `painters`
- `utils`
- `widgets`

This spec defines the directory contract, file placement rules, and the concrete migration plan before continuing implementation.

## Goals

- Reorganize `lib/src` so files are grouped by responsibility rather than kept flat.
- Keep the public API stable through `lib/stretchable_container.dart`.
- Make interaction logic, rendering logic, and UI composition easier to locate.
- Avoid behavior changes unless they are required to support the new structure.

## Non-Goals

- Redesigning the package API.
- Adding new end-user features.
- Changing visual behavior unless required by refactoring.
- Introducing state management libraries or architecture frameworks.

## Current File Inventory

- `lib/stretchable_container.dart`
- `lib/main.dart`
- `lib/src/models/stretchable_container_config.dart`
- `lib/src/utils/grid_coordinates.dart`
- `lib/src/widgets/stretchable_container.dart`
- `lib/src/widgets/stretchable_dot_grid.dart`

## Target Directory Contract

### `lib/src/models`

Contains immutable data structures and configuration objects.

Planned files:

- `stretchable_container_config.dart`

### `lib/src/utils`

Contains pure helper functions with no UI ownership.

Planned files:

- `grid_coordinates.dart`

### `lib/src/widgets`

Contains compositional Flutter widgets and public UI building blocks used inside the package.

Planned files:

- `stretchable_container.dart`
- `stretchable_dot_grid.dart` if rendering remains widget-based

### `lib/src/controllers`

Contains interaction and motion logic extracted from widget state when that logic is substantial enough to justify separation.

Candidate file:

- `stretchable_container_controller.dart`

This controller should only be introduced if it clearly improves readability by owning drag state, offset computation, and release animation coordination without making the package API harder to use.

### `lib/src/painters`

Contains `CustomPainter` implementations when drawing logic is better expressed as paint operations than widget trees.

Candidate file:

- `stretchable_dot_grid_painter.dart`

This painter should only be introduced if dot rendering is migrated away from many positioned children into a paint-based implementation.

## Migration Rules

1. Preserve `lib/stretchable_container.dart` as the package entrypoint.
2. Keep imports relative inside `lib/src` unless a package import is clearly better at the boundary.
3. Do not move demo-only code into the package public API.
4. Prefer structural refactoring first; avoid mixing it with behavior changes.
5. Only add `controllers` and `painters` files if they reduce complexity. Empty directories should not be forced into git history without real ownership.

## Recommended File Mapping

### Baseline Mapping

- `stretchable_container_config.dart` -> `models`
- `grid_coordinates.dart` -> `utils`
- `stretchable_container.dart` -> `widgets`
- `stretchable_dot_grid.dart` -> `widgets`

### Optional Second-Step Extraction

- Drag/offset/release logic from `widgets/stretchable_container.dart` -> `controllers/stretchable_container_controller.dart`
- Dot rendering math from `widgets/stretchable_dot_grid.dart` -> `painters/stretchable_dot_grid_painter.dart`

The optional second step should happen only if the first pass still leaves UI files doing too much.

## Public API Expectations

`lib/stretchable_container.dart` should continue exporting:

- `src/widgets/stretchable_container.dart`
- `src/models/stretchable_container_config.dart`

If a controller becomes a supported extension point for consumers, it can be exported later. Otherwise it should remain internal to `src`.

## Acceptance Criteria

- `lib/src` is organized by responsibility under the agreed directories.
- Existing package imports continue to work.
- `flutter analyze` passes after the refactor.
- No unintended behavioral regressions are introduced.
- New files and directories have clear ownership and are not placeholders without purpose.

## Implementation Plan

1. Confirm current partial move state and stabilize imports.
2. Keep the baseline mapping as the minimum viable reorganization.
3. Evaluate whether controller extraction materially improves `stretchable_container.dart`.
4. Evaluate whether painter extraction materially improves `stretchable_dot_grid.dart`.
5. Update exports in `lib/stretchable_container.dart`.
6. Run analysis and fix any import or lint issues.

## Decision Recommendation

Proceed in two phases:

1. Finish the baseline directory reorganization with `models`, `utils`, and `widgets`.
2. Only introduce `controllers` and `painters` if the code still feels overloaded after that baseline pass.

This keeps the refactor proportional to the size of the package and avoids creating architecture that the current codebase does not yet need.
