// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/timer_controller.dart';
import 'package:timeismoney/models/preset_rates.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _rateController;
  late TextEditingController _currencyController;
  // NOUVEAU : Contrôleur pour le taux Net/Brut
  late TextEditingController _netRateController;
  
  @override
  void initState() {
    super.initState();
    final controller = context.read<TimerController>();
    
    _rateController = TextEditingController(text: controller.hourlyRate.toStringAsFixed(2));
    _currencyController = TextEditingController(text: controller.currency);
    // NOUVEAU : Initialisation avec le pourcentage actuel
    _netRateController = TextEditingController(text: controller.netRatePercentage.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _rateController.dispose();
    _currencyController.dispose();
    _netRateController.dispose(); // NOUVEAU
    super.dispose();
  }

  // Applique un préréglage et navigue en arrière
  void _applyPreset(PresetRate preset) {
    final controller = context.read<TimerController>();
    
    controller.setHourlyRate(preset.rate);
    controller.setCurrency(preset.currency);
    controller.setRateTitle(preset.title); 
    
    // Met à jour les champs de texte
    setState(() {
      _rateController.text = preset.rate.toStringAsFixed(2);
      _currencyController.text = preset.currency;
    });
    
    Navigator.pop(context);
  }
  
  // Sauvegarde le taux saisi manuellement (et le nouveau taux Net)
  void _saveRate() {
    final controller = context.read<TimerController>();
    
    final double? newRate = double.tryParse(_rateController.text.replaceAll(',', '.'));
    final double? newNetRatePercentage = double.tryParse(_netRateController.text.replaceAll(',', '.'));
    
    bool isValid = true;

    // 1. Validation du Taux Horaire
    if (newRate != null && newRate > 0) {
      controller.setHourlyRate(newRate);
      controller.setCurrency(_currencyController.text.trim());
      controller.setRateTitle('Taux Personnalisé'); 
    } else {
      isValid = false;
    }

    // 2. Validation du Taux Net
    if (newNetRatePercentage != null && newNetRatePercentage >= 0 && newNetRatePercentage <= 100) {
      controller.setNetRatePercentage(newNetRatePercentage); // NOUVEAU : Sauvegarde du taux Net
    } else {
      isValid = false;
      // Affichage d'un message spécifique si seul le taux Net est invalide
      if (newNetRatePercentage == null || newNetRatePercentage < 0 || newNetRatePercentage > 100) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le pourcentage Net doit être compris entre 0 et 100.')),
        );
      }
    }


    if (isValid) {
      Navigator.pop(context); // Ferme l'écran
    } else if (newRate == null || newRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un taux horaire valide.')),
      );
    }
  }
  
  // Fonction pour regrouper les préréglages par catégorie
  Map<String, List<PresetRate>> _groupPresets() {
    final Map<String, List<PresetRate>> grouped = {};
    for (var preset in presetRates) {
      if (!grouped.containsKey(preset.category)) {
        grouped[preset.category] = [];
      }
      grouped[preset.category]!.add(preset);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedPresets = _groupPresets();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages & Taux'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveRate,
            tooltip: 'Sauvegarder les changements',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ------------------ 1. Taux Horaire Actuel ------------------
            const Text(
              'Taux Horaire Actuel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Champ Devise
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: _currencyController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Devise',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    maxLength: 3,
                  ),
                ),
                const SizedBox(width: 10),
                // Champ Taux
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Taux par heure',
                      hintText: 'Ex: 15.30',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 50, thickness: 1),

            // ------------------ 2. Réglage Taux Net/Brut (NOUVEAU) ------------------
            const Text(
              'Réglage du Taux Net/Brut',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _netRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Pourcentage du Brut conservé (Net)',
                      hintText: 'Ex: 77 pour -23% de charges',
                      border: OutlineInputBorder(),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}')),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  '% du Brut',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Indiquez le pourcentage de votre salaire BRUT que vous recevez en NET (avant impôt sur le revenu). En France, la moyenne est souvent autour de 77%.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            
            const Divider(height: 50, thickness: 1),
            
            // ------------------ 3. Préréglages Fun Catégorisés ------------------
            const Text(
              'Préréglages Fun & Référents',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Itération sur les catégories
            ...groupedPresets.keys.map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      category, // Nom de la Catégorie
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.tealAccent),
                    ),
                  ),
                  // Itération sur les préréglages de cette catégorie
                  ...groupedPresets[category]!.map((preset) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        title: Text(preset.title),
                        subtitle: Text('${preset.currency} ${preset.rate.toStringAsFixed(2)} / h'),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => _applyPreset(preset),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: const BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 20),
                ],
              );
            }).toList(),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}