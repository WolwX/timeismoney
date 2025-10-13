import 'package:flutter/material.dart';
import 'package:timeismoney/screens/home_screen.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:timeismoney/widgets/animated_hourglass.dart';
import 'package:timeismoney/widgets/falling_currency.dart';
import 'package:timeismoney/widgets/footer_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _hourglassScale;
  // _hourglassColor removed; using local SVG asset now
  late Animation<double> _titleOpacity;
  Timer? _navTimer;

  // We'll create staggered animations for multiple coins
  final int _coinCount = 4;
  late List<Animation<Offset>> _coinSlideAnims;
  late List<Animation<double>> _coinRotateAnims;
  late List<Animation<double>> _coinScaleAnims;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _hourglassScale = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)),
    );

    // No color tween needed for the SVG hourglass

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _coinSlideAnims = List.generate(_coinCount, (i) {
      final start = 0.2 + i * 0.12;
      final end = start + 0.6;
      return Tween<Offset>(begin: Offset(0, -0.8 - i * 0.1), end: Offset(0, 0.6 + i * 0.05)).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeIn)),
      );
    });

    _coinRotateAnims = List.generate(_coinCount, (i) {
      final start = 0.2 + i * 0.12;
      final end = start + 0.6;
      return Tween<double>(begin: -0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeInOut)),
      );
    });

    _coinScaleAnims = List.generate(_coinCount, (i) {
      final start = 0.2 + i * 0.12;
      final end = start + 0.6;
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9).chain(CurveTween(curve: Curves.easeIn)), weight: 1),
      ]).animate(CurvedAnimation(parent: _controller, curve: Interval(start, end.clamp(0.0, 1.0))));
    });

    _controller.forward();
  // debug
  // ignore: avoid_print
  print('[Splash] controller.forward() called');

    // Navigate after animation completes
    _controller.addStatusListener((status) {
      // debug
      // ignore: avoid_print
      print('[Splash] animation status: $status');
      if (status == AnimationStatus.completed && mounted) {
        // ignore: avoid_print
        print('[Splash] animation completed -> navigate');
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    });

    // Fallback: ensure navigation even if status listener is missed for any reason
    // set fallback slightly longer than the animation duration so we don't cut it off
    _navTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      // ignore: avoid_print
      print('[Splash] nav timer fired -> navigate fallback (attempting)');
      try {
        Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
        // ignore: avoid_print
        print('[Splash] nav timer navigate succeeded');
      } catch (e, st) {
        // ignore: avoid_print
        print('[Splash] nav timer navigate FAILED: $e');
        // ignore: avoid_print
        print(st);
      }
    });

    // debug
    // ignore: avoid_print
    print('[Splash] initState completed, nav timer scheduled');
  }

  @override
  void dispose() {
    _controller.dispose();
    _navTimer?.cancel();
    super.dispose();
  }

  Widget _buildCoin(int index, IconData icon, double leftOffset) {
    return SlideTransition(
      position: _coinSlideAnims[index],
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(leftOffset, 0),
            child: Transform.rotate(
              angle: _coinRotateAnims[index].value,
              child: Transform.scale(
                scale: _coinScaleAnims[index].value,
                child: Icon(icon, size: 36, color: Colors.yellow.shade600, shadows: [const Shadow(blurRadius: 6, color: Colors.black38)]),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF001219), Color(0xFF001827)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lightweight background particles: low count and reduced opacity to avoid UI blocking
            Opacity(
              opacity: 0.55,
              child: const FallingCurrencyBackground(count: 12),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              // Local SVG hourglass (replaces previous network Lottie)
              // Render fallback AnimatedHourglass first (in case SVG fails to render)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = (_controller.value).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: _hourglassScale.value,
                    child: SizedBox(
                      width: 180,
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Always show the painted hourglass to avoid SVG/network loading stalls
                          AnimatedHourglass(progress: progress, sandColor: Colors.yellow.shade600, outlineColor: Colors.white54, size: 150),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Coins stack
              SizedBox(
                height: 120,
                width: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < _coinCount; i++)
                      _buildCoin(i, i.isEven ? Icons.monetization_on : Icons.attach_money, (i - 1.5) * 22.0),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              FadeTransition(
                opacity: _titleOpacity,
                child: const Text(
                  'Time Is Money',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
                // Footer bar with credits (reusable)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: FooterBar(
                    creatorName: 'XR',
                    version: 'v1.3',
                    minimal: true,
                    onCreatorTap: () {
                      // optional: open about page later
                    },
                  ),
                ),
      ],
    ),
      ),
    );
  }
}