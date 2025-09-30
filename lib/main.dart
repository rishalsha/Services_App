import 'dart:async';
import 'dart:io';

// Placeholder for future encryption
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' as services;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServicesApp());
}

class ServicesApp extends StatefulWidget {
  const ServicesApp({super.key});

  @override
  State<ServicesApp> createState() => _ServicesAppState();
}

class _ServicesAppState extends State<ServicesApp> with WidgetsBindingObserver {
  final ValueNotifier<bool> _isLocked = ValueNotifier<bool>(true);
  StreamSubscription? _shareStreamSub;
  static const services.MethodChannel _channel = services.MethodChannel('services.share/channel');
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  void _openSafe(int safeId) {
    _navKey.currentState!.pushReplacement(
      MaterialPageRoute(
        builder: (_) => SafeHome(
          safeId: safeId,
          onLock: _goToLockScreen,
        ),
      ),
    );
  }

  void _goToLockScreen() {
    _isLocked.value = true;
    _navKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LockScreen(
          onUnlocked: (id) {
            _isLocked.value = false;
            _openSafe(id);
          },
        ),
      ),
      (r) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenForShares();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shareStreamSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isLocked.value = true; // Auto-lock on background
    }
  }

  void _listenForShares() {
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
    final Directory base = await _safeDirectory(1, sub: 'inbox');
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
    final Directory base = await _safeDirectory(1, sub: 'inbox');
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

  static Future<Directory> _safeDirectory(int safeId, {String? sub}) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory safeDir = Directory('${appDir.path}${Platform.pathSeparator}safes${Platform.pathSeparator}s$safeId');
    if (!await safeDir.exists()) {
      await safeDir.create(recursive: true);
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Services',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: ValueListenableBuilder<bool>(
        valueListenable: _isLocked,
        builder: (context, locked, _) {
          if (locked) {
            return LockScreen(
              onUnlocked: (int safeId) {
                _isLocked.value = false;
                _openSafe(safeId);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

enum LockType { pin, password, pattern }

class SettingsStore {
  static const FlutterSecureStorage _secure = FlutterSecureStorage();
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

class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.onUnlocked});
  final void Function(int safeId) onUnlocked;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  LockType _lockType = LockType.password;
  String _input = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _lockType = await SettingsStore.getLockType();
    setState(() {});
  }

  Future<void> _tryUnlock() async {
    final String? p1 = await SettingsStore.getPasscode(1);
    final String? p2 = await SettingsStore.getPasscode(2);
    // First-time setup: if no passcodes, prompt to create
    if ((p1 == null || p1.isEmpty) && (p2 == null || p2.isEmpty)) {
      if (_input.isEmpty) return;
      await SettingsStore.setPasscode(1, _input);
      await SettingsStore.setPasscode(2, '${_input}_2');
    }
    final String? pass1 = await SettingsStore.getPasscode(1);
    final String? pass2 = await SettingsStore.getPasscode(2);
    if (_input == pass1) {
      widget.onUnlocked(1);
    } else if (_input == pass2) {
      widget.onUnlocked(2);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect code')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings_applications, size: 72),
                const SizedBox(height: 16),
                Text(_lockType == LockType.pin
                    ? 'Enter PIN'
                    : _lockType == LockType.pattern
                        ? 'Draw Pattern'
                        : 'Enter Password'),
                const SizedBox(height: 12),
                if (_lockType == LockType.pattern)
                  PatternPad(onChanged: (v) => _input = v)
                else if (_lockType == LockType.pin)
                  PinPad(
                    onChanged: (v) => _input = v,
                    onSubmit: _tryUnlock,
                  )
                else ...[
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      inputFormatters: [LengthLimitingTextInputFormatter(64)],
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Password'),
                      onChanged: (v) => _input = v,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _tryUnlock,
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PatternPad extends StatefulWidget {
  const PatternPad({super.key, required this.onChanged});
  final void Function(String) onChanged;

  @override
  State<PatternPad> createState() => _PatternPadState();
}

class _PatternPadState extends State<PatternPad> {
  final List<int> _sequence = [];

  void _toggle(int index) {
    if (_sequence.isEmpty || _sequence.last != index) {
      setState(() {
        _sequence.add(index);
        widget.onChanged(_sequence.join('-'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
        itemCount: 9,
        itemBuilder: (context, i) {
          final bool active = _sequence.contains(i);
          return GestureDetector(
            onTap: () => _toggle(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: active ? Colors.indigo : Colors.transparent,
                border: Border.all(color: Colors.indigo, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onChanged, required this.onSubmit});
  final void Function(String) onChanged;
  final Future<void> Function() onSubmit;

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';

  void _tap(String d) {
    if (_pin.length >= 12) return;
    setState(() {
      _pin += d;
    });
    widget.onChanged(_pin);
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
    widget.onChanged(_pin);
  }

  Widget _dot(bool filled) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: filled ? Colors.indigo : Colors.transparent,
          border: Border.all(color: Colors.indigo, width: 2),
          shape: BoxShape.circle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final List<Widget> dots = List.generate(6, (i) => _dot(i < _pin.length));
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: dots),
        const SizedBox(height: 16),
        _row(['1', '2', '3']),
        const SizedBox(height: 8),
        _row(['4', '5', '6']),
        const SizedBox(height: 8),
        _row(['7', '8', '9']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _key('⌫', onTap: _backspace),
            const SizedBox(width: 8),
            _key('0', onTap: () => _tap('0')),
            const SizedBox(width: 8),
            _key('✓', onTap: () => widget.onSubmit()),
          ],
        )
      ],
    );
  }

  Widget _row(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final l in labels) ...[
          _key(l, onTap: () => _tap(l)),
          if (l != labels.last) const SizedBox(width: 8),
        ]
      ],
    );
  }

  Widget _key(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo, width: 2),
        ),
        child: Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class SafeHome extends StatefulWidget {
  const SafeHome({super.key, required this.safeId, required this.onLock});
  final int safeId;
  final VoidCallback onLock;

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> with WidgetsBindingObserver {
  late Future<List<FileSystemEntity>> _filesFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _filesFuture = _listFiles();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      widget.onLock();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => LockScreen(onUnlocked: (id) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => SafeHome(safeId: id, onLock: widget.onLock)));
            })),
        (route) => false,
      );
    }
  }

  Future<List<FileSystemEntity>> _listFiles() async {
    final Directory dir = await _ServicesAppState._safeDirectory(widget.safeId);
    final List<FileSystemEntity> children = await dir.list(recursive: false).toList();
    children.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    return children;
  }

  bool _isImage(String path) => path.endsWith('.png') || path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.gif') || path.endsWith('.webp');
  bool _isVideo(String path) => path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.mov') || path.endsWith('.webm');
  bool _isAudio(String path) => path.endsWith('.mp3') || path.endsWith('.m4a') || path.endsWith('.wav') || path.endsWith('.ogg');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe'),
        actions: [
          IconButton(onPressed: _importFiles, icon: const Icon(Icons.add)),
          IconButton(onPressed: () => setState(() { _filesFuture = _listFiles(); }), icon: const Icon(Icons.refresh)),
          if (widget.safeId == 1)
            IconButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
              icon: const Icon(Icons.settings),
            ),
          IconButton(
            onPressed: () {
              widget.onLock();
            },
            icon: const Icon(Icons.lock),
            tooltip: 'Lock now',
          )
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
            return const Center(child: Text('No files yet. Use Android Share to add to Safe 1.'));
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
                      return ListTile(title: Text(entity.uri.pathSegments.last));
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
                      onTap: () async {
                        if (_isImage(p)) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageViewer(file: entity)));
                        } else if (_isVideo(p)) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoViewer(file: entity)));
                        } else if (_isAudio(p)) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => AudioPlayerScreen(file: entity)));
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

  Future<void> _importFiles() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    final Directory dest = await _ServicesAppState._safeDirectory(widget.safeId);
    for (final file in result.files) {
      final String? path = file.path;
      if (path == null) continue;
      final File src = File(path);
      if (!await src.exists()) continue;
      final File dst = File('${dest.path}${Platform.pathSeparator}${src.uri.pathSegments.last}');
      await src.copy(dst.path);
    }
    if (mounted) {
      setState(() {
        _filesFuture = _listFiles();
      });
    }
  }
}

