import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locker_app/src/core/services/settings_store.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_store_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('SettingsStore', () {
    test('getLockType returns default value', () async {
      // Arrange
      final mockStorage = MockFlutterSecureStorage();
      SettingsStore.secure = mockStorage;
      when(mockStorage.read(key: 'lock_type')).thenAnswer((_) => Future.value(null));

      // Act
      final lockType = await SettingsStore.getLockType();

      // Assert
      expect(lockType, LockType.password);
    });
  });
}
