// lib/widgets/celebration_overlay.dart

import 'package:flutter/material.dart';

/// Overlay simple de célébration qui apparaît quand un timer atteint 0
class CelebrationOverlay extends StatelessWidget {
  final Duration achievedTime;
  final VoidCallback onDismiss;

  const CelebrationOverlay({
    super.key,
    required this.achievedTime,
    required this.onDismiss,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.yellow,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Emojis de fête
                const Text(
                  '🎉 ✨ 🎊',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),

                // Message de félicitations
                const Text(
                  'FÉLICITATIONS !',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Temps réalisé
                Text(
                  'Vous avez atteint votre objectif\nen ${_formatDuration(achievedTime)}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Emojis supplémentaires
                const Text(
                  '🏆 💪 🎯',
                  style: TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 16),

                // Instruction pour fermer
                Text(
                  'Appuyez pour continuer',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}