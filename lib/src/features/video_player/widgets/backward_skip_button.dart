import 'package:flutter/material.dart';

class BackwardSkipButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Duration skipDuration;

  const BackwardSkipButton({
    super.key,
    required this.onPressed,
    this.skipDuration = const Duration(seconds: 10),
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.replay_10),
      onPressed: onPressed,
    );
  }
}
