import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _isPassword1Visible = false;
  bool _isPassword2Visible = false;

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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Lock Type'),
                    subtitle: SegmentedButton<LockType>(
                      segments: const [
                        ButtonSegment(value: LockType.pin, label: Text('PIN'), icon: Icon(Icons.pin)),
                        ButtonSegment(value: LockType.password, label: Text('Password'), icon: Icon(Icons.password)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) {
                        setState(() {
                          _type = s.first;
                          _p1.clear();
                          _p2.clear();
                        });
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.looks_one_outlined),
                    title: const Text('Safe 1 Code'),
                    subtitle: TextField(
                      controller: _p1,
                      obscureText: !_isPassword1Visible,
                      keyboardType: _type == LockType.pin ? TextInputType.number : TextInputType.text,
                      inputFormatters: _type == LockType.pin ? [FilteringTextInputFormatter.digitsOnly] : [],
                      decoration: InputDecoration(
                        hintText: 'Enter passcode for Safe 1',
                        suffixIcon: IconButton(
                          icon: Icon(_isPassword1Visible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPassword1Visible = !_isPassword1Visible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.looks_two_outlined),
                    title: const Text('Safe 2 Code'),
                    subtitle: TextField(
                      controller: _p2,
                      obscureText: !_isPassword2Visible,
                      keyboardType: _type == LockType.pin ? TextInputType.number : TextInputType.text,
                      inputFormatters: _type == LockType.pin ? [FilteringTextInputFormatter.digitsOnly] : [],
                      decoration: InputDecoration(
                        hintText: 'Enter passcode for Safe 2',
                        suffixIcon: IconButton(
                          icon: Icon(_isPassword2Visible ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _isPassword2Visible = !_isPassword2Visible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              await SettingsStore.setLockType(_type);
              await SettingsStore.setPasscode(1, _p1.text);
              await SettingsStore.setPasscode(2, _p2.text);
              if (mounted) Navigator.of(context).pop();
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
          )
        ],
      ),
    );
  }
}
