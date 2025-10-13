// lib/widgets/timer_display.dart

import 'package:flutter/material.dart';
import 'package:timeismoney/models/single_timer.dart';

class TimerDisplay extends StatefulWidget {
  final SingleTimer timer;
  final int timerIndex;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback? onTimeEdited;
  final bool isCompact;

  const TimerDisplay({
    Key? key,
    required this.timer,
    required this.timerIndex,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    this.onTimeEdited,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> {
  bool _isExpanded = false;

  // Fonction pour afficher le dialogue d'édition du temps
  void _showEditTimeDialog(BuildContext context) {
    final currentDuration = widget.timer.elapsedDuration;
    
    final hoursController = TextEditingController(
      text: currentDuration.inHours.toString().padLeft(2, '0')
    );
    final minutesController = TextEditingController(
      text: (currentDuration.inMinutes % 60).toString().padLeft(2, '0')
    );
    final secondsController = TextEditingController(
      text: (currentDuration.inSeconds % 60).toString().padLeft(2, '0')
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éditer le temps'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Entrez le temps souhaité :',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Heures
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Heures', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: hoursController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  // Minutes
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Minutes', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: minutesController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  // Secondes
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Secondes', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: secondsController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final hours = int.tryParse(hoursController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;
                
                // Validation
                if (minutes > 59 || seconds > 59) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Les minutes et secondes doivent être < 60'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                final newDuration = Duration(
                  hours: hours,
                  minutes: minutes,
                  seconds: seconds,
                );
                
                widget.timer.setManualTime(newDuration);
                widget.onTimeEdited?.call(); // Notifier le contrôleur pour sauvegarder
                setState(() {}); // Rafraîchir l'affichage
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Temps modifié : ${formatDuration(newDuration)}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  // Fonction utilitaire pour formater la durée de manière dynamique
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return "${twoDigits(hours)} heures ${twoDigits(minutes)} min ${twoDigits(seconds)} sec";
    } else if (minutes > 0) {
      return "${twoDigits(minutes)} min ${twoDigits(seconds)} sec";
    } else {
      return "${twoDigits(seconds)} sec";
    }
  }

  // Fonction utilitaire pour formater l'argent avec 2 décimales
  String formatMoney(double amount) {
    return '${widget.timer.currency} ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double gainFontSize = widget.isCompact 
        ? (screenWidth * 0.12).clamp(30, 60).toDouble()
        : (screenWidth * 0.25).clamp(55, 120).toDouble();

    final double currentGrossGains = widget.timer.currentGains;
    final double currentNetGains = currentGrossGains * widget.timer.netConversionFactor;

    // Calcul dynamique basé sur les heures hebdomadaires du timer
    final double hoursPerWeek = widget.timer.weeklyHours;
    final double hoursPerMonth = (hoursPerWeek * 52) / 12; // Moyenne mensuelle
    final double hoursPerYear = hoursPerWeek * 52;
    
    final double monthlyGross = widget.timer.hourlyRate * hoursPerMonth;
    final double yearlyGross = widget.timer.hourlyRate * hoursPerYear;
    final double hourlyNet = widget.timer.hourlyRate * widget.timer.netConversionFactor;
    final double monthlyNet = monthlyGross * widget.timer.netConversionFactor;
    final double yearlyNet = yearlyGross * widget.timer.netConversionFactor;
    
    final String netPercentage = widget.timer.netRatePercentage.toStringAsFixed(0);
    final String chargesPercentage = (100.0 - widget.timer.netRatePercentage).toStringAsFixed(0);

    // Couleur distinctive selon l'index du timer
    final Color timerColor = widget.timerIndex == 0 
        ? Colors.cyan 
        : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: timerColor,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          
          // Titre du taux (si compact) - Affiche le nom du préréglage ou "Taux Personnalisé"
          // Hauteur fixe pour éviter les décalages
          if (widget.isCompact) ...[
            SizedBox(
              height: 40, // Hauteur fixe pour le titre
              child: Center(
              child: Text(
                widget.timer.rateTitle,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        
        // 1. Compteur d'Argent PRINCIPAL (GAIN NET)
        if (!widget.isCompact)
          SizedBox(
            height: 25, // Hauteur fixe pour le titre en mode plein écran
            child: Text(
              widget.timer.rateTitle,
              style: const TextStyle(
                fontSize: 18, 
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (widget.isCompact) const SizedBox(height: 5) else const SizedBox(height: 5),
        
        // Montant - Hauteur fixe pour l'alignement
        SizedBox(
          height: widget.isCompact ? 60 : 120, // Hauteur fixe pour le montant
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                formatMoney(currentNetGains),
                style: TextStyle(
                  fontSize: gainFontSize, 
                  fontWeight: FontWeight.w900,
                  color: Colors.yellowAccent, 
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
        ),
        
        const SizedBox(height: 2),

        // 2. Temps écoulé - Hauteur fixe (éditable si en pause)
        SizedBox(
          height: widget.isCompact ? 35 : 50, // Hauteur fixe pour le timer
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: !widget.timer.isRunning ? () => _showEditTimeDialog(context) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: widget.isCompact ? 20 : 32,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatDuration(widget.timer.elapsedDuration),
                        style: TextStyle(
                          fontSize: gainFontSize * 0.5, 
                          fontWeight: FontWeight.w900,
                          color: Colors.white, 
                        ),
                      ),
                    ),
                  ),
                  // Icône d'édition si le timer est en pause
                  if (!widget.timer.isRunning)
                    Icon(
                      Icons.edit,
                      color: Colors.grey.shade400,
                      size: widget.isCompact ? 16 : 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 25),
        
        // 3. Boutons de Contrôle - Hauteur fixe
        SizedBox(
          height: widget.isCompact ? 50 : 70, // Hauteur fixe pour les boutons
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        widget.timer.isRunning ? Icons.pause : Icons.play_arrow,
                        size: widget.isCompact ? 20 : 28,
                      ),
                      label: Text(widget.timer.isRunning ? 'STOP' : 'START'),
                      onPressed: widget.timer.isRunning ? widget.onStop : widget.onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.timer.isRunning ? Colors.red : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: widget.isCompact ? 12 : 20),
                        textStyle: TextStyle(fontSize: widget.isCompact ? 16 : 24, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 15),
                  
                  Expanded(
                    flex: 1, 
                    child: OutlinedButton(
                      onPressed: widget.timer.isRunning ? null : widget.onReset,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: widget.isCompact ? 12 : 20),
                        side: BorderSide(
                          color: widget.timer.isRunning ? Colors.grey.shade700 : Colors.grey, 
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Icon(Icons.refresh, size: widget.isCompact ? 20 : 28), 
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 25),
        
        // 4. Accordéon pour les détails
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Plus de détails',
                          style: TextStyle(
                            fontSize: widget.isCompact ? 14 : 16, 
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_isExpanded) ...[
                  const Divider(height: 1, color: Colors.white30),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Gains Brut Actuels :',
                              style: TextStyle(fontSize: widget.isCompact ? 14 : 16, color: Colors.grey),
                            ),
                            Text(
                              formatMoney(currentGrossGains),
                              style: TextStyle(fontSize: widget.isCompact ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          'Source : ${widget.timer.rateTitle}',
                          style: TextStyle(fontSize: widget.isCompact ? 12 : 14, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 15),
                        
                        Text(
                          'Taux BRUT : ${formatMoney(widget.timer.hourlyRate)} / heure',
                          style: TextStyle(fontSize: widget.isCompact ? 14 : 16, color: Colors.grey),
                        ),
                        
                        const SizedBox(height: 5),
                        
                        Text(
                          'Taux NET : ${formatMoney(hourlyNet)} / heure',
                          style: TextStyle(fontSize: widget.isCompact ? 14 : 16, color: Colors.greenAccent),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        Text(
                          'Estimations Annuelles (Base ${hoursPerWeek.toStringAsFixed(0)}h/sem.)',
                          style: TextStyle(fontSize: widget.isCompact ? 13 : 15, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const Divider(height: 15, color: Colors.white30),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mensuel Net estimé :', style: TextStyle(fontSize: widget.isCompact ? 13 : 15)),
                            Text(
                              formatMoney(monthlyNet),
                              style: TextStyle(fontSize: widget.isCompact ? 13 : 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mensuel Brut :', style: TextStyle(fontSize: widget.isCompact ? 13 : 15)),
                            Text(
                              formatMoney(monthlyGross),
                              style: TextStyle(fontSize: widget.isCompact ? 13 : 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Annuel Net estimé :', style: TextStyle(fontSize: widget.isCompact ? 13 : 15)),
                            Text(
                              formatMoney(yearlyNet),
                              style: TextStyle(fontSize: widget.isCompact ? 13 : 15, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Annuel Brut :', style: TextStyle(fontSize: widget.isCompact ? 13 : 15)),
                            Text(
                              formatMoney(yearlyGross),
                              style: TextStyle(fontSize: widget.isCompact ? 13 : 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Text(
                          '*Le Net est estimé à $netPercentage% du Brut (-$chargesPercentage% de charges). Ce taux est réglable dans les Réglages.',
                          style: TextStyle(fontSize: widget.isCompact ? 10 : 11, color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        ],
      ),
    );
  }
}
