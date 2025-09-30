import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SafeService {
  static const MethodChannel _channel = MethodChannel('services.share/channel');

  Future<void> listenForShares() async {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'ingestShared') {
        final List<dynamic> list = call.arguments as List<dynamic>;
        final List<String> paths = list.map((e) => e.toString()).toList();
        await _handleSharedUris(paths);
      }
    });
  }

  Future<void> _saveSharedItems(List<String> paths) async {
    if (paths.isEmpty) return;
    final Directory base = await safeDirectory(1, sub: 'inbox');
    for (final String p in paths) {
      try {
        final File src = File(p);
        if (await src.exists()) {
          final String fileName = src.uri.pathSegments.isNotEmpty ? src.uri.pathSegments.last : DateTime.now().millisecondsSinceEpoch.toString();
          final File dst = File('${base.path}${Platform.pathSeparator}$fileName');
          await src.copy(dst.path);
        }
      } catch (_) {}
    }
  }

  Future<void> _handleSharedUris(List<String> uris) async {
    if (uris.isEmpty) return;
    // Persist to Safe 1 inbox; content access still requires unlocking with passcode1
    final Directory base = await safeDirectory(1, sub: 'inbox');
    for (final String u in uris) {
      try {
        final Uri uri = Uri.parse(u);
        // Try to resolve content:// to a filename and copy via openRead/openWrite if possible
        // As a fallback, skip if scheme not file due to scoped storage limitations without SAF
        if (uri.scheme == 'file') {
          final File src = File(uri.toFilePath());
          if (await src.exists()) {
            final File dst = File('${base.path}${Platform.pathSeparator}${src.uri.pathSegments.last}');
            await src.copy(dst.path);
          }
        }
      } catch (_) {}
    }
  }

  static Future<Directory> safeDirectory(int safeId, {String? sub}) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory safeDir = Directory('${appDir.path}${Platform.pathSeparator}safes${Platform.pathSeparator}s$safeId');
    if (!await safeDir.exists()) {
      await safeDir.create(recursive: true);
    }
    if (!await File('${safeDir.path}${Platform.pathSeparator}.nomedia').exists()) {
      await File('${safeDir.path}${Platform.pathSeparator}.nomedia').create();
    }
    if (sub != null) {
      final Directory subDir = Directory('${safeDir.path}${Platform.pathSeparator}$sub');
      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }
      return subDir;
    }
    return safeDir;
  }

  Future<List<FileSystemEntity>> listFiles(int safeId) async {
    final Directory dir = await safeDirectory(safeId);
    final List<FileSystemEntity> children = await dir.list(recursive: false).toList();
    children.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return children;
  }

  Future<void> importFiles(int safeId) async {
    // This will be implemented in a later task
  }
}
