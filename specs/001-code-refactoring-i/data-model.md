# Data Model: Refactored Services and Widgets

This document defines the APIs for the new services and widgets created during the refactoring.

## Services

### `SettingsStore` (`lib/src/core/services/settings_store.dart`)

```dart
class SettingsStore {
  static Future<LockType> getLockType();
  static Future<void> setLockType(LockType type);
  static Future<void> setPasscode(int safeId, String value);
  static Future<String?> getPasscode(int safeId);
}
```

### `SafeService` (`lib/src/core/services/safe_service.dart`)

```dart
class SafeService {
  static Future<Directory> safeDirectory(int safeId, {String? sub});
  Future<void> handleSharedUris(List<String> uris);
  Future<void> saveSharedItems(List<String> paths);
  Future<List<FileSystemEntity>> listFiles(int safeId);
  Future<void> importFiles(int safeId);
}
```

## Widgets

### `ServicesApp` (`lib/src/app.dart`)
- Manages the overall application state (locked/unlocked).

### `LockScreen` (`lib/src/features/lockscreen/lock_screen.dart`)
- `onUnlocked(int safeId)`: Callback when the user successfully unlocks a safe.

### `SafeHome` (`lib/src/features/safe_home/safe_home_screen.dart`)
- `safeId`: The ID of the currently unlocked safe.
- `onLock()`: Callback to lock the application.

### File Viewers (`lib/src/features/safe_home/widgets/file_viewers.dart`)
- `ImageViewer(file: File)`
- `VideoViewer(file: File)`
- `AudioPlayerScreen(file: File)`
