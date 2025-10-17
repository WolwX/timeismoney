import 'package:url_launcher/url_launcher.dart';
// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/models/preset_rates.dart';
import 'package:timeismoney/screens/language_settings_screen.dart';
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
    'Dreamlist': Icons.star_border,
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
    
    return Column(
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
        const SizedBox(height: 10),
        Text(
          'Base mensuelle: ${controller.selectedTimer.hoursPerMonth.toStringAsFixed(2)} heures/mois (selon vos ${controller.selectedTimer.weeklyHours.toStringAsFixed(1)}h/semaine).',
          style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  // --- Widget pour la section des Préréglages ---

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Ligne 1 : 4 tuiles plus petites
              Row(
                children: [
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.timer,
                      title: 'Gestion des\nTimers',
                      color: const Color(0xFFFFD700),
                      onTap: () => _showTimerManagementDialog(controller),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      color: Colors.blue,
                      onTap: () => _showNotificationsDialog(),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.attach_money,
                      title: 'Taux et\nConversions',
                      color: Colors.green,
                      onTap: () => _showRateSettingsDialog(controller),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.language,
                      title: 'Préférences\nGénérales',
                      color: Colors.teal,
                      onTap: () => _showGeneralPreferencesDialog(),
                      isSmall: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ligne 2 : 3 tuiles pour les presets
              Row(
                children: [
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.format_list_bulleted,
                      title: 'Presets\nRapides',
                      color: Colors.purple,
                      onTap: () => _showPresetsDialog(controller),
                      isSmall: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.emoji_events,
                      title: 'Presets\nFun',
                      color: Colors.orange,
                      onTap: () => _showFunPresetsDialog(controller),
                      isSmall: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.star_border,
                      title: 'Presets\nDreamlist',
                      color: Colors.pink,
                      onTap: () => _showDreamlistPresetsDialog(controller),
                      isSmall: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour une tuile cliquable
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required bool isSmall,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: isSmall ? 120 : 160, // Hauteur différente selon la taille
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmall ? 36 : 56, color: color), // Icône plus petite ou plus grosse
            SizedBox(height: isSmall ? 8 : 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmall ? 13 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog pour la gestion des timers
  void _showTimerManagementDialog(MultiTimerController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎯 Gestion des Timers'),
        content: SingleChildScrollView(
          child: Consumer<MultiTimerController>(
            builder: (context, controller, _) => _buildTimerManagementContent(controller),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog pour les préférences générales
  void _showGeneralPreferencesDialog() {
    final controller = context.read<MultiTimerController>();
    final List<Map<String, String>> currencies = [
      {'symbol': 'auto', 'label': 'Automatique (selon pays)'},
      {'symbol': '€', 'label': 'Euro (€)'},
      {'symbol': ' 24', 'label': 'Dollar US ( 24)'},
  {'symbol': '£', 'label': 'Livre Sterling (£)'},
  {'symbol': 'CHF', 'label': 'Franc Suisse (CHF)'},
  {'symbol': 'A\$', 'label': 'Dollar Australien (A\$)'},
  {'symbol': 'CA\$', 'label': 'Dollar Canadien (CA\$)'},
  {'symbol': '¥', 'label': 'Yen Japonais (¥)'},
  {'symbol': '₹', 'label': 'Roupie Indienne (₹)'},
    ];
    String? selectedCurrency = controller.preferredCurrency ?? 'auto';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🌍 Préférences Générales'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Color(0xFFFFD700), size: 32),
                title: const Text('Langue / Language'),
                subtitle: const Text('Choisir la langue de l\'application'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.attach_money, color: Colors.green, size: 32),
                title: const Text('Monnaie préférentielle'),
                subtitle: DropdownButton<String>(
                  value: selectedCurrency,
                  isExpanded: true,
                  items: currencies.map((c) => DropdownMenuItem<String>(
                    value: c['symbol'],
                    child: Text(c['label']!),
                  )).toList(),
                  onChanged: (value) async {
                    if (value == null || value == 'auto') {
                      await controller.setPreferredCurrency(null);
                      selectedCurrency = 'auto';
                    } else {
                      await controller.setPreferredCurrency(value);
                      selectedCurrency = value;
                    }
                    // Force rebuild du dialog
                    Navigator.pop(context);
                    _showGeneralPreferencesDialog();
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog pour les notifications
  void _showNotificationsDialog() {
    final controller = context.read<MultiTimerController>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔔 Notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Fin du timer'),
                subtitle: const Text('Notifier quand un timer se termine'),
                value: controller.timerFinishedNotificationsEnabled,
                onChanged: (value) {
                  controller.setTimerFinishedNotificationsEnabled(value);
                },
                secondary: const Icon(Icons.timer_off, color: Colors.orange),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Jalons de gains'),
                subtitle: const Text('Notifier aux jalons de gains (10€, 50€, etc.)'),
                value: controller.gainMilestoneNotificationsEnabled,
                onChanged: (value) {
                  controller.setGainMilestoneNotificationsEnabled(value);
                },
                secondary: const Icon(Icons.trending_up, color: Colors.green),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Rappels horaires'),
                subtitle: const Text('Notifier chaque heure travaillée'),
                value: controller.hourlyNotificationsEnabled,
                onChanged: (value) {
                  controller.setHourlyNotificationsEnabled(value);
                },
                secondary: const Icon(Icons.schedule, color: Colors.blue),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Animation de fête'),
                subtitle: const Text('Afficher une animation quand le timer atteint zéro'),
                value: controller.celebrationAnimationEnabled,
                onChanged: (value) {
                  controller.setCelebrationAnimationEnabled(value);
                },
                secondary: const Icon(Icons.celebration, color: Colors.purple),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog pour les taux et conversions
  void _showRateSettingsDialog(MultiTimerController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                  Text('📊', style: TextStyle(fontSize: 22)),
                SizedBox(width: 8),
                Text('Taux et Conversions'),
              ],
            ),
            // Icônes de sélection de timer (ChronoIcon)
            if (controller.timers.length > 1)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.selectTimer(0);
                      Navigator.pop(context);
                      _showRateSettingsDialog(controller);
                    },
                    child: Tooltip(
                      message: 'Timer 1 (Or)',
                      child: Opacity(
                        opacity: controller.selectedTimerIndex == 0 ? 1.0 : 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.timer,
                                    color: const Color(0xFFFFD700),
                                    size: 34,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '1',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.selectTimer(1);
                      Navigator.pop(context);
                      _showRateSettingsDialog(controller);
                    },
                    child: Tooltip(
                      message: 'Timer 2 (Argent)',
                      child: Opacity(
                        opacity: controller.selectedTimerIndex == 1 ? 1.0 : 0.5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Stack(
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.timer,
                                    color: const Color(0xFFC0C0C0),
                                    size: 34,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      '2',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: _buildSettingsSection(controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog pour les presets
  void _showPresetsDialog(MultiTimerController controller) {
    final groupedPresets = _groupPresets(presetRates);
    // Filtrer uniquement les catégories "standards" (excluant Sport/Fun, Tech/PDG, Politique, Dreamlist)
    final standardCategories = Map.fromEntries(
      groupedPresets.entries.where((entry) => 
        entry.key != 'Sport / Fun' && 
        entry.key != 'Tech / PDG' && 
        entry.key != 'Politique / Dirigeants' &&
        entry.key != 'Dreamlist'
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => _PresetsDialog(
        title: '📋 Presets Rapides',
        groupedPresets: standardCategories,
        controller: controller,
        categoryIcons: _categoryIcons,
      ),
    );
  }

  // Dialog pour les presets fun
  void _showFunPresetsDialog(MultiTimerController controller) {
    final groupedPresets = _groupPresets(presetRates);
    // Filtrer uniquement les catégories "fun" (Sport / Fun, Tech / PDG, Politique / Dirigeants)
    final funCategories = {
      'Sport / Fun': groupedPresets['Sport / Fun'] ?? [],
      'Tech / PDG': groupedPresets['Tech / PDG'] ?? [],
      'Politique / Dirigeants': groupedPresets['Politique / Dirigeants'] ?? [],
    };
    
    showDialog(
      context: context,
      builder: (context) => _PresetsDialog(
        title: '🏆 Presets Fun',
        groupedPresets: funCategories,
        controller: controller,
        categoryIcons: _categoryIcons,
      ),
    );
  }

  // Dialog pour les presets Dreamlist
  void _showDreamlistPresetsDialog(MultiTimerController controller) {
    final groupedPresets = _groupPresets(presetRates);
    // Filtrer uniquement la catégorie "Dreamlist"
    final dreamlistCategories = {
      'Dreamlist': groupedPresets['Dreamlist'] ?? [],
    };
    
    showDialog(
      context: context,
      builder: (context) => _PresetsDialog(
        title: '✨ Presets Dreamlist',
        groupedPresets: dreamlistCategories,
        controller: controller,
        categoryIcons: _categoryIcons,
      ),
    );
  }

  // Contenu de la gestion des timers (extrait de l'ancien _buildTimerManagementSection)
  Widget _buildTimerManagementContent(MultiTimerController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(controller.timers.length, (index) {
          final timer = controller.timers[index];
          final isSelected = controller.selectedTimerIndex == index;
          final Color timerColor = index == 0 ? const Color(0xFFFFD700) : const Color(0xFFC0C0C0);
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
                  Switch(
                    value: timer.isActive,
                    onChanged: (value) {
                      controller.toggleTimerActive(index);
                    },
                    activeColor: Colors.green,
                  ),
                  if (controller.timers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
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
        if (controller.timers.length < 2)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddTimerDialog(context, controller);
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un timer'),
          ),
      ],
    );
  }
}

// Widget StatefulWidget pour les dialogs de presets (pour gérer l'état de la catégorie sélectionnée)
class _PresetsDialog extends StatefulWidget {
  final String title;
  final Map<String, List<PresetRate>> groupedPresets;
  final MultiTimerController controller;
  final Map<String, IconData> categoryIcons;

  const _PresetsDialog({
    required this.title,
    required this.groupedPresets,
    required this.controller,
    required this.categoryIcons,
  });

  @override
  State<_PresetsDialog> createState() => _PresetsDialogState();
}

class _PresetsDialogState extends State<_PresetsDialog> {
  void _applyPresetToTimer(PresetRate preset, int timerIndex) {
    final int previousIndex = widget.controller.selectedTimerIndex;
    widget.controller.selectTimer(timerIndex);
    widget.controller.setHourlyRate(preset.rate);
    widget.controller.setCurrency(preset.currency);
    widget.controller.setRateTitle(preset.title);
    widget.controller.setRateIcon(preset.icon);
    widget.controller.setRateSourceUrl(preset.sourceUrl);
    widget.controller.setNetRatePercentage(preset.netRatePercentage);
    widget.controller.setWeeklyHours(preset.weeklyHours);
    widget.controller.selectTimer(previousIndex); // Restaure la sélection initiale
    Navigator.pop(context); // Ferme le dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Préréglage "${preset.title}" appliqué au Timer ${timerIndex + 1} !')),
    );
  }

  Widget _buildPresetDetail(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      ),
    );
  }

  String _shortUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final host = uri.host.replaceFirst('www.', '');
    final path = uri.pathSegments.isNotEmpty ? '/${uri.pathSegments.first}' : '';
    return '$host$path';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        height: 600, // Fixed height for better scrolling
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.groupedPresets.entries.map((entry) {
              final category = entry.key;
              final presets = entry.value;
              return ExpansionTile(
                leading: Icon(widget.categoryIcons[category] ?? Icons.star, size: 24, color: Colors.tealAccent),
                title: Text(
                  category,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                iconColor: Colors.tealAccent,
                collapsedIconColor: Colors.tealAccent,
                backgroundColor: Colors.grey.shade800.withOpacity(0.3),
                collapsedBackgroundColor: Colors.grey.shade900.withOpacity(0.5),
                children: presets.map((preset) {
                  final monthlyGross = preset.rate * 4.33 * preset.weeklyHours;
                  final monthlyNet = monthlyGross * (preset.netRatePercentage / 100.0);
                  final annualGross = monthlyGross * 12;
                  final annualNet = monthlyNet * 12;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    color: Colors.grey.shade900,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (preset.icon != null) Text(preset.icon!, style: const TextStyle(fontSize: 22)),
                              if (preset.icon != null) const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  preset.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  softWrap: true,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Appliquer au Timer 1',
                                icon: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.timer, color: Color(0xFFFFD700), size: 28),
                                    Positioned(
                                      bottom: 4, right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('1', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () => _applyPresetToTimer(preset, 0),
                              ),
                              IconButton(
                                tooltip: 'Appliquer au Timer 2',
                                icon: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(Icons.timer, color: Color(0xFFC0C0C0), size: 28),
                                    Positioned(
                                      bottom: 4, right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('2', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () => _applyPresetToTimer(preset, 1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (preset.sourceUrl != null && preset.sourceUrl!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Row(
                                children: [
                                  const Text('Source : ', style: TextStyle(fontSize: 12, color: Colors.white70)),
                                  InkWell(
                                    onTap: () async {
                                      final url = Uri.parse(preset.sourceUrl!);
                                      try {
                                        await launchUrl(url);
                                      } catch (_) {}
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.link, size: 15, color: Colors.tealAccent),
                                        const SizedBox(width: 3),
                                        Text(
                                          _shortUrl(preset.sourceUrl!),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.tealAccent,
                                            decoration: TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _buildPresetDetail('Horaire', '${preset.rate.toStringAsFixed(2)} ${preset.currency}/h', Colors.tealAccent),
                          _buildPresetDetail('Mensuel Brut', '${monthlyGross.toStringAsFixed(2)} ${preset.currency}', Colors.greenAccent),
                          _buildPresetDetail('Mensuel Net', '${monthlyNet.toStringAsFixed(2)} ${preset.currency}', Colors.green),
                          _buildPresetDetail('Annuel Brut', '${annualGross.toStringAsFixed(2)} ${preset.currency}', Colors.yellowAccent),
                          _buildPresetDetail('Annuel Net', '${annualNet.toStringAsFixed(2)} ${preset.currency}', Colors.yellow),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
  // La suite du code de build doit être dans une méthode de widget, pas ici !
}
