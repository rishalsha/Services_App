# Tasks: Video Playback Enhancements

**Input**: Design documents from `/specs/002-i-want-to/`
**Prerequisites**: plan.md (required), research.md, data-model.md, contracts/

## Execution Flow (main)
```
1. Load plan.md from feature directory
   → If not found: ERROR "No implementation plan found"
   → Extract: tech stack, libraries, structure
2. Load optional design documents:
   → data-model.md: Extract entities → model tasks
   → contracts/: Each file → contract test task
   → research.md: Extract decisions → setup tasks
3. Generate tasks by category:
   → Setup: project init, dependencies, linting
   → Tests: contract tests, integration tests
   → Core: models, services, CLI commands
   → Integration: DB, middleware, logging
   → Polish: unit tests, performance, docs
4. Apply task rules:
   → Different files = mark [P] for parallel
   → Same file = sequential (no [P])
   → Tests before implementation (TDD)
5. Number tasks sequentially (T001, T002...)
6. Generate dependency graph
7. Create parallel execution examples
8. Validate task completeness:
   → All contracts have tests?
   → All entities have models?
   → All endpoints implemented?
9. Return: SUCCESS (tasks ready for execution)
```

## Format: `[ID] [P?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- Include exact file paths in descriptions

## Path Conventions
- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`, `lib/`
- Paths shown below assume single project - adjust based on plan.md structure

## Phase 3.1: Setup
- [X] T001 Verify Flutter environment setup.
- [X] T002 Add `video_player` dependency to `pubspec.yaml`.
- [X] T003 Run `flutter pub get` to install dependencies.

## Phase 3.2: Testing
- [X] T004 [P] Write widget tests for the seek bar functionality in `test/features/video_player/seek_bar_widget_test.dart`.
- [X] T005 [P] Write widget tests for the skip button functionality in `test/features/video_player/skip_buttons_widget_test.dart`.
- [X] T006 Write integration tests for the overall video playback controls in `test/features/video_player/video_playback_integration_test.dart`.

## Phase 3.3: Core Implementation (ONLY after tests are failing)
- [X] T007 Identify the video playing screen file (e.g., `lib/src/features/video_player/video_player_screen.dart`).
- [X] T008 Implement a seek bar widget in `lib/src/features/video_player/widgets/seek_bar.dart`.
- [X] T009 Integrate the seek bar with the `video_player` controller in `lib/src/features/video_player/video_player_screen.dart`.
- [X] T010 Implement forward skip button in `lib/src/features/video_player/widgets/forward_skip_button.dart`.
- [X] T011 Implement backward skip button in `lib/src/features/video_player/widgets/backward_skip_button.dart`.
- [X] T012 Integrate skip buttons with the `video_player` controller in `lib/src/features/video_player/video_player_screen.dart`.
- [X] T013 Update the UI to display the current playback position and total duration in `lib/src/features/video_player/video_player_screen.dart`.

## Phase 3.4: Integration
- [X] T014 Ensure smooth interaction between seek bar, skip buttons, and video player.

## Phase 3.5: Polish
- [X] T015 Ensure UI/UX consistency with existing design.
- [X] T016 Implement logic to prevent seeking beyond video duration.
- [X] T017 Update UI feedback when seeking near or beyond video duration.
- [X] T018 Optimize performance for smooth seeking.

## Dependencies
- T001, T002, T003 must be completed before any other tasks.
- T004, T005, T006 must be completed before T007-T013.
- T007-T013 must be completed before T014.
- T014 must be completed before T015-T017.

## Parallel Example
```
# Launch T004 and T005 together:
Task: "Write widget tests for the seek bar functionality in `test/features/video_player/seek_bar_widget_test.dart`"
Task: "Write widget tests for the skip button functionality in `test/features/video_player/skip_buttons_widget_test.dart`"
```

## Notes
- [P] tasks = different files, no dependencies
- Verify tests fail before implementing
- Commit after each task
- Avoid: vague tasks, same file conflicts

## Task Generation Rules
*Applied during main() execution*

1. **From Contracts**:
   - Each contract file → contract test task [P]
   - Each endpoint → implementation task
   
2. **From Data Model**:
   - Each entity → model creation task [P]
   - Relationships → service layer tasks
   
3. **From User Stories**:
   - Each story → integration test [P]
   - Quickstart scenarios → validation tasks

4. **Ordering**:
   - Setup → Tests → Models → Services → Endpoints → Polish
   - Dependencies block parallel execution

## Validation Checklist
*GATE: Checked by main() before returning*

- [ ] All contracts have corresponding tests
- [ ] All entities have model tasks
- [ ] All tests come before implementation
- [ ] Parallel tasks truly independent
- [ ] Each task specifies exact file path
- [ ] No task modifies same file as another [P] task