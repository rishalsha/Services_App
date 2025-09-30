# Implementation Plan: Code Refactoring

**Branch**: `001-code-refactoring-i` | **Date**: 2025-09-30 | **Spec**: [link to spec.md]
**Input**: Feature specification from `/specs/001-code-refactoring-i/spec.md`

## Summary
This plan outlines the process for refactoring the `main.dart` file to improve code quality, reduce redundancy, and align with Flutter best practices and the project constitution.

## Technical Context
**Language/Version**: Dart (Flutter)
**Primary Dependencies**: flutter, flutter_secure_storage, open_filex, path_provider, video_player, just_audio, file_picker
**Testing**: Widget and Unit Tests (using `flutter_test`)
**Target Platform**: Android, iOS, Linux, macOS, Web, Windows
**Project Type**: Mobile

## Constitution Check
*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Performant and Clean Code**: The refactoring will directly address this by improving code structure and readability.
- **II. Material Design**: The existing UI already uses Material Design, and the refactoring will maintain this.
- **III. Pragmatic Testing**: While the original code has no tests, the refactoring process will include adding unit and widget tests for the new, smaller components.

## Project Structure

### Source Code (repository root)
```
lib/
├── src/
│   ├── app.dart
│   ├── core/
│   │   ├── constants.dart
│   │   └── services/
│   │       ├── settings_store.dart
│   │       └── safe_service.dart
│   ├── features/
│   │   ├── lockscreen/
│   │   │   ├── widgets/
│   │   │   │   ├── pattern_pad.dart
│   │   │   │   └── pin_pad.dart
│   │   │   └── lock_screen.dart
│   │   ├── safe_home/
│   │   │   ├── widgets/
│   │   │   │   ├── file_viewers.dart
│   │   │   │   └── safe_home_app_bar.dart
│   │   │   └── safe_home_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── main.dart
test/
├── features/
│   ├── lockscreen/
│   │   └── lock_screen_test.dart
│   └── safe_home/
│       └── safe_home_screen_test.dart
└── core/
    └── services/
        └── settings_store_test.dart
```

**Structure Decision**: The code will be organized into a feature-based structure within the `lib/src` directory. Core services and constants will be in `lib/src/core`. UI-related widgets will be in their respective feature directories.

## Phase 0: Outline & Research
1.  **Analyze `main.dart`:** Identify all widgets, state management logic, and utility functions.
2.  **Map to New Structure:** Determine which parts of the existing code will move to which new files in the proposed structure.

**Output**: A `research.md` file with a detailed mapping of old code to the new file structure.

## Phase 1: Design & Contracts
*Prerequisites: research.md complete*

1.  **Define Widget Interfaces:** For each new widget, define the required parameters and callbacks.
2.  **Define Service APIs:** For `SettingsStore` and a new `SafeService`, define the public methods and properties.

**Output**: A `data-model.md` file detailing the APIs for the new services and widgets.

## Phase 2: Task Planning Approach
*This section describes what the /tasks command will do - DO NOT execute during /plan*

**Task Generation Strategy**:
- Create tasks for creating the new directory structure.
- Create tasks for moving code from `main.dart` to the new files.
- Create tasks for creating new tests for the refactored widgets and services.
- Create tasks for updating `main.dart` to use the new structure.

**Ordering Strategy**:
1.  Create new files and directories.
2.  Write tests for the new components.
3.  Move code to new files and make tests pass.
4.  Update `main.dart`.

## Progress Tracking
**Phase Status**:
- [ ] Phase 0: Research complete
- [ ] Phase 1: Design complete
- [ ] Phase 2: Task planning complete

**Gate Status**:
- [X] Initial Constitution Check: PASS