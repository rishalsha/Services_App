import 'package:flutter/material.dart';

class ForwardSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Duration skipDuration;

  const ForwardSkipButton({
    super.key,
    required this.onPressed,
    this.skipDuration = const Duration(seconds: 10),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.forward_10),
      onPressed: onPressed,
    );
  }
}
