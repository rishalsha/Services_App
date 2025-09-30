import 'package:flutter/material.dart';

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
