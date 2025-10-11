import 'package:flutter/material.dart';

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
        width: 16,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: filled ? Theme.of(context).colorScheme.primary : Colors.transparent,
          border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
          shape: BoxShape.circle,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final List<Widget> dots = List.generate(6, (i) => _dot(i < _pin.length));
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: dots),
        const SizedBox(height: 32),
        _row(['1', '2', '3']),
        const SizedBox(height: 16),
        _row(['4', '5', '6']),
        const SizedBox(height: 16),
        _row(['7', '8', '9']),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _key('⌫', onTap: _backspace),
            const SizedBox(width: 16),
            _key('0', onTap: () => _tap('0')),
            const SizedBox(width: 16),
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
          if (l != labels.last) const SizedBox(width: 16),
        ]
      ],
    );
  }

  Widget _key(String label, {required VoidCallback onTap}) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        ),
        child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
