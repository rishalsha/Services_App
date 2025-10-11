import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const FlutterSecureStorage _secure = FlutterSecureStorage();
  static const String _keyStorageKey = 'encryption_key';
  static const int _keySize = 32; // 256 bits
  static const int _nonceSize = 12; // 96 bits for ChaCha20

  /// Get or generate encryption key for a specific safe
  static Future<SecretKey> _getOrGenerateKey(int safeId) async {
    final String keyName = '${_keyStorageKey}_$safeId';
    final String? keyString = await _secure.read(key: keyName);

    if (keyString != null) {
      final keyBytes = base64Decode(keyString);
      return SecretKey(keyBytes);
    }

    // Generate new key
    final algorithm = Chacha20.poly1305Aead;
    final newKey = await algorithm.newSecretKey();
    final keyBytes = await newKey.extractBytes();
    await _secure.write(key: keyName, value: base64Encode(keyBytes));
    return newKey;
  }

  /// Encrypt file content
  static Future<List<int>> encryptFile(List<int> fileContent, int safeId) async {
    try {
      final key = await _getOrGenerateKey(safeId);
      final algorithm = Chacha20.poly1305Aead;

      // Encrypt the file
      final secretBox = await algorithm.encrypt(
        fileContent,
        secretKey: key,
      );

      return secretBox.concatenation();
    } catch (e) {
      throw EncryptionException('Failed to encrypt file: $e');
    }
  }

  /// Decrypt file content
  static Future<List<int>> decryptFile(List<int> encryptedData, int safeId) async {
    try {
      final key = await _getOrGenerateKey(safeId);
      final algorithm = Chacha20.poly1305Aead;

      final secretBox = SecretBox.fromConcatenation(
        encryptedData,
        nonceLength: _nonceSize,
        macLength: 16, // ChaCha20Poly1305 uses a 16-byte MAC
      );

      // Decrypt the file
      final decrypted = await algorithm.decrypt(
        secretBox,
        secretKey: key,
      );

      return decrypted;
    } catch (e) {
      throw EncryptionException('Failed to decrypt file: $e');
    }
  }

  /// Encrypt and save file
  static Future<void> encryptAndSaveFile(File sourceFile, File destinationFile, int safeId) async {
    try {
      final fileContent = await sourceFile.readAsBytes();
      final encryptedContent = await encryptFile(fileContent, safeId);
      await destinationFile.writeAsBytes(encryptedContent);
    } catch (e) {
      throw EncryptionException('Failed to encrypt and save file: $e');
    }
  }

  /// Decrypt and load file
  static Future<List<int>> decryptAndLoadFile(File encryptedFile, int safeId) async {
    try {
      final encryptedContent = await encryptedFile.readAsBytes();
      return await decryptFile(encryptedContent, safeId);
    } catch (e) {
      throw EncryptionException('Failed to decrypt and load file: $e');
    }
  }

  /// Securely delete encryption key (for safe deletion)
  static Future<void> deleteSafeKey(int safeId) async {
    final String keyName = '${_keyStorageKey}_$safeId';
    await _secure.delete(key: keyName);
  }

  /// Check if file is encrypted (has proper header)
  static bool isEncrypted(File file) {
    // For now, we'll assume all files in safes are encrypted
    // In a more sophisticated implementation, you'd check for a magic header
    return true;
  }

  /// Get file hash for integrity checking
  static Future<String> getFileHash(List<int> content) async {
    final algorithm = Sha256();
    final hash = await algorithm.hash(content);
    return base64Encode(hash.bytes);
  }

  /// Verify file integrity
  static Future<bool> verifyFileIntegrity(File file, String expectedHash, int safeId) async {
    try {
      final content = await decryptAndLoadFile(file, safeId);
      final actualHash = await getFileHash(content);
      return actualHash == expectedHash;
    } catch (e) {
      return false;
    }
  }
}

class EncryptionException implements Exception {
  final String message;
  EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}
