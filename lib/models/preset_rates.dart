// lib/models/preset_rates.dart

class PresetRate {
  final String title;
  final double rate;
  final String currency;
  final String category;
  final double netRatePercentage; // Pourcentage de conversion BRUT → NET
  final double weeklyHours; // Heures de travail hebdomadaires légales du pays
  final String? icon; // Icône emoji pour identifier rapidement le préréglage
  final String? sourceUrl; // URL vers une source officielle expliquant le taux

  PresetRate({
    required this.title, 
    required this.rate, 
    this.currency = '€', 
    required this.category,
    this.netRatePercentage = 77.6, // Valeur par défaut (France)
    this.weeklyHours = 35.0, // Valeur par défaut (France)
    this.icon, // Icône optionnelle
    this.sourceUrl, // URL optionnelle
  });
}

// Constante pour les calculs de conversion
// (Salaire Annuel BRUT / 52 semaines / 35h par semaine)
const double _annualToHourlyFactor = 52 * 35; // 1820 heures par an (sur base 35h/semaine)
double _toHourly(double annualSalary) => annualSalary / _annualToHourlyFactor;

// Liste des préréglages
final List<PresetRate> presetRates = [
  
  // ====================================================================
  // --- CATÉGORIE : Salaires Minimums - Europe ---
  // ====================================================================
  PresetRate(
    title: 'Salaire Minimum Luxembourg', 
    rate: 14.50, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 85.0, 
    weeklyHours: 40.0, 
    icon: '🇱🇺',
    sourceUrl: 'https://guichet.public.lu/fr/entreprises/ressources-humaines/remuneration-salaire/salaire-social-minimum.html',
  ),
  PresetRate(
    title: 'Salaire Minimum Irlande', 
    rate: 13.00, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 80.0, 
    weeklyHours: 39.0, 
    icon: '🇮🇪',
    sourceUrl: 'https://www.gov.ie/en/publication/7e4d8-national-minimum-wage/',
  ),
  PresetRate(
    title: 'Salaire Minimum Pays-Bas', 
    rate: 13.27, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 82.0, 
    weeklyHours: 40.0, 
    icon: '🇳🇱',
    sourceUrl: 'https://www.government.nl/topics/minimum-wage',
  ),
  PresetRate(
    title: 'Salaire Minimum Allemagne', 
    rate: 12.41, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 80.0, 
    weeklyHours: 40.0, 
    icon: '🇩🇪',
    sourceUrl: 'https://www.bundesregierung.de/breg-de/aktuelles/mindestlohn-steigt-2095304',
  ),
  PresetRate(
    title: 'SMIC Français', 
    rate: 11.88, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 77.6, 
    weeklyHours: 35.0, 
    icon: '🇫🇷',
    sourceUrl: 'https://www.service-public.fr/particuliers/vosdroits/F2300',
  ),
  PresetRate(
    title: 'Salaire Minimum Belgique', 
    rate: 11.78, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 68.0, 
    weeklyHours: 38.0, 
    icon: '🇧🇪',
    sourceUrl: 'https://emploi.belgique.be/fr/themes/remuneration/salaire-minimum',
  ),
  PresetRate(
    title: 'Salaire Minimum Royaume-Uni', 
    rate: 11.44, 
    currency: '£', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 87.0, 
    weeklyHours: 40.0, 
    icon: '🇬🇧',
    sourceUrl: 'https://www.gov.uk/national-minimum-wage-rates',
  ),
  PresetRate(
    title: 'Salaire Minimum Espagne', 
    rate: 8.85, 
    currency: '€', 
    category: 'Salaires Minimums - Europe', 
    netRatePercentage: 84.0, 
    weeklyHours: 40.0, 
    icon: '🇪🇸',
    sourceUrl: 'https://www.boe.es/buscar/act.php?id=BOE-A-2023-26651',
  ),
  PresetRate(title: 'Salaire Minimum Portugal', rate: 5.25, currency: '€', category: 'Salaires Minimums - Europe', netRatePercentage: 78.0, weeklyHours: 40.0, icon: '🇵🇹'),
  PresetRate(title: 'Salaire Minimum Pologne', rate: 4.30, currency: '€', category: 'Salaires Minimums - Europe', netRatePercentage: 82.0, weeklyHours: 40.0, icon: '🇵🇱'),
  PresetRate(title: 'Salaire Minimum Russie', rate: 2.90, currency: '\$', category: 'Salaires Minimums - Europe', netRatePercentage: 87.0, weeklyHours: 40.0, icon: '🇷🇺'),
  PresetRate(title: 'Salaire Minimum Islande', rate: 13.85, currency: '€', category: 'Salaires Minimums - Europe', netRatePercentage: 84.0, weeklyHours: 40.0, icon: '🇮🇸'),
  PresetRate(title: 'Salaire Minimum Andorre', rate: 6.85, currency: '€', category: 'Salaires Minimums - Europe', netRatePercentage: 90.0, weeklyHours: 40.0, icon: '🇦🇩'),
  
  // ====================================================================
  // --- CATÉGORIE : Salaires Minimums - Pays Riches (Hors Catégorie) ---
  // ====================================================================
  PresetRate(
    title: 'Salaire Minimum Suisse', 
    rate: 24.50, 
    currency: 'CHF', 
    category: 'Salaires Minimums - Pays Riches', 
    netRatePercentage: 88.0, 
    weeklyHours: 42.0, 
    icon: '🇨🇭',
    sourceUrl: 'https://www.ch.ch/fr/travail-et-retraite/conditions-de-travail/salaire-minimum/',
  ),
  PresetRate(title: 'Salaire Minimum Australie', rate: 14.00, currency: 'A\$', category: 'Salaires Minimums - Pays Riches', netRatePercentage: 83.0, weeklyHours: 38.0, icon: '🇦🇺'),
  PresetRate(title: 'Salaire Minimum Nouvelle-Zélande', rate: 13.20, currency: 'NZ\$', category: 'Salaires Minimums - Pays Riches', netRatePercentage: 85.0, weeklyHours: 40.0, icon: '🇳🇿'),
  
  // ====================================================================
  // --- CATÉGORIE : Salaires Minimums - Amériques ---
  // ====================================================================
  PresetRate(title: 'Salaire Minimum USA (Fédéral)', rate: 7.25, currency: '\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 85.0, weeklyHours: 40.0, icon: '🇺🇸'),
  PresetRate(title: 'Salaire Minimum Canada (Moy.)', rate: 14.00, currency: 'CA\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 82.0, weeklyHours: 40.0, icon: '🇨🇦'),
  PresetRate(title: 'Salaire Minimum Brésil', rate: 2.80, currency: '\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 75.0, weeklyHours: 44.0, icon: '🇧🇷'),
  PresetRate(title: 'Salaire Minimum Argentine', rate: 2.20, currency: '\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 83.0, weeklyHours: 48.0, icon: '🇦🇷'),
  PresetRate(title: 'Salaire Minimum Mexique', rate: 1.50, currency: '\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 88.0, weeklyHours: 48.0, icon: '🇲🇽'),
  PresetRate(title: 'Salaire Minimum Venezuela', rate: 0.10, currency: '\$', category: 'Salaires Minimums - Amériques', netRatePercentage: 88.0, weeklyHours: 40.0, icon: '🇻🇪'),
  
  // ====================================================================
  // --- CATÉGORIE : Salaires Minimums - Asie ---
  // ====================================================================
  PresetRate(title: 'Salaire Minimum Japon', rate: 7.50, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 80.0, weeklyHours: 40.0, icon: '🇯🇵'),
  PresetRate(title: 'Salaire Minimum Corée du Sud', rate: 6.50, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 85.0, weeklyHours: 52.0, icon: '🇰🇷'),
  PresetRate(title: 'Salaire Minimum Chine (Moy.)', rate: 2.50, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 90.0, weeklyHours: 44.0, icon: '🇨🇳'),
  PresetRate(title: 'Salaire Minimum Thaïlande', rate: 1.90, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 95.0, weeklyHours: 48.0, icon: '🇹🇭'),
  PresetRate(title: 'Salaire Minimum Inde (Est.)', rate: 0.50, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 92.0, weeklyHours: 48.0, icon: '🇮🇳'),
  PresetRate(title: 'Salaire Minimum Pakistan', rate: 0.40, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 90.0, weeklyHours: 48.0, icon: '🇵🇰'),
  PresetRate(title: 'Salaire Minimum Bangladesh', rate: 0.35, currency: '\$', category: 'Salaires Minimums - Asie', netRatePercentage: 92.0, weeklyHours: 48.0, icon: '🇧🇩'),
  
  // ====================================================================
  // --- CATÉGORIE : Salaires Minimums - Afrique ---
  // ====================================================================
  PresetRate(title: 'Salaire Minimum Afrique du Sud', rate: 2.30, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 85.0, weeklyHours: 45.0, icon: '🇿🇦'),
  PresetRate(title: 'Salaire Minimum Maroc', rate: 1.40, currency: '€', category: 'Salaires Minimums - Afrique', netRatePercentage: 90.0, weeklyHours: 44.0, icon: '🇲🇦'),
  PresetRate(title: 'Salaire Minimum Kenya', rate: 1.10, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 93.0, weeklyHours: 45.0, icon: '🇰🇪'),
  PresetRate(title: 'Salaire Minimum Égypte', rate: 0.80, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 90.0, weeklyHours: 48.0, icon: '🇪🇬'),
  PresetRate(title: 'Salaire Minimum Nigeria', rate: 0.60, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 92.0, weeklyHours: 40.0, icon: '🇳🇬'),
  PresetRate(title: 'Salaire Minimum Ouganda', rate: 0.25, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 95.0, weeklyHours: 48.0, icon: '🇺🇬'),
  PresetRate(title: 'Salaire Minimum Soudan du Sud', rate: 0.15, currency: '\$', category: 'Salaires Minimums - Afrique', netRatePercentage: 95.0, weeklyHours: 48.0, icon: '🇸🇸'),
  
  // ====================================================================
  // --- Catégorie : Standard / Emploi ---
  // ====================================================================
  PresetRate(title: 'Ingénieur Débutant (Moy.)', rate: 25.00, currency: '€', category: 'Standard / Emploi', icon: '👨‍💻'),
  PresetRate(title: 'Médecin Généraliste (Moy.)', rate: 45.00, currency: '€', category: 'Standard / Emploi', icon: '👨‍⚕️'),

  // ====================================================================
  // --- Catégorie : Santé / Médical ---
  // ====================================================================
  PresetRate(title: 'Infirmier(ère) Débutant(e)', rate: _toHourly(30000), currency: '€', category: 'Santé / Médical', icon: '👩‍⚕️'),
  PresetRate(title: 'Infirmier(ère) Expérimenté(e)', rate: _toHourly(40000), currency: '€', category: 'Santé / Médical', icon: '👩‍⚕️'),
  PresetRate(title: 'Aide-Soignant(e)', rate: _toHourly(22000), currency: '€', category: 'Santé / Médical', icon: '🩺'),
  PresetRate(title: 'Chirurgien (Libéral Est.)', rate: _toHourly(120000), currency: '€', category: 'Santé / Médical', icon: '⚕️'),

  // ====================================================================
  // --- Catégorie : Administration / Bureau ---
  // ====================================================================
  PresetRate(title: 'Assistant(e) Administratif(ve)', rate: _toHourly(26000), currency: '€', category: 'Administration / Bureau', icon: '📋'),
  PresetRate(title: 'Comptable', rate: _toHourly(35000), currency: '€', category: 'Administration / Bureau', icon: '🧮'),
  PresetRate(title: 'Responsable des Ressources Humaines', rate: _toHourly(55000), currency: '€', category: 'Administration / Bureau', icon: '👔'),
  
  // ====================================================================
  // --- Catégorie : Politique / Dirigeants ---
  // ====================================================================
  PresetRate(title: 'Président de la France', rate: _toHourly(180000), currency: '€', category: 'Politique / Dirigeants', icon: '🇫🇷'), 
  PresetRate(title: 'Premier Ministre Français', rate: _toHourly(180000), currency: '€', category: 'Politique / Dirigeants', icon: '🇫🇷'), 
  PresetRate(title: 'Député / Sénateur (Indemnité Brute)', rate: _toHourly(87000), currency: '€', category: 'Politique / Dirigeants', icon: '🏛️'), 
  PresetRate(title: 'Président des États-Unis (Salaire)', rate: _toHourly(400000), currency: '\$', category: 'Politique / Dirigeants', icon: '🇺🇸'), 
  PresetRate(title: 'Président du Gouvernement Espagnol', rate: _toHourly(90000), currency: '€', category: 'Politique / Dirigeants', icon: '🇪🇸'),
  
  // ====================================================================
  // --- Catégorie : Tech / IT (Complétée) ---
  // ====================================================================
  // Rétablissement des valeurs manquantes et ajout d'autres
  PresetRate(title: 'Développeur Senior Freelance', rate: 80.00, currency: '€', category: 'Tech / IT', icon: '💻'),
  PresetRate(title: 'Responsable Informatique (Moy.)', rate: 25.27, currency: '€', category: 'Tech / IT', icon: '🖥️'),
  PresetRate(title: 'Formateur Informatique (AFPA Est.)', rate: 17.50, currency: '€', category: 'Tech / IT', icon: '🎓'), // Rétabli
  PresetRate(title: 'Technicien Informatique (Moy.)', rate: 17.20, currency: '€', category: 'Tech / IT', icon: '🔧'),
  PresetRate(title: 'Assistant Informatique (Est.)', rate: 14.50, currency: '€', category: 'Tech / IT', icon: '💾'), // Rétabli
  
  // ====================================================================
  // --- CATÉGORIE FUN : Milliardaires & Célébrités ---
  // ====================================================================
  // Taux purement symboliques ou basés sur des estimations de gains TOTAUX annuels
  PresetRate(title: 'Elon Musk (Gain par heure Est.)', rate: 10000.00, currency: '\$', category: 'Sport / Fun', icon: '🚀'), 
  PresetRate(title: 'Mark Zuckerberg (Gain par heure Est.)', rate: 5000.00, currency: '\$', category: 'Sport / Fun', icon: '👤'), 
  PresetRate(title: 'Auteur à Succès (Est. Moyenne)', rate: 250.00, currency: '€', category: 'Sport / Fun', icon: '📚'),
  
  // ====================================================================
  // --- CATÉGORIE FUN : Sportifs Pros (Haute Estimation) ---
  // ====================================================================
  // Basé sur des estimations annuelles de salaire/contrat (hors sponsoring)
  PresetRate(title: 'Kylian Mbappé (Est. Salaire Club)', rate: _toHourly(72000000), currency: '€', category: 'Sport / Fun', icon: '⚽'), // Rétabli, sur base 72M€/an
  PresetRate(title: 'Joueur Pro de Football (Ligue 1 Est.)', rate: 250.00, currency: '€', category: 'Sport / Fun', icon: '⚽'),
  PresetRate(title: 'Joueur NBA Star (Est. Moyenne Contrat)', rate: 1500.00, currency: '\$', category: 'Sport / Fun', icon: '🏀'),
  PresetRate(title: 'Joueur Pro eSport (Top Tier)', rate: 150.00, currency: '\$', category: 'Sport / Fun', icon: '🎮'),
];