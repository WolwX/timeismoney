// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/models/preset_rates.dart'; 
import 'dart:async'; 

// Constante pour les conversions
const int monthsPerYear = 12; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Contrôleurs de texte
  late TextEditingController _rateController;
  late TextEditingController _currencyController;
  late TextEditingController _netRateController;
  late TextEditingController _monthlyGrossController;
  late TextEditingController _monthlyNetController;
  late TextEditingController _annualGrossController;
  late TextEditingController _annualNetController;
  late TextEditingController _weeklyHoursController; 

  // NOUVEAU : FocusNodes pour identifier le champ actif et empêcher la réécriture
  late FocusNode _rateFocus;
  late FocusNode _monthlyGrossFocus;
  late FocusNode _monthlyNetFocus;
  late FocusNode _annualGrossFocus;
  late FocusNode _annualNetFocus;
  late FocusNode _weeklyHoursFocus;
  // NOTE : Les champs Devise et Pourcentage Net n'ont pas besoin de FocusNode pour la synchro
  
  // État pour gérer la catégorie de préréglages sélectionnée
  String? _selectedCategory;
  
  // Timer pour la fonction de debounce (temporisation)
  Timer? _debounce;

  // Mappage des catégories vers leurs icônes
  static final Map<String, IconData> _categoryIcons = {
    'Standard / Emploi': Icons.business_center,
    'Santé / Médical': Icons.local_hospital,
    'Administration / Bureau': Icons.description,
    'Politique / Dirigeants': Icons.gavel,
    'Tech / PDG': Icons.computer,
    'Sport / Fun': Icons.sports_tennis,
    'Taux Étrangers': Icons.public,
  };
  
  // --- Fonction utilitaire de Debounce ---
  void _debounceRun(VoidCallback callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), callback);
  }

  // --- Fonctions de Synchronisation ---
  
  // Recalcule tous les champs basés sur un nouveau taux horaire
  void _syncFieldsFromNewHourlyRate(MultiTimerController controller, double newHourlyRate) {
    // Annule tout debounce en cours
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (newHourlyRate.isInfinite || newHourlyRate.isNaN) newHourlyRate = 0.0;
    
    final double hoursPerMonth = controller.selectedTimer.hoursPerMonth; 

    // 1. Calcul des nouvelles valeurs
    final double newMonthlyGross = newHourlyRate * hoursPerMonth;
    final double newMonthlyNet = newMonthlyGross * controller.selectedTimer.netConversionFactor;
  final double newAnnualGross = newMonthlyGross * monthsPerYear;
  final double newAnnualNet = newMonthlyNet * monthsPerYear;

    // 2. Mise à jour des contrôleurs de texte :
    //    Nous mettons à jour un contrôleur SEULEMENT si son champ n'est PAS en focus.
    setState(() {
      // Taux Horaire BRUT
      if (!_rateFocus.hasFocus) {
        _rateController.text = newHourlyRate.toStringAsFixed(2);
        _setSelectionToEnd(_rateController);
      }
      
      // Mensuel BRUT
      if (!_monthlyGrossFocus.hasFocus) {
        _monthlyGrossController.text = newMonthlyGross.toStringAsFixed(2);
        _setSelectionToEnd(_monthlyGrossController);
      }
      
      // Mensuel NET
      if (!_monthlyNetFocus.hasFocus) {
        _monthlyNetController.text = newMonthlyNet.toStringAsFixed(2);
        _setSelectionToEnd(_monthlyNetController);
      }
      
      // Annuel BRUT
      if (!_annualGrossFocus.hasFocus) {
        _annualGrossController.text = newAnnualGross.toStringAsFixed(2);
        _setSelectionToEnd(_annualGrossController);
      }
      
      // Annuel NET
      if (!_annualNetFocus.hasFocus) {
        _annualNetController.text = newAnnualNet.toStringAsFixed(2);
        _setSelectionToEnd(_annualNetController);
      }
      
      // Le champ Heures/Semaine a sa propre logique de onChanged, pas besoin ici
    });


    // 3. Mise à jour du Provider (pour la persistance et le HomeScreen)
    // Utiliser une méthode qui ne réinitialise pas le rateTitle
    controller.updateHourlyRateOnly(newHourlyRate);
  }

  // Utilitaire pour maintenir le curseur à la fin du texte
  void _setSelectionToEnd(TextEditingController controller) {
    final newText = controller.text;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newText.length),
    );
  }

  // --- Initialisation et Nettoyage ---

  @override
  void initState() {
    super.initState();
    final controller = context.read<MultiTimerController>();
    
    final double hoursPerMonth = controller.selectedTimer.hoursPerMonth;

    // Calcul des valeurs initiales pour tous les champs
    final double initialHourlyRate = controller.selectedTimer.hourlyRate;
    final double initialMonthlyGross = initialHourlyRate * hoursPerMonth;
    final double initialMonthlyNet = initialMonthlyGross * controller.selectedTimer.netConversionFactor;
  final double initialAnnualGross = initialMonthlyGross * monthsPerYear;
  final double initialAnnualNet = initialMonthlyNet * monthsPerYear;

    // Initialisation de tous les contrôleurs
    _rateController = TextEditingController(text: initialHourlyRate.toStringAsFixed(2));
    _currencyController = TextEditingController(text: controller.selectedTimer.currency);
    _netRateController = TextEditingController(text: controller.selectedTimer.netRatePercentage.toStringAsFixed(0));
    _monthlyGrossController = TextEditingController(text: initialMonthlyGross.toStringAsFixed(2));
    _monthlyNetController = TextEditingController(text: initialMonthlyNet.toStringAsFixed(2));
    _annualGrossController = TextEditingController(text: initialAnnualGross.toStringAsFixed(2));
    _annualNetController = TextEditingController(text: initialAnnualNet.toStringAsFixed(2));
    _weeklyHoursController = TextEditingController(text: controller.selectedTimer.weeklyHours.toStringAsFixed(1));

    // Initialisation des FocusNodes
    _rateFocus = FocusNode();
    _monthlyGrossFocus = FocusNode();
    _monthlyNetFocus = FocusNode();
    _annualGrossFocus = FocusNode();
    _annualNetFocus = FocusNode();
    _weeklyHoursFocus = FocusNode();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // Dispose des Controllers
    _rateController.dispose();
    _currencyController.dispose();
    _netRateController.dispose(); 
    _monthlyGrossController.dispose(); 
    _monthlyNetController.dispose();   
    _annualGrossController.dispose(); 
    _annualNetController.dispose(); 
    _weeklyHoursController.dispose();
    
    // Dispose des FocusNodes
    _rateFocus.dispose();
    _monthlyGrossFocus.dispose();
    _monthlyNetFocus.dispose();
    _annualGrossFocus.dispose();
    _annualNetFocus.dispose();
    _weeklyHoursFocus.dispose();
    
    super.dispose();
  }

  // --- Logique d'Application d'un Préréglage ---

  void _applyPreset(PresetRate preset) {
    final controller = context.read<MultiTimerController>();
    
    controller.setCurrency(preset.currency);
    _currencyController.text = preset.currency;
    
    controller.setRateTitle(preset.title);
    
    // Applique le pourcentage NET/BRUT spécifique au pays
    controller.setNetRatePercentage(preset.netRatePercentage);
    _netRateController.text = preset.netRatePercentage.toStringAsFixed(1);
    
    // Applique les heures hebdomadaires spécifiques au pays
    controller.setWeeklyHours(preset.weeklyHours);
    _weeklyHoursController.text = preset.weeklyHours.toStringAsFixed(1);

    // Applique le nouveau taux et synchronise les champs
    _syncFieldsFromNewHourlyRate(controller, preset.rate);

    Navigator.of(context).pop();
  }
  
  // Fonction utilitaire pour regrouper les préréglages
  Map<String, List<PresetRate>> _groupPresets(List<PresetRate> presets) {
    Map<String, List<PresetRate>> grouped = {};
    for (var preset in presets) {
      if (!grouped.containsKey(preset.category)) {
        grouped[preset.category] = [];
      }
      grouped[preset.category]!.add(preset);
    }
    return grouped;
  }
  
  // --- Widget utilitaire pour une ligne de deux champs ---
  Widget _buildTwoColumnRow({required Widget leftField, required Widget rightField}) {
      return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Expanded(child: leftField),
                  const SizedBox(width: 16), 
                  Expanded(child: rightField),
              ],
          ),
      );
  }

  // --- Widget pour la section des paramètres en 2 colonnes ---
  Widget _buildSettingsSection(MultiTimerController controller) {
    
    // Couleur distinctive selon l'index du timer sélectionné
    final Color timerColor = controller.selectedTimerIndex == 0 ? Colors.cyan : Colors.orange;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: timerColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text('⚙️ Paramètres Taux et Conversions (${controller.selectedTimer.name})'), 
        initiallyExpanded: true, 
        childrenPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        children: [
          Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne 1 : Taux Horaire (G) / Heures Hebdomadaires (D)
            _buildTwoColumnRow(
              leftField: TextFormField(
                controller: _rateController,
                focusNode: _rateFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.\,]?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: 'Taux Horaire BRUT',
                  suffixText: '${controller.selectedTimer.currency} / h',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newRate = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    controller.setRateTitle('Taux Personnalisé');
                    _syncFieldsFromNewHourlyRate(controller, newRate); 
                  });
                },
              ),
              rightField: TextFormField(
                controller: _weeklyHoursController,
                focusNode: _weeklyHoursFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}[\.\,]?\d{0,1}'))],
                decoration: const InputDecoration(
                  labelText: 'Heures / Semaine',
                  suffixText: 'h',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newHours = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    // Mise à jour de la valeur dans le contrôleur (même si le FocusNode est lié, 
                    // ce champ est un cas spécial où il force une synchro)
                    controller.setWeeklyHours(newHours.clamp(0.0, 168.0)); 
                    _syncFieldsFromNewHourlyRate(controller, controller.selectedTimer.hourlyRate); 
                  });
                },
              ),
            ),
            
            // Ligne 2 : Mensuel Brut (G) / Mensuel Net (D)
            _buildTwoColumnRow(
              leftField: TextFormField(
                controller: _monthlyGrossController,
                focusNode: _monthlyGrossFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.\,]?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: 'Mensuel BRUT',
                  suffixText: '${controller.selectedTimer.currency} / mois',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newMonthlyGross = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    final newRate = controller.selectedTimer.hoursPerMonth > 0 ? newMonthlyGross / controller.selectedTimer.hoursPerMonth : 0.0; 
                    controller.setRateTitle('Salaire Mensuel Brut');
                    _syncFieldsFromNewHourlyRate(controller, newRate);
                  });
                },
              ),
              rightField: TextFormField(
                controller: _monthlyNetController,
                focusNode: _monthlyNetFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.\,]?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: 'Mensuel NET',
                  suffixText: '${controller.selectedTimer.currency} / mois',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newMonthlyNet = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    final netFactor = controller.selectedTimer.netConversionFactor;
                    double newMonthlyGross = (netFactor > 0) ? newMonthlyNet / netFactor : 0.0;
                    final newRate = controller.selectedTimer.hoursPerMonth > 0 ? newMonthlyGross / controller.selectedTimer.hoursPerMonth : 0.0; 
                    controller.setRateTitle('Salaire Mensuel Net');
                    _syncFieldsFromNewHourlyRate(controller, newRate);
                  });
                },
              ),
            ),

            // Ligne 3 : Annuel Brut (G) / Annuel Net (D)
            _buildTwoColumnRow(
              leftField: TextFormField(
                controller: _annualGrossController,
                focusNode: _annualGrossFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.\,]?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: 'Annuel BRUT',
                  suffixText: '${controller.selectedTimer.currency} / an',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newAnnualGross = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    final newMonthlyGross = newAnnualGross / monthsPerYear;
                    final newRate = controller.selectedTimer.hoursPerMonth > 0 ? newMonthlyGross / controller.selectedTimer.hoursPerMonth : 0.0; 
                    controller.setRateTitle('Salaire Annuel Brut');
                    _syncFieldsFromNewHourlyRate(controller, newRate);
                  });
                },
              ),
              rightField: TextFormField(
                controller: _annualNetController,
                focusNode: _annualNetFocus, // LIAISON FOCUS
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+[\.\,]?\d{0,2}'))],
                decoration: InputDecoration(
                  labelText: 'Annuel NET',
                  suffixText: '${controller.selectedTimer.currency} / an',
                ),
                onChanged: (value) { 
                  _debounceRun(() {
                    final newAnnualNet = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    final newMonthlyNet = newAnnualNet / monthsPerYear;
                    final netFactor = controller.selectedTimer.netConversionFactor;
                    double newMonthlyGross = (netFactor > 0) ? newMonthlyNet / netFactor : 0.0;
                    final newRate = controller.selectedTimer.hoursPerMonth > 0 ? newMonthlyGross / controller.selectedTimer.hoursPerMonth : 0.0; 
                    controller.setRateTitle('Salaire Annuel Net');
                    _syncFieldsFromNewHourlyRate(controller, newRate);
                  });
                },
              ),
            ),
            
            // Ligne 4 : Symbole Devise (G) / Pourcentage Net (D)
            _buildTwoColumnRow(
              leftField: TextFormField(
                controller: _currencyController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 3, 
                decoration: const InputDecoration(
                  labelText: 'Symbole Devise',
                  counterText: '', 
                ),
                onFieldSubmitted: (value) { 
                  controller.setCurrency(value.toUpperCase());
                },
              ),
              rightField: TextFormField(
                controller: _netRateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}'))],
                decoration: const InputDecoration(
                  labelText: 'Pourcentage Net reçu',
                  suffixText: '% du Brut',
                ),
                onFieldSubmitted: (value) { 
                  final newPercentage = double.tryParse(value) ?? 0.0;
                  if (newPercentage < 0 || newPercentage > 100) return;

                  controller.setNetRatePercentage(newPercentage);
                  final currentHourlyRate = controller.selectedTimer.hourlyRate; 
                  // Resynchronise tous les champs basés sur le nouveau facteur Net/Brut
                  _syncFieldsFromNewHourlyRate(controller, currentHourlyRate); 

                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Base mensuelle: ${controller.selectedTimer.hoursPerMonth.toStringAsFixed(2)} heures/mois (selon vos ${controller.selectedTimer.weeklyHours.toStringAsFixed(1)}h/semaine).',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12),
        ),
        ],
      ),
    );
  }

  // --- Widget pour la section des Préréglages ---

  Widget _buildPresetsSection(Map<String, List<PresetRate>> groupedPresets) {
    final categories = groupedPresets.keys.toList();
    final controller = context.read<MultiTimerController>();

    return ExpansionTile(
      title: const Text('🚀 Préréglages Rapides'), 
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.all(8),
      children: [
        // ROW des ICÔNES de Catégories
        Wrap(
          spacing: 8.0, 
          runSpacing: 8.0, 
          children: categories.map((category) {
            final isSelected = category == _selectedCategory;
            return ActionChip(
              avatar: Icon(
                _categoryIcons[category] ?? Icons.category, 
                color: isSelected ? Colors.black : Colors.white70,
              ),
              label: Text(category),
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: isSelected ? Colors.tealAccent : Colors.grey.shade800,
              onPressed: () {
                setState(() {
                  _selectedCategory = isSelected ? null : category;
                });
              },
            );
          }).toList(),
        ),
        
        const SizedBox(height: 20),

        // Affichage des préréglages de la catégorie sélectionnée (DÉTAILLÉ)
        if (_selectedCategory != null) 
          ...groupedPresets[_selectedCategory]!.map((preset) {
            final double hoursPerMonth = controller.selectedTimer.hoursPerMonth;
            
            // Calculs COMPLETS pour l'affichage détaillé
            final double monthlyGross = preset.rate * hoursPerMonth;
            final double monthlyNet = monthlyGross * controller.selectedTimer.netConversionFactor; 
            final double annualGross = monthlyGross * monthsPerYear;
            final double annualNet = monthlyNet * monthsPerYear;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _applyPreset(preset),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.tealAccent.withAlpha((0.3 * 255).round()), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et icône d'application
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              preset.title, 
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.play_arrow, color: Colors.tealAccent),
                        ],
                      ),
                      const Divider(color: Colors.white10),
                      // Détail des 5 valeurs
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 8.0,
                        children: [
                          _buildPresetDetail('Horaire', '${preset.currency} ${preset.rate.toStringAsFixed(2)}', Colors.yellow),
                          _buildPresetDetail('Mensuel Brut', '${preset.currency} ${monthlyGross.toStringAsFixed(2)}', Colors.blue),
                          _buildPresetDetail('Mensuel Net', '${preset.currency} ${monthlyNet.toStringAsFixed(2)}', Colors.green),
                          
                          _buildPresetDetail('Annuel Brut', '${preset.currency} ${annualGross.toStringAsFixed(0)}', const Color.fromRGBO(129, 199, 132, 1.0)),
                          _buildPresetDetail('Annuel Net', '${preset.currency} ${annualNet.toStringAsFixed(0)}', const Color.fromRGBO(56, 142, 60, 1.0)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
  
  // Petit widget utilitaire pour afficher les détails du preset
  Widget _buildPresetDetail(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color.withAlpha((0.7 * 255).round())),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }


  // --- Widget pour la section de gestion des timers ---
  Widget _buildTimerManagementSection(MultiTimerController controller) {
    return ExpansionTile(
      title: const Text('⏱️ Gestion des Timers'),
      initiallyExpanded: true,
      childrenPadding: const EdgeInsets.all(12),
      children: [
        // Liste des timers
        ...List.generate(controller.timers.length, (index) {
          final timer = controller.timers[index];
          final isSelected = controller.selectedTimerIndex == index;
          
          // Couleur distinctive selon l'index du timer
          final Color timerColor = index == 0 ? Colors.cyan : Colors.orange;
          
          return Card(
            color: isSelected ? Colors.teal.shade900 : Colors.grey.shade800,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: timerColor,
                width: 3,
              ),
            ),
            child: ListTile(
              leading: Icon(
                timer.isActive ? Icons.timer : Icons.timer_off,
                color: timer.isActive ? Colors.green : Colors.grey,
              ),
              title: Text(
                timer.rateTitle,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '${timer.currency} ${timer.hourlyRate.toStringAsFixed(2)}/h',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle actif/inactif
                  Switch(
                    value: timer.isActive,
                    onChanged: (value) {
                      controller.toggleTimerActive(index);
                    },
                    activeColor: Colors.green,
                  ),
                  // Bouton supprimer (seulement si plus d'un timer)
                  if (controller.timers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmation(context, controller, index);
                      },
                    ),
                ],
              ),
              onTap: () {
                controller.selectTimer(index);
              },
            ),
          );
        }),
        
        const SizedBox(height: 12),
        
        // Bouton ajouter un timer (max 2 timers)
        if (controller.timers.length < 2)
          ElevatedButton.icon(
            onPressed: () {
              _showAddTimerDialog(context, controller);
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un Timer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Maximum 2 timers atteint',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Dialogue pour ajouter un nouveau timer
  void _showAddTimerDialog(BuildContext context, MultiTimerController controller) {
    final nameController = TextEditingController(text: 'Timer ${controller.timers.length + 1}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Timer'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom du timer',
            hintText: 'Ex: Projet A, Client B...',
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                controller.addTimer(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  // Dialogue de confirmation de suppression
  void _showDeleteConfirmation(BuildContext context, MultiTimerController controller, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le timer ?'),
        content: Text('Voulez-vous vraiment supprimer "${controller.timers[index].name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removeTimer(index);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Widget Principal
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MultiTimerController>();

    final groupedPresets = _groupPresets(presetRates); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 0. SECTION GESTION DES TIMERS
            _buildTimerManagementSection(controller),
            
            const SizedBox(height: 30),
            
            // 1. SECTION PARAMÈTRES (2 colonnes garanties)
            _buildSettingsSection(controller),
            
            const SizedBox(height: 30),

            // 2. SECTION PRÉRÉGLAGES (Icônes et Détails)
            _buildPresetsSection(groupedPresets),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
