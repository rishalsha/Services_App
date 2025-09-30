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
