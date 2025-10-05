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

// Constante pour les calculs de conversion
// (Salaire Annuel BRUT / 52 semaines / 35h par semaine)
const double _annualToHourlyFactor = 52 * 35; // 1820 heures par an (sur base 35h/semaine)
double _toHourly(double annualSalary) => annualSalary / _annualToHourlyFactor;

// Liste des préréglages
final List<PresetRate> presetRates = [
  
  // ====================================================================
  // --- Catégorie : Standard / Emploi ---
  // ====================================================================
  PresetRate(title: 'SMIC (France, 2024)', rate: 11.65, currency: '€', category: 'Standard / Emploi'), 
  PresetRate(title: 'Ingénieur Débutant (Moy.)', rate: 25.00, currency: '€', category: 'Standard / Emploi'),
  PresetRate(title: 'Médecin Généraliste (Moy.)', rate: 45.00, currency: '€', category: 'Standard / Emploi'),
  PresetRate(title: 'Salaire Minimum (US)', rate: 7.25, currency: '\$', category: 'Standard / Emploi'),
  
  // ====================================================================
  // --- NOUVELLE CATÉGORIE : SMIC International ---
  // ====================================================================
  // Basé sur le taux horaire légal ou estimé BRUT
  PresetRate(title: 'SMIC Espagne (Est. 2024)', rate: 8.85, currency: '€', category: 'SMIC International'), 
  PresetRate(title: 'SMIC Allemagne (Est. 2024)', rate: 12.41, currency: '€', category: 'SMIC International'),
  PresetRate(title: 'SMIC Royaume-Uni (Est. 2024)', rate: 13.00, currency: '£', category: 'SMIC International'),
  PresetRate(title: 'Salaire Minimum (Canada Est.)', rate: 11.50, currency: 'CA\$', category: 'SMIC International'),

  // ====================================================================
  // --- Catégorie : Santé / Médical ---
  // ====================================================================
  PresetRate(title: 'Infirmier(ère) Débutant(e)', rate: _toHourly(30000), currency: '€', category: 'Santé / Médical'),
  PresetRate(title: 'Infirmier(ère) Expérimenté(e)', rate: _toHourly(40000), currency: '€', category: 'Santé / Médical'),
  PresetRate(title: 'Aide-Soignant(e)', rate: _toHourly(22000), currency: '€', category: 'Santé / Médical'),
  PresetRate(title: 'Chirurgien (Libéral Est.)', rate: _toHourly(120000), currency: '€', category: 'Santé / Médical'),

  // ====================================================================
  // --- Catégorie : Administration / Bureau ---
  // ====================================================================
  PresetRate(title: 'Assistant(e) Administratif(ve)', rate: _toHourly(26000), currency: '€', category: 'Administration / Bureau'),
  PresetRate(title: 'Comptable', rate: _toHourly(35000), currency: '€', category: 'Administration / Bureau'),
  PresetRate(title: 'Responsable des Ressources Humaines', rate: _toHourly(55000), currency: '€', category: 'Administration / Bureau'),
  
  // ====================================================================
  // --- Catégorie : Politique / Dirigeants ---
  // ====================================================================
  PresetRate(title: 'Président de la France', rate: _toHourly(180000), currency: '€', category: 'Politique / Dirigeants'), 
  PresetRate(title: 'Premier Ministre Français', rate: _toHourly(180000), currency: '€', category: 'Politique / Dirigeants'), 
  PresetRate(title: 'Député / Sénateur (Indemnité Brute)', rate: _toHourly(87000), currency: '€', category: 'Politique / Dirigeants'), 
  PresetRate(title: 'Président des États-Unis (Salaire)', rate: _toHourly(400000), currency: '\$', category: 'Politique / Dirigeants'), 
  PresetRate(title: 'Président du Gouvernement Espagnol', rate: _toHourly(90000), currency: '€', category: 'Politique / Dirigeants'),
  
  // ====================================================================
  // --- Catégorie : Tech / IT (Complétée) ---
  // ====================================================================
  // Rétablissement des valeurs manquantes et ajout d'autres
  PresetRate(title: 'Développeur Senior Freelance', rate: 80.00, currency: '€', category: 'Tech / IT'),
  PresetRate(title: 'Responsable Informatique (Moy.)', rate: 25.27, currency: '€', category: 'Tech / IT'),
  PresetRate(title: 'Formateur Informatique (AFPA Est.)', rate: 17.50, currency: '€', category: 'Tech / IT'), // Rétabli
  PresetRate(title: 'Technicien Informatique (Moy.)', rate: 17.20, currency: '€', category: 'Tech / IT'),
  PresetRate(title: 'Assistant Informatique (Est.)', rate: 14.50, currency: '€', category: 'Tech / IT'), // Rétabli
  
  // ====================================================================
  // --- NOUVELLE CATÉGORIE : Milliardaires & Célébrités (Fun) ---
  // ====================================================================
  // Taux purement symboliques ou basés sur des estimations de gains TOTAUX annuels
  PresetRate(title: 'Elon Musk (Gain par heure Est.)', rate: 10000.00, currency: '\$', category: 'Milliardaires & Célébrités'), 
  PresetRate(title: 'Mark Zuckerberg (Gain par heure Est.)', rate: 5000.00, currency: '\$', category: 'Milliardaires & Célébrités'), 
  PresetRate(title: 'Auteur à Succès (Est. Moyenne)', rate: 250.00, currency: '€', category: 'Milliardaires & Célébrités'),
  
  // ====================================================================
  // --- NOUVELLE CATÉGORIE : Sportifs Pros (Haute Estimation) ---
  // ====================================================================
  // Basé sur des estimations annuelles de salaire/contrat (hors sponsoring)
  PresetRate(title: 'Kylian Mbappé (Est. Salaire Club)', rate: _toHourly(72000000), currency: '€', category: 'Sportifs Pros'), // Rétabli, sur base 72M€/an
  PresetRate(title: 'Joueur Pro de Football (Ligue 1 Est.)', rate: 250.00, currency: '€', category: 'Sportifs Pros'),
  PresetRate(title: 'Joueur NBA Star (Est. Moyenne Contrat)', rate: 1500.00, currency: '\$', category: 'Sportifs Pros'),
  PresetRate(title: 'Joueur Pro eSport (Top Tier)', rate: 150.00, currency: '\$', category: 'Sportifs Pros'),
];