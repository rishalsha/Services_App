import 'package:flutter/material.dart';
import 'package:locker_app/src/core/services/settings_store.dart';

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