class ImageViewer extends StatelessWidget {
  const ImageViewer({super.key, required this.file});
  final File file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.uri.pathSegments.last)),
      body: Center(child: Image.file(file, fit: BoxFit.contain)),
    );
  }
}

class VideoViewer extends StatefulWidget {
  const VideoViewer({super.key, required this.file});
  final File file;
  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late final VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.file.uri.pathSegments.last)),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.file});
  final File file;
  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.file.path);
  }
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.file.uri.pathSegments.last)),
      body: Center(
        child: StreamBuilder<PlayerState>(
          stream: _player.playerStateStream,
          builder: (context, snap) {
            final playing = snap.data?.playing ?? false;
            return IconButton(
              iconSize: 64,
              icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
              onPressed: () => playing ? _player.pause() : _player.play(),
            );
          },
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  LockType _type = LockType.password;
  final TextEditingController _p1 = TextEditingController();
  final TextEditingController _p2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _type = await SettingsStore.getLockType();
    _p1.text = (await SettingsStore.getPasscode(1)) ?? '';
    _p2.text = (await SettingsStore.getPasscode(2)) ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Lock Type'),
          const SizedBox(height: 8),
          SegmentedButton<LockType>(
            segments: const [
              ButtonSegment(value: LockType.pin, label: Text('PIN')),
              ButtonSegment(value: LockType.password, label: Text('Password')),
              ButtonSegment(value: LockType.pattern, label: Text('Pattern')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _p1,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Safe 1 code', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _p2,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Safe 2 code', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await SettingsStore.setLockType(_type);
              await SettingsStore.setPasscode(1, _p1.text);
              await SettingsStore.setPasscode(2, _p2.text);
              if (mounted) Navigator.of(context).pop();
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}
