# Tasks: Code Refactoring

**Input**: Design documents from `/specs/001-code-refactoring-i/`

## Phase 3.1: Setup
- [X] T001 [P] Create the directory structure defined in `plan.md`.

## Phase 3.2: Testing
- [X] T002 [P] Create `test/core/services/settings_store_test.dart` with unit tests for the `SettingsStore` class.
- [X] T003 [P] Create `test/features/lockscreen/lock_screen_test.dart` with widget tests for the `LockScreen` widget.
- [X] T004 [P] Create `test/features/safe_home/safe_home_screen_test.dart` with widget tests for the `SafeHomeScreen` widget.

## Phase 3.3: Core Implementation
- [X] T005 [P] Create `lib/src/app.dart` and move the `ServicesApp` widget to it.
- [X] T006 [P] Create `lib/src/core/services/settings_store.dart` and move the `SettingsStore` class to it.
- [X] T007 [P] Create `lib/src/core/services/safe_service.dart` and move the safe-related functions to it.
- [X] T008 [P] Create `lib/src/features/lockscreen/lock_screen.dart` and move the `LockScreen` widget to it.
- [X] T009 [P] Create `lib/src/features/lockscreen/widgets/pattern_pad.dart` and move the `PatternPad` widget to it.
- [X] T010 [P] Create `lib/src/features/lockscreen/widgets/pin_pad.dart` and move the `PinPad` widget to it.
- [X] T011 [P] Create `lib/src/features/safe_home/safe_home_screen.dart` and move the `SafeHome` widget to it.
- [X] T012 [P] Create `lib/src/features/safe_home/widgets/file_viewers.dart` and move the `ImageViewer`, `VideoViewer`, and `AudioPlayerScreen` widgets to it.
- [X] T013 [P] Create `lib/src/features/settings/settings_screen.dart` and move the `SettingsScreen` widget to it.

## Phase 3.4: Integration
- [X] T014 Update `lib/main.dart` to import and use the new widgets and services from their new locations.
- [X] T015 Update all the new files to import any dependencies they need.

## Dependencies
- `T001` must be completed before all other tasks.
- `T002`, `T003`, `T004` should be completed before `T005`-`T015`.

## Parallel Example
```
# Launch T002-T004 together:
Task: "Create test/core/services/settings_store_test.dart with unit tests for the SettingsStore class."
Task: "Create test/features/lockscreen/lock_screen_test.dart with widget tests for the LockScreen widget."
Task: "Create test/features/safe_home/safe_home_screen_test.dart with widget tests for the SafeHomeScreen widget."
```
