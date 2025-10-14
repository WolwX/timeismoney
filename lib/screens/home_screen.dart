// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/screens/settings_screen.dart'; 
import 'package:timeismoney/widgets/footer_bar.dart';
import 'package:timeismoney/widgets/timer_display.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MultiTimerController>();
    final activeTimers = controller.activeTimers;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF060608), // Même couleur que la footer bar
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            border: const Border(
              bottom: BorderSide(
                color: Color(0x22FFFFFF),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  // Icône de l'app à gauche (simple, sans effets)
                  Image.asset(
                    'assets/images/app_icon.png',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  
                  // Titre avec image personnalisée (remplace le texte 3D)
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/timeismoney-text-appbar.png',
                        height: 32, // Réduit de 40 à 32 (-20%)
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  // Bouton Settings à droite
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      tooltip: 'Réglages et Taux',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: activeTimers.isEmpty
                ? _buildNoTimersView()
                : activeTimers.length == 1
                    ? _buildSingleTimerView(controller, activeTimers[0], 0)
                    : _buildMultiTimerView(controller, activeTimers),
          ),
          const FooterBar(creatorName: 'XR'),
        ],
      ),
    );
  }

  Widget _buildNoTimersView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Aucun timer actif',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Activez un timer dans les réglages pour commencer',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleTimerView(MultiTimerController controller, timer, int index) {
    return Center( // Centrage vertical
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0), // Augmenté : 16→24 pour plus d'espace
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450), // Réduit encore : 600→450 pour plus d'élégance
            child: TimerDisplay(
              timer: timer,
              timerIndex: index,
              onStart: () => controller.startTimer(index),
              onStop: () => controller.stopTimer(index),
              onReset: () => controller.resetTimer(index),
              onTimeEdited: () => controller.editTimerTime(index),
              isCompact: true, // Mode compact pour avoir le format à 2 lignes
              isSingleView: true, // Vue single timer - polices plus grandes
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultiTimerView(MultiTimerController controller, List activeTimers) {
    return Builder(
      builder: (context) => Column(
        children: [
          // Supprimé le SizedBox pour que la barre centrale monte jusqu'à l'AppBar
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Permet d'étirer verticalement
              children: [
              Expanded(
                child: Center( // Centrage vertical
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0), // Retour au padding horizontal uniquement
                      child: TimerDisplay(
                      timer: activeTimers[0],
                      timerIndex: controller.timers.indexOf(activeTimers[0]),
                      onStart: () => controller.startTimer(controller.timers.indexOf(activeTimers[0])),
                      onStop: () => controller.stopTimer(controller.timers.indexOf(activeTimers[0])),
                      onReset: () => controller.resetTimer(controller.timers.indexOf(activeTimers[0])),
                      onTimeEdited: () => controller.editTimerTime(controller.timers.indexOf(activeTimers[0])),
                      isCompact: true,
                    ),
                  ),
                ), // fin SingleChildScrollView
                ), // fin Center
              ), // fin premier Expanded
              Container(
                width: 36, // Réduit de 40 à 36 pour gagner de l'espace sur mobile
                decoration: BoxDecoration(
                  // Dégradé 3D : noir profond en haut et bas, gris foncé au milieu
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A0A0A), // Noir profond en haut
                      Color(0xFF1A1A1A), // Gris très foncé au milieu (était 0xFF2A2A2A)
                      Color(0xFF0A0A0A), // Noir profond en bas
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                  border: Border.symmetric(
                    vertical: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.0), // Bordures plus visibles
                  ),
                  // Ombres pour effet 3D de relief
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(-2, 0),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.05),
                      offset: const Offset(2, 0),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Texture subtile (lignes horizontales pour effet console)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ConsolePanelPainter(),
                      ),
                    ),
                    // Contenu par-dessus la texture
                    Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0), // Réduit de 4.0 à 2.0
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bouton Play/Pause dynamique selon l'état des timers
                      Tooltip(
                        message: controller.timers.any((t) => t.isRunning) ? 'Arrêter tous' : 'Démarrer tous',
                        child: IconButton(
                          icon: Icon(
                            controller.timers.any((t) => t.isRunning) ? Icons.pause : Icons.play_arrow,
                            color: controller.timers.any((t) => t.isRunning) ? Colors.red : Colors.green,
                          ),
                          onPressed: () {
                            if (controller.timers.any((t) => t.isRunning)) {
                              controller.stopAllTimers();
                            } else {
                              controller.startAllTimers();
                            }
                          },
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Tooltip(
                        message: 'Réinitialiser tous',
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.orange),
                          onPressed: () => controller.resetAllTimers(),
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, thickness: 1),
                      const SizedBox(height: 20),
                      Tooltip(
                        message: 'Synchroniser les timers',
                        child: IconButton(
                          icon: const Icon(Icons.sync, color: Colors.blue),
                          onPressed: () {
                            controller.synchronizeTimers();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Timers synchronisés !'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                    ), // fin Padding
                  ], // fin Stack children
                ), // fin Stack
              ), // fin Container barre centrale
              if (activeTimers.length > 1)
                Expanded(
                  child: Center( // Centrage vertical
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0), // Retour au padding horizontal uniquement
                        child: TimerDisplay(
                        timer: activeTimers[1],
                        timerIndex: controller.timers.indexOf(activeTimers[1]),
                        onStart: () => controller.startTimer(controller.timers.indexOf(activeTimers[1])),
                        onStop: () => controller.stopTimer(controller.timers.indexOf(activeTimers[1])),
                        onReset: () => controller.resetTimer(controller.timers.indexOf(activeTimers[1])),
                        onTimeEdited: () => controller.editTimerTime(controller.timers.indexOf(activeTimers[1])),
                        isCompact: true,
                        referenceTimer: activeTimers[0], // Le timer de gauche est la référence pour la conversion
                      ),
                    ),
                  ), // fin SingleChildScrollView
                  ), // fin Center
                ), // fin deuxième Expanded
            ],
          ),
        ),
      ],
      ),
    );
  }
}

// CustomPainter pour créer une texture de console sur la barre centrale
class _ConsolePanelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Lignes horizontales subtiles espacées régulièrement (effet console/grille)
    const spacing = 4.0;
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Quelques lignes verticales très subtiles pour renforcer l'effet
    final verticalPaint = Paint()
      ..color = Colors.white.withOpacity(0.01)
      ..strokeWidth = 0.3
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      verticalPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      verticalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
