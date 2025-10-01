// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/timer_controller.dart';
import 'package:timeismoney/screens/settings_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fonction utilitaire pour formater la durée en HH:MM:SS
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Fonction utilitaire pour formater l'argent avec 2 décimales
  String formatMoney(TimerController controller, double amount) {
    return '${controller.currency} ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final timerController = context.watch<TimerController>();
    
    // --- Responsive : Calcul de la taille de police dynamique ---
    final screenWidth = MediaQuery.of(context).size.width;
    final double gainFontSize = (screenWidth * 0.25).clamp(55, 120).toDouble();

    final String buttonText = timerController.isRunning ? 'STOP' : 'START';
    final Function buttonAction = timerController.isRunning
        ? timerController.stopTimer
        : timerController.startTimer;
    
    // --- CALCULS : Gains et Estimations ---
    final double netConversionFactor = timerController.netConversionFactor; 
    
    // Gains Actuels
    final double currentGrossGains = timerController.currentGains;
    final double currentNetGains = currentGrossGains * netConversionFactor;
    
    // Estimations (Base 35h/sem.)
    const double hoursPerMonth = 151.67; 
    const double hoursPerYear = 1820;    
    
    final double monthlyGross = timerController.hourlyRate * hoursPerMonth;
    final double yearlyGross = timerController.hourlyRate * hoursPerYear;
    final double hourlyNet = timerController.hourlyRate * netConversionFactor;
    final double monthlyNet = monthlyGross * netConversionFactor;
    final double yearlyNet = yearlyGross * netConversionFactor;
    
    // Affichage des pourcentages pour la note
    final String netPercentage = timerController.netRatePercentage.toStringAsFixed(0);
    final String chargesPercentage = (100.0 - timerController.netRatePercentage).toStringAsFixed(0);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Is Money'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Réglages et Taux',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 1. Compteur d'Argent PRINCIPAL (GAIN NET) - En Jaune
              const Text(
                'Gains NETS Actuels :',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: FittedBox(
                  child: Text(
                    formatMoney(timerController, currentNetGains),
                    style: TextStyle(
                      fontSize: gainFontSize, 
                      fontWeight: FontWeight.w900,
                      color: Colors.yellowAccent, // CHANGEMENT : Jaune pour le Net
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.yellow.shade700,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 10),

              // 2. Compteur secondaire (GAIN BRUT) - Plus grand et en Vert
              Text(
                'Brut : ${formatMoney(timerController, currentGrossGains)}',
                style: const TextStyle(fontSize: 22, color: Colors.green), // CHANGEMENT : Plus grand et Vert
              ),

              // CHANGEMENT : Affichage de la Source déplacé ici
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Source : ${timerController.rateTitle}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              // FIN CHANGEMENT DE BLOC

              const SizedBox(height: 40),

              // 3. Compteurs (Temps et Taux)
              Text(
                'Temps écoulé : ${formatDuration(timerController.elapsedDuration)}',
                style: const TextStyle(fontSize: 24),
              ),
              
              const SizedBox(height: 10),

              // Taux Horaire BRUT
              Text(
                'Taux BRUT : ${formatMoney(timerController, timerController.hourlyRate)} / heure',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              
              // Taux Horaire NET (Estimation)
              Text(
                'Taux NET : ${formatMoney(timerController, hourlyNet)} / heure',
                style: const TextStyle(fontSize: 16, color: Colors.greenAccent),
              ),
              
              const SizedBox(height: 40),
              
              // 4. Section Estimations de Salaire (Brut et Net)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estimations Annuelles (Base 35h/sem.)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const Divider(height: 15, color: Colors.white30),
                    
                    // Ligne Mensuel NET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mensuel Net estimé :', style: TextStyle(fontSize: 16)),
                        Text(
                          formatMoney(timerController, monthlyNet),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    // Ligne Mensuel BRUT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mensuel Brut :', style: TextStyle(fontSize: 16)),
                        Text(
                          formatMoney(timerController, monthlyGross),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Colors.white30),

                    // Ligne Annuel NET
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Annuel Net estimé :', style: TextStyle(fontSize: 16)),
                        Text(
                          formatMoney(timerController, yearlyNet),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                        ),
                      ],
                    ),
                    // Ligne Annuel BRUT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Annuel Brut :', style: TextStyle(fontSize: 16)),
                        Text(
                          formatMoney(timerController, yearlyGross),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        '*Le Net est estimé à ${netPercentage}% du Brut (-${chargesPercentage}% de charges). Ce taux est réglable dans les Réglages.',
                        style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                      ),
                    )
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 5. Boutons de Contrôle (START/STOP et RESET)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Row(
                        children: [
                          // Bouton START/STOP : Texte et Icône
                          Expanded(
                            flex: 3, 
                            child: ElevatedButton.icon(
                              icon: Icon(
                                timerController.isRunning ? Icons.pause : Icons.play_arrow,
                                size: 28,
                              ),
                              label: Text(buttonText),
                              onPressed: () => buttonAction(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: timerController.isRunning ? Colors.red : Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 25),
                                textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 15),
                          
                          // Bouton RESET
                          Expanded(
                            flex: 1, 
                            child: OutlinedButton(
                              onPressed: timerController.isRunning 
                                ? null 
                                : timerController.resetSession, 
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 25),
                                side: BorderSide(
                                  color: timerController.isRunning ? Colors.grey.shade700 : Colors.grey, 
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Icon(Icons.refresh, size: 28), 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}