import 'package:url_launcher/url_launcher.dart';
// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/multi_timer_controller.dart';
import 'package:timeismoney/models/preset_rates.dart';
import 'package:timeismoney/screens/language_settings_screen.dart';
import 'package:timeismoney/services/work_schedule_service.dart';
import 'package:timeismoney/utils.dart';
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
        _rateController.text = formatNumberWithSpaces(newHourlyRate, 2);
        _setSelectionToEnd(_rateController);
      }
      
      // Mensuel BRUT
      if (!_monthlyGrossFocus.hasFocus) {
        _monthlyGrossController.text = formatNumberWithSpaces(newMonthlyGross, 2);
        _setSelectionToEnd(_monthlyGrossController);
      }
      
      // Mensuel NET
      if (!_monthlyNetFocus.hasFocus) {
        _monthlyNetController.text = formatNumberWithSpaces(newMonthlyNet, 2);
        _setSelectionToEnd(_monthlyNetController);
      }
      
      // Annuel BRUT
      if (!_annualGrossFocus.hasFocus) {
        _annualGrossController.text = formatNumberWithSpaces(newAnnualGross, 2);
        _setSelectionToEnd(_annualGrossController);
      }
      
      // Annuel NET
      if (!_annualNetFocus.hasFocus) {
        _annualNetController.text = formatNumberWithSpaces(newAnnualNet, 2);
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
    _rateController = TextEditingController(text: formatNumberWithSpaces(initialHourlyRate, 2));
    _currencyController = TextEditingController(text: controller.selectedTimer.currency);
    _netRateController = TextEditingController(text: controller.selectedTimer.netRatePercentage.toStringAsFixed(0));
    _monthlyGrossController = TextEditingController(text: formatNumberWithSpaces(initialMonthlyGross, 2));
    _monthlyNetController = TextEditingController(text: formatNumberWithSpaces(initialMonthlyNet, 2));
    _annualGrossController = TextEditingController(text: formatNumberWithSpaces(initialAnnualGross, 2));
    _annualNetController = TextEditingController(text: formatNumberWithSpaces(initialAnnualNet, 2));
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
              // Ligne 2 : 4 tuiles plus petites (Planning + autres fonctionnalités)
              Row(
                children: [
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.schedule,
                      title: 'Planning',
                      color: Colors.indigo,
                      onTap: () => _showWorkScheduleDialog(),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.backup,
                      title: 'Sauvegarde\n& Restauration',
                      color: Colors.brown,
                      onTap: () => _showBackupDialog(),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.help_outline,
                      title: 'Aide &\nSupport',
                      color: Colors.cyan,
                      onTap: () => _showHelpDialog(),
                      isSmall: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingsTile(
                      icon: Icons.info_outline,
                      title: 'À propos',
                      color: Colors.grey,
                      onTap: () => _showAboutDialog(),
                      isSmall: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Ligne 3 : 3 tuiles pour les presets
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
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog pour dupliquer les réglages d'un jour vers tous les autres jours
  void _showCopyScheduleDialog(BuildContext context, WorkScheduleService workScheduleService, StateSetter setState) {
    const daysOfWeek = [
      {'key': 'monday', 'label': 'Lundi'},
      {'key': 'tuesday', 'label': 'Mardi'},
      {'key': 'wednesday', 'label': 'Mercredi'},
      {'key': 'thursday', 'label': 'Jeudi'},
      {'key': 'friday', 'label': 'Vendredi'},
      {'key': 'saturday', 'label': 'Samedi'},
      {'key': 'sunday', 'label': 'Dimanche'},
    ];

    String? selectedSourceDay;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Dupliquer les réglages'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sélectionnez le jour source dont vous voulez copier les réglages :',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              ...daysOfWeek.map((day) {
                final dayKey = day['key']!;
                final dayLabel = day['label']!;
                final schedule = workScheduleService.getDaySchedule(dayKey);
                final hasTimeSlots = schedule.timeSlots.isNotEmpty;

                return RadioListTile<String>(
                  title: Text(
                    '$dayLabel ${hasTimeSlots ? '(${schedule.timeSlots.length} plage${schedule.timeSlots.length > 1 ? 's' : ''})' : '(vide)'}',
                    style: TextStyle(
                      color: hasTimeSlots ? Colors.white : Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  value: dayKey,
                  groupValue: selectedSourceDay,
                  onChanged: hasTimeSlots ? (value) {
                    setDialogState(() {
                      selectedSourceDay = value;
                    });
                  } : null,
                  activeColor: Colors.teal,
                  dense: true,
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: selectedSourceDay == null ? null : () {
                // Copier les réglages du jour source vers tous les autres jours
                final sourceSchedule = workScheduleService.getDaySchedule(selectedSourceDay!);

                for (final day in daysOfWeek) {
                  final targetDayKey = day['key']!;
                  if (targetDayKey != selectedSourceDay) {
                    workScheduleService.updateDaySchedule(
                      targetDayKey,
                      WorkDaySchedule(
                        enabled: sourceSchedule.enabled,
                        timeSlots: List.from(sourceSchedule.timeSlots),
                      ),
                    );
                  }
                }

                Navigator.pop(context);
                setState(() {}); // Rafraîchir l'interface principale

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Réglages dupliqués depuis ${daysOfWeek.firstWhere((d) => d['key'] == selectedSourceDay)['label']}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Dupliquer'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog pour le planning de travail
  void _showWorkScheduleDialog() async {
    final controller = context.read<MultiTimerController>();
    final workScheduleService = WorkScheduleService();

    // Charger les horaires sauvegardés
    final savedSchedule = await controller.storage.getWorkSchedule();
    if (savedSchedule != null) {
      workScheduleService.loadFromStorage(savedSchedule);
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24), // Réduire les marges externes
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Marges du titre
          contentPadding: EdgeInsets.zero, // Supprimer les marges du contenu
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('⏰', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text('Planning'),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton ON/OFF pour activer/désactiver le planning
                    Switch(
                      value: workScheduleService.isEnabled,
                      onChanged: (value) {
                        workScheduleService.setEnabled(value);
                        setState(() {}); // Rafraîchir le titre
                      },
                      activeColor: Colors.teal,
                      activeTrackColor: Colors.teal.withOpacity(0.3),
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                    ),
                    const SizedBox(width: 8),
                    // Bouton pour dupliquer les réglages
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20, color: Colors.teal),
                      onPressed: () => _showCopyScheduleDialog(context, workScheduleService, setState),
                      tooltip: 'Dupliquer les réglages vers tous les jours',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
            // Indication visuelle du timer sélectionné et état du planning
            if (controller.timers.length > 1)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: workScheduleService.isEnabled
                      ? (controller.selectedTimerIndex == 0 ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2))
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: workScheduleService.isEnabled
                        ? (controller.selectedTimerIndex == 0 ? Colors.amber : Colors.grey)
                        : Colors.grey.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      workScheduleService.isEnabled ? Icons.timer : Icons.timer_off,
                      size: 16,
                      color: workScheduleService.isEnabled
                          ? (controller.selectedTimerIndex == 0 ? Colors.amber : Colors.grey)
                          : Colors.grey.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      workScheduleService.isEnabled
                          ? 'Configuration du Timer ${controller.selectedTimerIndex + 1} (${controller.selectedTimerIndex == 0 ? 'Or' : 'Argent'})'
                          : 'Planning désactivé - Configuration du Timer ${controller.selectedTimerIndex + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: workScheduleService.isEnabled
                            ? (controller.selectedTimerIndex == 0 ? Colors.amber : Colors.grey)
                            : Colors.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.all(16.0), // Ajouter de l'espacement autour du contenu
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icônes de sélection de timer
              if (controller.timers.length > 1)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  alignment: Alignment.center,
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enregistrer sur le timer ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        controller.selectTimer(0);
                        Navigator.pop(context);
                        _showWorkScheduleDialog();
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
                        _showWorkScheduleDialog();
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
              ),
            // Contenu scrollable
            Expanded(
              child: Scrollbar(
                thickness: 6,
                radius: const Radius.circular(3),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(right: 16), // Espace pour l'ascenseur
                  child: _buildWorkScheduleContent(workScheduleService, controller, () => setState(() {})),
                ),
              ),
            ),
          ],
        ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // Sauvegarder les horaires
              final scheduleJson = workScheduleService.saveToStorage();
              await controller.storage.setWorkSchedule(scheduleJson);
              
              // Fermer le dialog d'abord
              Navigator.pop(context);
              
              // Puis afficher le message de confirmation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Planning sauvegardé !')),
                  );
                }
              });
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Sauvegarder'),
          ),
        ],
      ),
    ),
  );
  }

  // Widget pour le contenu du planning de travail
  Widget _buildWorkScheduleContent(WorkScheduleService workScheduleService, MultiTimerController controller, VoidCallback onStateChanged) {
    const daysOfWeek = [
      {'key': 'monday', 'label': 'Lundi'},
      {'key': 'tuesday', 'label': 'Mardi'},
      {'key': 'wednesday', 'label': 'Mercredi'},
      {'key': 'thursday', 'label': 'Jeudi'},
      {'key': 'friday', 'label': 'Vendredi'},
      {'key': 'saturday', 'label': 'Samedi'},
      {'key': 'sunday', 'label': 'Dimanche'},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Définissez vos horaires de travail pour automatiser la pause/reprise des timers.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...daysOfWeek.map((day) {
          final dayKey = day['key']!;
          final dayLabel = day['label']!;
          final schedule = workScheduleService.getDaySchedule(dayKey);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du jour avec case à cocher
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          Checkbox(
                            value: schedule.enabled,
                            onChanged: (value) {
                              if (value != null) {
                                workScheduleService.toggleDayEnabled(dayKey, value);
                                onStateChanged(); // Force rebuild
                              }
                            },
                            activeColor: Colors.teal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dayLabel,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton pour ajouter une plage horaire (toujours visible)
                    IconButton(
                      icon: const Icon(Icons.add, size: 20, color: Colors.teal),
                      onPressed: () {
                        workScheduleService.addTimeSlot(
                          dayKey,
                          const TimeSlot(startTime: '09:00', endTime: '17:00'),
                        );
                        onStateChanged(); // Force rebuild
                      },
                      tooltip: 'Ajouter une plage horaire',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                // Affichage des plages horaires (toujours au moins une visible)
                if (schedule.timeSlots.isNotEmpty)
                  ...schedule.timeSlots.asMap().entries.map((entry) {
                    final slotIndex = entry.key;
                    final slot = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                      child: Row(
                        children: [
                          // Numéro de la plage
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: schedule.enabled
                                  ? Colors.teal.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${slotIndex + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: schedule.enabled ? Colors.teal : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sélecteur d'heure de début
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(
                                context,
                                initialTime: _parseTimeString(slot.startTime),
                                onTimeSelected: (time) {
                                  final newSlot = TimeSlot(
                                    startTime: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                    endTime: slot.endTime,
                                  );
                                  workScheduleService.updateTimeSlot(dayKey, slotIndex, newSlot);
                                  onStateChanged(); // Force rebuild
                                },
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: schedule.enabled ? Colors.teal : Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: schedule.enabled
                                      ? Colors.teal.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Début',
                                      style: TextStyle(
                                        color: schedule.enabled ? Colors.white : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      slot.startTime,
                                      style: TextStyle(
                                        color: schedule.enabled ? Colors.teal : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Sélecteur d'heure de fin
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(
                                context,
                                initialTime: _parseTimeString(slot.endTime),
                                onTimeSelected: (time) {
                                  final newSlot = TimeSlot(
                                    startTime: slot.startTime,
                                    endTime: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                  );
                                  workScheduleService.updateTimeSlot(dayKey, slotIndex, newSlot);
                                  onStateChanged(); // Force rebuild
                                },
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: schedule.enabled ? Colors.orange : Colors.grey,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: schedule.enabled
                                      ? Colors.orange.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Fin',
                                      style: TextStyle(
                                        color: schedule.enabled ? Colors.white : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      slot.endTime,
                                      style: TextStyle(
                                        color: schedule.enabled ? Colors.orange : Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bouton de suppression (si plus d'une plage)
                          if (schedule.timeSlots.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20, color: Colors.red),
                              onPressed: () {
                                workScheduleService.removeTimeSlot(dayKey, slotIndex);
                                onStateChanged(); // Force rebuild
                              },
                              tooltip: 'Supprimer cette plage',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue, width: 1),
          ),
          child: const Text(
            '💡 Le timer se mettra automatiquement en pause en dehors de ces horaires et reprendra automatiquement quand vous rentrez dans vos heures de travail.',
            style: TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Méthode utilitaire pour parser une string HH:MM en TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Méthode pour afficher le sélecteur d'heure
  Future<void> _selectTime(BuildContext context, {
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onTimeSelected,
  }) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('💾 Sauvegarde & Restauration'),
        content: const SingleChildScrollView(
          child: Text('Fonctionnalité en développement...\n\nCette fonctionnalité vous permettra de sauvegarder et restaurer vos paramètres et données.'),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog "À propos"
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📱 À propos'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Is Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Text('Version 1.4.5'),
              SizedBox(height: 16),
              Text(
                'Une application Flutter conçue pour visualiser la valeur de votre temps en argent. '
                'Elle calcule et affiche vos gains en temps réel, basés sur un taux horaire configurable, '
                'avec support de 36 pays et leurs salaires minimums réels.',
                style: TextStyle(height: 1.4),
              ),
              SizedBox(height: 20),
              Text('Développé avec amour ❤️ en Flutter par XR 💻 (Xavier Redondo) et l\'aide précieuse de l\'IA 🤖'),
              SizedBox(height: 24),
              Text('Liens utiles :', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://github.com/WolwX/TimeIsMoney');
                  try {
                    await launchUrl(url);
                  } catch (_) {}
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      '📂 Repository GitHub',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://github.com/WolwX/TimeIsMoney/issues');
                  try {
                    await launchUrl(url);
                  } catch (_) {}
                },
                child: Row(
                  children: [
                    Icon(Icons.bug_report, size: 20, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      '🐛 Signaler un bug',
                      style: TextStyle(color: Colors.orange, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://github.com/WolwX/TimeIsMoney/releases');
                  try {
                    await launchUrl(url);
                  } catch (_) {}
                },
                child: Row(
                  children: [
                    Icon(Icons.new_releases, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      '📦 Versions & Téléchargements',
                      style: TextStyle(color: Colors.green, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  // Dialog d'aide avec formulaire de contact
  void _showHelpDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedCategory = 'Général';

    final List<String> categories = [
      'Général',
      'Fonctionnalités',
      'Configuration',
      'Presets',
      'Planning',
      'Notifications',
      'Bug/Erreur',
      'Autre'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('❓ Aide & Support'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contactez-nous',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text('Catégorie de votre question :'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Votre email :'),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'votre.email@exemple.com',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                const Text('Votre message :'),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Décrivez votre question ou problème...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 5,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Fermer'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (emailController.text.isEmpty || messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                final subject = '[Time Is Money] $selectedCategory';
                final body = '''
Catégorie: $selectedCategory
Email: ${emailController.text}

Message:
${messageController.text}

---
Envoyé depuis l'application Time Is Money
                ''';

                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'wolwx@hotmail.com',
                  queryParameters: {
                    'subject': subject,
                    'body': body,
                  },
                );

                try {
                  await launchUrl(emailUri);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Client email ouvert !')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Impossible d\'ouvrir le client email')),
                  );
                }
              },
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
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
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
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
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
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
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Fermer'),
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
    // Grouper les presets Dreamlist en sous-catégories
    final dreamlistSubcategories = {
      'Métiers de Rêve': (groupedPresets['Dreamlist'] ?? []).where((p) => p.category == 'Dreamlist' && p.icon != '🎰').toList(),
      'Gains Loterie': (groupedPresets['Dreamlist'] ?? []).where((p) => p.category == 'Dreamlist' && p.icon == '🎰').toList(),
    };
    
    showDialog(
      context: context,
      builder: (context) => _PresetsDialog(
        title: '✨ Presets Dreamlist',
        groupedPresets: dreamlistSubcategories,
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
                '${timer.currency} ${formatNumberWithSpaces(timer.hourlyRate, 2)}/h',
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                          _buildPresetDetail('Horaire', '${formatNumberWithSpaces(preset.rate, 2)} ${preset.currency}/h', Colors.tealAccent),
                          _buildPresetDetail('Mensuel Brut', '${formatNumberWithSpaces(monthlyGross, 2)} ${preset.currency}', Colors.greenAccent),
                          _buildPresetDetail('Mensuel Net', '${formatNumberWithSpaces(monthlyNet, 2)} ${preset.currency}', Colors.green),
                          _buildPresetDetail('Annuel Brut', '${formatNumberWithSpaces(annualGross, 2)} ${preset.currency}', Colors.yellowAccent),
                          _buildPresetDetail('Annuel Net', '${formatNumberWithSpaces(annualNet, 2)} ${preset.currency}', Colors.yellow),
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
        TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, size: 18),
          label: const Text('Fermer'),
        ),
      ],
    );
  }
}
