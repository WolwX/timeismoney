// lib/widgets/timer_display.dart

import 'package:flutter/material.dart';
import 'package:timeismoney/models/single_timer.dart';
import 'package:timeismoney/services/exchange_rate_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';

class TimerDisplay extends StatefulWidget {
  final SingleTimer timer;
  final int timerIndex;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onReset;
  final VoidCallback? onTimeEdited;
  final bool isCompact;
  final bool isSingleView; // Nouveau paramètre pour différencier vue single vs multi
  final SingleTimer? referenceTimer; // Timer de référence pour la conversion (timer de gauche)

  const TimerDisplay({
    Key? key,
    required this.timer,
    required this.timerIndex,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    this.onTimeEdited,
    this.isCompact = false,
    this.isSingleView = false, // Par défaut false (vue multi)
    this.referenceTimer, // Optionnel : utilisé uniquement pour le timer de droite
  }) : super(key: key);

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // Animation de rotation continue (6 secondes par tour - rythme moyen)
    _rotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    // Démarre l'animation si le timer est actif
    if (widget.timer.isRunning) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Synchronise l'animation avec l'état du timer
    if (widget.timer.isRunning && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.timer.isRunning && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

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
    
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    // Cas 1 : Avec jours (≥ 1 jour) - format abrégé
    if (days > 0) {
      return "${twoDigits(days)} j ${twoDigits(hours)} h ${twoDigits(minutes)} min";
    }
    // Cas 2 : Avec heures (≥ 1 heure, < 1 jour) - "heures" en entier
    else if (hours > 0) {
      return "${twoDigits(hours)} ${hours > 1 ? 'heures' : 'heure'} ${twoDigits(minutes)} min ${twoDigits(seconds)} sec";
    }
    // Cas 3 : Avec minutes (≥ 1 minute, < 1 heure)
    else if (minutes > 0) {
      return "${twoDigits(minutes)} min ${twoDigits(seconds)} sec";
    }
    // Cas 4 : Que des secondes (< 1 minute)
    else {
      return "$seconds seconde${seconds > 1 ? 's' : ''}";
    }
  }

