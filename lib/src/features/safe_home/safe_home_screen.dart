import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:locker_app/src/features/video_player/video_player_screen.dart';
import 'package:locker_app/src/utils/file_deleter.dart';
import 'package:open_filex/open_filex.dart';
import 'package:locker_app/src/core/services/safe_service.dart';
import 'package:locker_app/src/features/safe_home/widgets/file_viewers.dart';
import 'package:locker_app/src/features/settings/settings_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SafeHomeScreen extends StatefulWidget {
  const SafeHomeScreen({
    super.key,
    required this.safeId,
    required this.onLock,
    required this.safeService,
  });
  final int safeId;
  final VoidCallback onLock;
  final SafeService safeService;

  @override
  State<SafeHomeScreen> createState() => _SafeHomeScreenState();
}

class _SafeHomeScreenState extends State<SafeHomeScreen>
    with WidgetsBindingObserver {
  late Future<List<FileSystemEntity>> _filesFuture;
  bool _isSelectionMode = false;
  final Set<String> _selectedFiles = {};
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _filesFuture = widget.safeService.listFiles(widget.safeId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedFiles.clear(); // Clear selection when exiting selection mode
      }
    });
  }

  void _toggleFileSelection(String filePath) {
    setState(() {
      if (_selectedFiles.contains(filePath)) {
        _selectedFiles.remove(filePath);
      } else {
        _selectedFiles.add(filePath);
      }
    });
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    // Show a confirmation dialog
    final bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete ${_selectedFiles.length} selected files?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false; // Default to false if dialog is dismissed

    if (!confirm) return;

    for (final filePath in _selectedFiles) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('Error deleting file $filePath: $e');
        // Optionally show a snackbar or toast for failed deletions
      }
    }

    setState(() {
      _selectedFiles.clear();
      _isSelectionMode = false;
      _filesFuture = widget.safeService.listFiles(
        widget.safeId,
      ); // Refresh the list
    });
  }

  bool _isImage(String path) =>
      path.endsWith('.png') ||
      path.endsWith('.jpg') ||
      path.endsWith('.jpeg') ||
      path.endsWith('.gif') ||
      path.endsWith('.webp');
  bool _isVideo(String path) =>
      path.endsWith('.mp4') ||
      path.endsWith('.mkv') ||
      path.endsWith('.mov') ||
      path.endsWith('.webm');
  bool _isAudio(String path) =>
      path.endsWith('.mp3') ||
      path.endsWith('.m4a') ||
      path.endsWith('.wav') ||
      path.endsWith('.ogg');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedFiles.length} selected')
            : const Text('Safe'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteSelectedFiles,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: _toggleSelectionMode,
                ),
              ]
            : [
                IconButton(
                  onPressed: _importFiles,
                  icon: const Icon(Icons.add),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _filesFuture = widget.safeService.listFiles(widget.safeId);
                  }),
                  icon: const Icon(Icons.refresh),
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  onPressed: _toggleSelectionMode,
                ),
                if (widget.safeId == 1)
                  IconButton(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                  ),
                IconButton(
                  onPressed: () {
                    widget.onLock();
                  },
                  icon: const Icon(Icons.lock),
                  tooltip: 'Lock now',
                ),
              ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _filesFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final files = snapshot.data!;
          if (files.isEmpty) {
            return const Center(
              child: Text('No files yet. Use Android Share to add to Safe 1.'),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _importFiles,
                      icon: const Icon(Icons.add),
                      label: const Text('Add files'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final entity = files[index];
                    if (entity is! File) {
                      return ListTile(
                        title: Text(entity.uri.pathSegments.last),
                      );
                    }
                    final String name = entity.uri.pathSegments.last;
                    final String p = entity.path.toLowerCase();
                    IconData icon = Icons.insert_drive_file;
                    if (_isImage(p)) icon = Icons.image;
                    if (_isVideo(p)) icon = Icons.movie;
                    if (_isAudio(p)) icon = Icons.audiotrack;
                    return ListTile(
                      leading: Icon(icon),
                      title: Text(name),
                      selected: _selectedFiles.contains(entity.path),
                      selectedTileColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      onTap: _isSelectionMode
                          ? () => _toggleFileSelection(entity.path)
                          : () async {
                              if (_isImage(p)) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ImageViewer(file: entity),
                                  ),
                                );
                              } else if (_isVideo(p)) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VideoPlayerScreen(file: entity),
                                  ),
                                );
                              } else if (_isAudio(p)) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AudioPlayerScreen(file: entity),
                                  ),
                                );
                              } else {
                                await OpenFilex.open(entity.path);
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      // This will open a screen where the user can grant the permission
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _importFiles() async {
    await requestStoragePermission();
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;
    final Directory dest = await SafeService.safeDirectory(widget.safeId);
    for (final file in result.files) {
      final String? path = file.path;
      if (path == null) continue;
      final File src = File(path);
      final File dst = File(
        '${dest.path}${Platform.pathSeparator}${src.uri.pathSegments.last}',
      );
      await src.rename(dst.path);
      await FileDeleter.deleteOriginalFile(file);

    }
    if (mounted) {
      setState(() {
        _filesFuture = widget.safeService.listFiles(widget.safeId);
      });
    }
  }
}
