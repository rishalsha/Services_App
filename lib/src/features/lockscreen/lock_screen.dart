import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locker_app/src/core/services/settings_store.dart';
import 'package:locker_app/src/features/lockscreen/widgets/pattern_pad.dart';
import 'package:locker_app/src/features/lockscreen/widgets/pin_pad.dart';

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
