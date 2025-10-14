import 'package:flutter/material.dart';
import 'package:timeismoney/screens/home_screen.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:timeismoney/widgets/falling_currency.dart';
import 'package:timeismoney/widgets/footer_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;
  late Animation<double> _titleOpacity;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 5500)); // Augmenté de 3500 à 5500ms (+2 secondes)

    _iconScale = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack)),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.32, 0.64, curve: Curves.easeIn)), // Ajusté pour garder le même timing absolu (1750ms - 3500ms sur 5500ms)
    );

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
    _navTimer = Timer(const Duration(milliseconds: 5700), () { // Augmenté de 3700 à 5700ms
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
              child: const FallingCurrencyBackground(count: 40), // Réduit de 80 à 40 pour éviter le lag
            ),
            // Remonter l'ensemble vers le haut avec Positioned
            Positioned(
              top: 50, // Réduit de 80 à 50 pour remonter l'icône plus haut
              left: 0,
              right: 0,
              child: Stack( // Changé de Column à Stack pour superposer les éléments
                alignment: Alignment.center,
                clipBehavior: Clip.none, // Permet au texte de dépasser sans être coupé
                children: [
              // Icône de l'application en grand format avec animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _iconScale.value,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(80),
                        // Ombres supprimées pour un effet plus net
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Titre avec image (superposé en bas de l'icône)
              Positioned(
                bottom: -125, // Descendu de -25 à -125 (100 pixels plus bas)
                child: FadeTransition(
                  opacity: _titleOpacity,
                  child: Image.asset(
                    'assets/images/timeismoney-text-splash-screen.png',
                    width: 315, // Réduit de 350 à 315 (-10%)
                    fit: BoxFit.contain,
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
                    minimal: true,
                    majorOnly: true,
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