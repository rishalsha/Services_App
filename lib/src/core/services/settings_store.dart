import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum LockType { pin, password, pattern }

class SettingsStore {
  static FlutterSecureStorage _secure = const FlutterSecureStorage();

  // Allow overriding the storage for testing
  static set secure(FlutterSecureStorage storage) {
    _secure = storage;
  }

  static const String _kLockType = 'lock_type';
  static const String _kPass1 = 'pass_1';
  static const String _kPass2 = 'pass_2';

  static Future<LockType> getLockType() async {
    final String? v = await _secure.read(key: _kLockType);
    switch (v) {
      case 'pin':
        return LockType.pin;
      case 'pattern':
        return LockType.pattern;
      case 'password':
      default:
        return LockType.password;
    }
  }

  static Future<void> setLockType(LockType type) => _secure.write(key: _kLockType, value: type.name);

  static Future<void> setPasscode(int safeId, String value) => _secure.write(key: safeId == 1 ? _kPass1 : _kPass2, value: value);
  static Future<String?> getPasscode(int safeId) => _secure.read(key: safeId == 1 ? _kPass1 : _kPass2);
}
