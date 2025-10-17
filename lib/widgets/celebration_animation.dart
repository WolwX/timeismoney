// lib/widgets/celebration_animation.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Représente une particule de célébration avec un smiley
class CelebrationParticle {
  Offset position;
  Offset velocity;
  double rotation;
  double rotationSpeed;
  double scale;
  double opacity;
  String emoji;
  Color color;

  CelebrationParticle({
    required this.position,
    required this.velocity,
    required this.rotation,
    required this.rotationSpeed,
    required this.scale,
    required this.opacity,
    required this.emoji,
    required this.color,
  });

  void update(double deltaTime) {
    position += velocity * deltaTime;
    rotation += rotationSpeed * deltaTime;
    opacity = max(0.0, opacity - deltaTime * 0.5); // Fade out
    scale = max(0.0, scale - deltaTime * 0.1); // Shrink
  }

  bool isDead() => opacity <= 0 || scale <= 0;
}

/// Widget d'animation de célébration avec des smileys
class CelebrationAnimation extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const CelebrationAnimation({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  final List<CelebrationParticle> _particles = [];
  late AnimationController _controller;
  Timer? _particleTimer;

  // Liste des smileys à utiliser
  final List<String> _emojis = [
    '🎉', '🎊', '✨', '🎈', '🎆', '🎇', '🎀', '🎁',
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣',
    '🥳', '😎', '🤩', '😍', '🥰', '😘', '😉', '😊',
    '💯', '🔥', '⭐', '🌟', '💫', '✨', '💥', '🎯',
  ];

  final List<Color> _colors = [
    Colors.yellow,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blue,
    Colors.cyan,
    Colors.green,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    _startAnimation();
  }

  void _startAnimation() {
    // Créer des particules initiales
    _createParticles();

    // Programmer la création de nouvelles particules
    _particleTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_controller.isAnimating) {
        _createParticles();
      }
    });

    _controller.forward();
  }

  void _createParticles() {
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    // Créer 5-10 particules à chaque fois
    final particleCount = 5 + random.nextInt(6);

    for (int i = 0; i < particleCount; i++) {
      final startX = screenSize.width / 2 + (random.nextDouble() - 0.5) * 100;
      final startY = screenSize.height * 0.7; // Démarrer depuis le bas

      final angle = (random.nextDouble() - 0.5) * pi; // Angle aléatoire
      final speed = 200 + random.nextDouble() * 300; // Vitesse aléatoire

      _particles.add(CelebrationParticle(
        position: Offset(startX, startY),
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 100), // Légère gravité
        rotation: random.nextDouble() * 2 * pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4 * pi, // Rotation aléatoire
        scale: 0.5 + random.nextDouble() * 0.5,
        opacity: 1.0,
        emoji: _emojis[random.nextInt(_emojis.length)],
        color: _colors[random.nextInt(_colors.length)],
      ));
    }
  }

  void _updateParticles() {
    final deltaTime = 1 / 60.0; // 60 FPS

    // Mettre à jour toutes les particules
    for (final particle in _particles) {
      particle.update(deltaTime);
    }

    // Supprimer les particules mortes
    _particles.removeWhere((particle) => particle.isDead());

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: CelebrationPainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

/// Peintre pour dessiner les particules de célébration
class CelebrationPainter extends CustomPainter {
  final List<CelebrationParticle> particles;

  CelebrationPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: particle.emoji,
          style: TextStyle(
            fontSize: 30 * particle.scale,
            color: particle.color.withOpacity(particle.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CelebrationPainter oldDelegate) {
    return true; // Toujours redessiner pour l'animation
  }
}