import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A lightweight particle background that paints falling currency symbols
/// (like gentle snow). Designed to be non-blocking and loop indefinitely.
class FallingCurrencyBackground extends StatefulWidget {
  /// Number of symbols to render.
  final int count;
  /// Symbols to pick from (e.g. €, $, £, ¥)
  final List<String> symbols;
  /// Colors to use for symbols.
  final List<Color> colors;

  const FallingCurrencyBackground({
    Key? key,
    // Augmenté de 50 à 80 pour beaucoup plus de monnaies
    this.count = 80,
    // Ajout de nombreuses monnaies du monde entier : rouble, yuan, rand, naira, dirham, etc.
    this.symbols = const ['€', r'$', '£', '¥', '₽', '₹', '₣', '₦', '₴', '₱', '฿', '₪', '₫', '₩', '₨', '₵', 'R', 'د.إ'],
    // une seule couleur or unie pour un rendu plus cohérent et "3D"
    this.colors = const [Color(0xFFFFD700)],
  }) : super(key: key);

  @override
  State<FallingCurrencyBackground> createState() => _FallingCurrencyBackgroundState();
}

class _Particle {
  double x; // 0..1
  double y; // 0..1
  double speed; // fraction per second
  double size; // relative to shortest side
  double rotation; // radians
  double horizontalSpeed; // mouvement horizontal aléatoire
  String symbol;
  double opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.horizontalSpeed,
    required this.symbol,
    required this.opacity,
    required this.color,
  });
}

class _FallingCurrencyBackgroundState extends State<FallingCurrencyBackground> {
  Timer? _timer;
  final List<_Particle> _particles = [];
  late final Random _rand;

  @override
  void initState() {
    super.initState();
    _rand = Random(); // Supprimé la seed fixe (123456) pour un vrai aléatoire
  // Use a periodic timer to update particle positions at ~8 FPS to reduce UI churn
  _timer = Timer.periodic(const Duration(milliseconds: 125), (_) => _tick());

    // initialize particles
    for (var i = 0; i < widget.count; i++) {
      _particles.add(_createParticle(randomOffset: true));
    }
  }

  _Particle _createParticle({bool randomOffset = false}) {
    final x = _rand.nextDouble();
    final y = randomOffset ? _rand.nextDouble() * 1.5 : (-0.1 - _rand.nextDouble() * 0.3); // Démarrage plus espacé en hauteur
    final speed = 0.015 + _rand.nextDouble() * 0.12; // Vitesse beaucoup plus variée (0.015 à 0.135)
    final size = 0.015 + _rand.nextDouble() * 0.08; // Tailles plus variées
    final rot = (_rand.nextDouble() * 2 - 1) * pi; // Rotation complète (toutes directions)
    final horizontalSpeed = (_rand.nextDouble() * 2 - 1) * 0.025; // Mouvement horizontal plus prononcé
    final sym = widget.symbols[_rand.nextInt(widget.symbols.length)];
    final opacity = 0.3 + _rand.nextDouble() * 0.7;
    final color = widget.colors[_rand.nextInt(widget.colors.length)];
    return _Particle(x: x, y: y, speed: speed, size: size, rotation: rot, horizontalSpeed: horizontalSpeed, symbol: sym, opacity: opacity, color: color);
  }

  void _tick() {
    // Update positions using a larger timestep since updates are less frequent
    const step = 1.0 / 12.0; // approximate seconds per tick (12 FPS)
    if (!mounted) return;
    setState(() {
      for (var p in _particles) {
        p.y += p.speed * step;
        // Mouvement horizontal basé sur horizontalSpeed (beaucoup plus prononcé)
        p.x += p.horizontalSpeed * step * 1.5;
        // Oscillation sinusoïdale plus marquée pour des trajectoires variées
        p.x += (sin(p.rotation + p.y * 8) * 0.008);
        // Rotation variée selon la vitesse
        p.rotation += 0.005 * (p.speed * 60);
        if (p.y > 1.15) {
          // reset above the top with new random x
          final newP = _createParticle(randomOffset: false);
          p.x = newP.x;
          p.y = -0.1 - _rand.nextDouble() * 0.4; // Réinitialisation plus espacée
          p.speed = newP.speed;
          p.size = newP.size;
          p.rotation = newP.rotation;
          p.horizontalSpeed = newP.horizontalSpeed;
          p.symbol = newP.symbol;
          p.opacity = newP.opacity;
        }
        // wrap x between 0..1
        if (p.x < -0.3) p.x = 1.3;
        if (p.x > 1.3) p.x = -0.3;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _CurrencyPainter(particles: _particles),
        size: Size.infinite,
      ),
    );
  }
}

class _CurrencyPainter extends CustomPainter {
  final List<_Particle> particles;

  _CurrencyPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = min(size.width, size.height);
    for (var p in particles) {
      final dx = p.x * size.width;
      final dy = p.y * size.height;
      final fontSize = p.size * shortest;
  final c = p.color.withAlpha((p.opacity * 255).round());
  final shadowColor = Color(0xFF8B6B00).withAlpha((p.opacity * 200).round());
  final shadowStyle = TextStyle(fontSize: fontSize, color: shadowColor, fontWeight: FontWeight.w800);
  final mainStyle = TextStyle(fontSize: fontSize, color: c, fontWeight: FontWeight.w700);

  final shadowSpan = TextSpan(text: p.symbol, style: shadowStyle);
  final shadowTp = TextPainter(text: shadowSpan, textDirection: TextDirection.ltr);
  shadowTp.layout();

  final mainSpan = TextSpan(text: p.symbol, style: mainStyle);
  final tp = TextPainter(text: mainSpan, textDirection: TextDirection.ltr);
  tp.layout();

  canvas.save();
  // draw subtle shadow slightly offset for 3D effect
  canvas.translate(dx - tp.width / 2 + fontSize * 0.08, dy - tp.height / 2 + fontSize * 0.08);
  canvas.rotate(p.rotation);
  shadowTp.paint(canvas, Offset.zero);
  canvas.restore();

  canvas.save();
  canvas.translate(dx - tp.width / 2, dy - tp.height / 2);
  canvas.rotate(p.rotation);
  tp.paint(canvas, Offset.zero);
  canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CurrencyPainter oldDelegate) => true;
}