  // Widget pour afficher le temps sur 2 lignes en mode compact (avec heures ou jours)
  Widget _buildCompactTimeDisplay(Duration duration, double fontSize) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    // Cas avec jours : format abrégé
    if (days > 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1 : Jours
          Text(
            "${twoDigits(days)} j",
            style: TextStyle(
              fontSize: fontSize * 0.6,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          // Ligne 2 : Heures et Minutes (abrégé)
          Text(
            "${twoDigits(hours)} h ${twoDigits(minutes)} min",
            style: TextStyle(
              fontSize: fontSize * 0.45,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              height: 1.2,
            ),
          ),
        ],
      );
    }
    // Cas avec heures (sans jours) : "heures" en entier
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne 1 : Heures en entier
          Text(
            "${twoDigits(hours)} ${hours > 1 ? 'heures' : 'heure'}",
            style: TextStyle(
              fontSize: fontSize * 0.6,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          // Ligne 2 : Minutes et Secondes
          Text(
            "${twoDigits(minutes)} min ${twoDigits(seconds)} sec",
            style: TextStyle(
              fontSize: fontSize * 0.45,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
              height: 1.2,
            ),
          ),
        ],
      );
    }
  }

  // Fonction utilitaire pour formater l'argent avec 2 décimales
  String formatMoney(double amount) {
    return '${widget.timer.currency} ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    // Récupère la monnaie préférentielle si disponible (Provider)
    String? preferredCurrency;
    try {
      preferredCurrency = Provider.of<MultiTimerController>(context, listen: false).getEffectivePreferredCurrency();
    } catch (_) {
      preferredCurrency = null;
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final double gainFontSize = widget.isCompact 
        ? widget.isSingleView 
            ? (screenWidth * 0.14).clamp(35, 70).toDouble() // Single view : plus grand
            : (screenWidth * 0.12).clamp(30, 60).toDouble() // Multi view : taille originale
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

    // Couleurs métaux précieux selon l'index du timer
    final Color timerColor = widget.timerIndex == 0 
        ? const Color(0xFFFFD700) // Or (Gold)
        : const Color(0xFFC0C0C0); // Argent (Silver)

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Container(
          // Container externe pour créer l'effet de bordure dégradée
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _rotationController.value * 2 * 3.14159, // Rotation du gradient
              colors: [
                Colors.transparent,
                timerColor.withOpacity(0.3),
                timerColor, // Couleur pleine intense
                timerColor.withOpacity(0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.transparent, // Plus de transparence pour une transition douce
                Colors.transparent,
                Colors.transparent, // Retour au début - doit correspondre au premier
              ],
              stops: const [0.0, 0.05, 0.15, 0.25, 0.35, 0.5, 0.7, 0.85, 1.0],
            ),
        boxShadow: [
          BoxShadow(
            color: timerColor.withOpacity(0.1), // Glow très discret
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.0), // Bordure plus fine (était 1.5)
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Fond noir uni comme avant
          borderRadius: BorderRadius.circular(14.0), // Ajusté pour suivre la bordure (était 13.5)
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const SizedBox(height: 6), // Réduit de 20 à 6 pixels
          
          // Titre du taux (si compact) - Affiche le nom du préréglage ou "Taux Personnalisé"
          // Hauteur fixe pour éviter les décalages
          if (widget.isCompact) ...[
            SizedBox(
              height: 40, // Hauteur fixe pour le titre
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.timer.rateIcon != null) ...[
                      Text(
                        widget.timer.rateIcon!,
                        style: TextStyle(fontSize: widget.isSingleView ? 24 : 20), // Single: 24, Multi: 20
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        widget.timer.rateTitle,
                        style: TextStyle(
                          fontSize: widget.isSingleView ? 19 : 16, // Single: 19, Multi: 16
                          fontWeight: FontWeight.bold, 
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Ligne de rappel du taux horaire net
          Text(
            '(${hourlyNet.toStringAsFixed(2)} ${widget.timer.currency}/h net)',
            style: TextStyle(
              fontSize: widget.isSingleView ? 14 : 12, // Single: 14, Multi: 12
              fontStyle: FontStyle.italic,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        
        // 1. Compteur d'Argent PRINCIPAL (GAIN NET)
        if (!widget.isCompact)
          SizedBox(
            height: 25, // Hauteur fixe pour le titre en mode plein écran
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.timer.rateIcon != null) ...[
                  Text(
                    widget.timer.rateIcon!,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.timer.rateTitle,
                  style: const TextStyle(
                    fontSize: 18, 
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        if (widget.isCompact) const SizedBox(height: 2) else const SizedBox(height: 2), // Réduit de 5 à 2 pixels
        
        // Séparateur élégant entre titre et compteur
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Augmenté de 32 à 16 pour plus de largeur
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  timerColor.withOpacity(0.3), // Or ou Argent selon le timer
                  timerColor.withOpacity(0.6),
                  timerColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: timerColor.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 4),
        
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
        
        // Conversion dynamique dans la monnaie préférentielle (pour tous les timers)
        if (preferredCurrency != null && preferredCurrency != widget.timer.currency)
          FutureBuilder<double>(
            future: ExchangeRateService.convert(
              amount: currentNetGains,
              fromCurrency: widget.timer.currency,
              toCurrency: preferredCurrency,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final convertedAmount = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 0, bottom: 0),
                  child: Text(
                    '≈ $preferredCurrency ${convertedAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: gainFontSize * 0.4,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC0C0C0), // Couleur argent
                      shadows: [
                        Shadow(
                          blurRadius: 8.0,
                          color: Colors.grey.shade400,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          blurRadius: 4.0,
                          color: Colors.white54,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        if (preferredCurrency != null && preferredCurrency != widget.timer.currency)
          const SizedBox(height: 2),

        // 2. Temps écoulé - Hauteur fixe (éditable si en pause)
        SizedBox(
          height: widget.isCompact ? 45 : 60, // Hauteur augmentée pour plus d'espace
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: !widget.timer.isRunning ? () => _showEditTimeDialog(context) : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône chronomètre
                  Icon(
                    Icons.timer,
                    color: Colors.white,
                    size: widget.isCompact ? 32 : 32,
                  ),
                  const SizedBox(width: 8),
                  // Affichage du temps : 2 lignes si compact ET heures > 0, sinon normal
                  widget.isCompact && widget.timer.elapsedDuration.inHours > 0
                      ? _buildCompactTimeDisplay(widget.timer.elapsedDuration, gainFontSize * 0.5)
                      : Text(
                          formatDuration(widget.timer.elapsedDuration),
                          style: TextStyle(
                            fontSize: gainFontSize * 0.5, 
                            fontWeight: FontWeight.w900,
                            color: Colors.white, 
                          ),
                        ),
                  const SizedBox(width: 8),
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
        
        const SizedBox(height: 15), // Réduit de 25 à 15
        
        // Séparateur élégant avant les boutons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 1.5,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  timerColor.withOpacity(0.3),
                  timerColor.withOpacity(0.6),
                  timerColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: timerColor.withOpacity(0.2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // 3. Boutons de Contrôle - Hauteur fixe
        SizedBox(
          height: widget.isCompact ? 50 : 70, // Hauteur fixe pour les boutons
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: widget.isSingleView ? 280 : 400, // Single: 280, Multi: 400
              ),
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
        Container( // Supprimé le Padding pour prendre toute la largeur
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Augmenté de 2 à 12 (marge interne)
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
                          _isExpanded ? Icons.search_off : Icons.search, // Loupe au lieu de expand_more
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_isExpanded) ...[
                  const Divider(height: 1, color: Colors.white30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Augmenté : horizontal 2→16, vertical 8→12
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
                        
                        Row(
                          children: [
                            Text(
                              'Source : ${widget.timer.rateTitle}',
                              style: TextStyle(fontSize: widget.isCompact ? 12 : 14, color: Colors.grey.shade400),
                            ),
                            if (widget.timer.rateSourceUrl != null) ...[
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () async {
                                  try {
                                    final url = Uri.parse(widget.timer.rateSourceUrl!);
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    print('Erreur lors de l\'ouverture du lien: $e');
                                  }
                                },
                                child: Icon(
                                  Icons.link,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
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
        
        const SizedBox(height: 20),
        ],
      ), // fin Column
      ), // fin Container interne
        ); // fin Container externe (bordure)
      },
    ); // fin AnimatedBuilder
  }
}
