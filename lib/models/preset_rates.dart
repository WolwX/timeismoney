// lib/models/preset_rates.dart

class PresetRate {
  final String title;
  final double rate;
  final String currency;
  final String category;

  PresetRate({
    required this.title, 
    required this.rate, 
    this.currency = '€', 
    required this.category
  });
}

// Liste des préréglages
final List<PresetRate> presetRates = [
  // --- Catégorie : Standard / Emploi ---
  PresetRate(title: 'SMIC (France, 2024)', rate: 11.65, currency: '€', category: 'Standard / Emploi'), 
  PresetRate(title: 'Ingénieur Débutant (Moy.)', rate: 25.00, currency: '€', category: 'Standard / Emploi'),
  PresetRate(title: 'Médecin Généraliste (Moy.)', rate: 45.00, currency: '€', category: 'Standard / Emploi'),
  PresetRate(title: 'Salaire Minimum (US)', rate: 7.25, currency: '\$', category: 'Standard / Emploi'),
  
  // --- Catégorie : Tech / IT ---
  PresetRate(title: 'Responsable Informatique (Moy.)', rate: 25.27, currency: '€', category: 'Tech / IT'),
  PresetRate(title: 'Formateur Informatique (AFPA Est.)', rate: 17.50, currency: '€', category: 'Tech / IT'), 
  PresetRate(title: 'Technicien Informatique (Moy.)', rate: 17.20, currency: '€', category: 'Tech / IT'),
  PresetRate(title: 'Référent Informatique (Est.)', rate: 20.50, currency: '€', category: 'Tech / IT'), 
  PresetRate(title: 'Assistant Informatique (Est.)', rate: 14.50, currency: '€', category: 'Tech / IT'), 
  PresetRate(title: 'Développeur Senior Freelance', rate: 80.00, currency: '€', category: 'Tech / IT'),
  
  // --- Catégorie : Célébrités / Sport ---
  PresetRate(title: 'Kylian Mbappé (Est.)', rate: 19047.00, currency: '€', category: 'Célébrités / Sport'), 
  PresetRate(title: 'Star NBA (Est. Moyenne)', rate: 10000.00, currency: '\$', category: 'Célébrités / Sport'),
  
  // --- Catégorie : Fun / Arbitraire ---
  PresetRate(title: 'Taux Arbitraire Fun', rate: 99.99, currency: '₿', category: 'Fun / Arbitraire'), 
];