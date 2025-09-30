# Research: main.dart Refactoring

This document maps the components from the original `main.dart` file to their new locations in the refactored code structure.

## `main.dart` -> New Structure Mapping

| Original Component | New File |
|---|---|
| `main()` | `lib/main.dart` (will be updated) |
| `ServicesApp` | `lib/src/app.dart` |
| `_ServicesAppState` | `lib/src/app.dart` |
| `SettingsStore` | `lib/src/core/services/settings_store.dart` |
| `LockScreen` | `lib/src/features/lockscreen/lock_screen.dart` |
| `_LockScreenState` | `lib/src/features/lockscreen/lock_screen.dart` |
| `PatternPad` | `lib/src/features/lockscreen/widgets/pattern_pad.dart` |
| `PinPad` | `lib/src/features/lockscreen/widgets/pin_pad.dart` |
| `SafeHome` | `lib/src/features/safe_home/safe_home_screen.dart` |
| `_SafeHomeState` | `lib/src/features/safe_home/safe_home_screen.dart` |
| `ImageViewer` | `lib/src/features/safe_home/widgets/file_viewers.dart` |
| `VideoViewer` | `lib/src/features/safe_home/widgets/file_viewers.dart` |
| `AudioPlayerScreen` | `lib/src/features/safe_home/widgets/file_viewers.dart` |
| `SettingsScreen` | `lib/src/features/settings/settings_screen.dart` |
| `_SettingsScreenState` | `lib/src/features/settings/settings_screen.dart` |
| `_safeDirectory()` | `lib/src/core/services/safe_service.dart` |
| `_handleSharedUris()` | `lib/src/core/services/safe_service.dart` |
| `_saveSharedItems()` | `lib/src/core/services/safe_service.dart` |
