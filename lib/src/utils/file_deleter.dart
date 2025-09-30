import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class FileDeleter {
  // 1. Define the method channel. The name must match the one on the native side.
  static const _channel = MethodChannel('com.example/file_deleter');

  // 2. Create a function to call the native method
  static Future<bool> deleteOriginalFile(PlatformFile file) async {
    // The 'identifier' property holds the content:// URI
    final uriString = file.identifier;

    if (uriString == null) {
      print("Error: The file identifier (URI) is null.");
      return false;
    }

    try {
      // 3. Invoke the method, passing the URI as an argument.
      final bool deleted = await _channel.invokeMethod('deleteFileFromUri', {
        'uri': uriString,
      });
      return deleted;
    } on PlatformException catch (e) {
      print("Failed to delete file: '${e.message}'.");
      return false;
    }
  }
}