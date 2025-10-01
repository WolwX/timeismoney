import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timeismoney/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Durée de l'animation : 3 secondes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Animation d'opacité (Fade-in/Fade-out)
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        // L'opacité atteint 1.0 au milieu de l'animation
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn), 
      ),
    );
    
    // Animation de déplacement (simule la chute des pièces)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5), // Commence au-dessus
      end: const Offset(0, 0.5),    // Finit en dessous
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Démarre l'animation
    _controller.forward();
    
    // Après 3 secondes, navigue vers l'écran principal
    Timer(const Duration(seconds: 3), () {
      // On vérifie que le widget est toujours monté
      if (mounted) { 
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  // Widget pour l'icône de monnaie animée
  Widget _buildAnimatedIcon(IconData icon) {
    return SlideTransition(
      position: _slideAnimation, // Utilise l'animation de chute
      child: Icon(
        icon,
        size: 40,
        color: Colors.yellow.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ---------------- Sablier (Visuel Central) ----------------
              Stack(
                alignment: Alignment.center,
                children: [
                  // Icône de base du Sablier (le contenant)
                  const Icon(
                    Icons.hourglass_empty,
                    size: 150,
                    color: Colors.tealAccent,
                  ),
                  
                  // Pièce 1 qui tombe
                  _buildAnimatedIcon(Icons.monetization_on),
                  
                  // Pièce 2 qui tombe (décalée pour un meilleur effet)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildAnimatedIcon(Icons.attach_money),
                  ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              // ---------------- Texte Principal ----------------
              const Text(
                'Time Is Money',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}