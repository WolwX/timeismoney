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
  final VoidCallback? onAnimationCancelled; // Nouveau callback pour annulation

  const CelebrationAnimation({
    super.key,
    this.onAnimationComplete,
    this.onAnimationCancelled,
  });

  @override
  State<CelebrationAnimation> createState() => _CelebrationAnimationState();
}

class _CelebrationAnimationState extends State<CelebrationAnimation>
    with TickerProviderStateMixin {
  final List<CelebrationParticle> _particles = [];
  late AnimationController _controller;
  Timer? _particleTimer;
  Timer? _safetyTimer; // Timer de sécurité pour éviter les blocages

  // Limite de particules pour éviter la surcharge
  static const int _maxParticles = 10; // Réduit drastiquement à 10 particules max

  // Liste des smileys à utiliser
  final List<String> _emojis = [
    '🎉', '✨', '�', // Réduit la liste pour moins de variété
  ];

  final List<Color> _colors = [
    Colors.yellow,
    Colors.orange,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Réduit à 1.5 secondes
    );

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeAnimation();
      }
    });

    // Timer de sécurité : arrêter l'animation après 2 secondes maximum (réduit de 3)
    _safetyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        debugPrint('CelebrationAnimation: Safety timer triggered');
        _forceStopAnimation();
      }
    });

    debugPrint('CelebrationAnimation: Starting animation');
    _startAnimation();
  }

  void _startAnimation() {
    // Créer des particules initiales
    _createParticles();

    // Programmer la création de nouvelles particules beaucoup moins fréquemment
    _particleTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) { // Augmenté à 1 seconde
      if (_controller.isAnimating) {
        _createParticles();
      }
    });

    _controller.forward();
  }

  void _createParticles() {
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    // Créer très peu de particules à chaque fois
    final particleCount = min(1 + random.nextInt(2), _maxParticles - _particles.length); // Réduit à 1-2 particules max
    if (particleCount <= 0) return; // Ne pas créer si on atteint la limite

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
    final deltaTime = 1 / 15.0; // Réduit à 15 FPS pour soulager encore plus le CPU

    // Mettre à jour toutes les particules
    for (final particle in _particles) {
      particle.update(deltaTime);
    }

    // Supprimer les particules mortes
    _particles.removeWhere((particle) => particle.isDead());

    // Si plus de particules et animation terminée, nettoyer
    if (_particles.isEmpty && !_controller.isAnimating) {
      _completeAnimation();
    }

    setState(() {});
  }

  // Méthode appelée quand l'animation se termine normalement
  void _completeAnimation() {
    _cleanup();
    widget.onAnimationComplete?.call();
  }

  // Méthode pour forcer l'arrêt de l'animation (timeout ou clic utilisateur)
  void _forceStopAnimation() {
    _cleanup();
    widget.onAnimationCancelled?.call();
  }

  // Nettoyer toutes les ressources
  void _cleanup() {
    _controller.stop();
    _particleTimer?.cancel();
    _safetyTimer?.cancel();
    _particles.clear();
  }

  @override
  void dispose() {
    _cleanup();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer( // Retour à IgnorePointer pour éviter les interférences de gestes
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