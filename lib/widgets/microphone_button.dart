import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MicrophoneButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MicrophoneButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isListening
                  ? [
                      Colors.red.shade400,
                      Colors.red.shade700,
                    ]
                  : [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withBlue(200),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: (isListening ? Colors.red : Theme.of(context).colorScheme.primary)
                    .withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isListening ? Icons.mic : Icons.mic_none,
            color: Colors.white,
            size: 40,
          ),
        )
            .animate(target: isListening ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.1, 1.1),
              duration: 1.seconds,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.1, 1.1),
              end: const Offset(1, 1),
              duration: 1.seconds,
              curve: Curves.easeInOut,
            ),
      ),
    );
  }
}
