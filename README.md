# 💰 Time Is Money
## Suivi de Gains en Temps Réel avec Base de Données Internationale

Bienvenue dans **Time Is Money**, une application Flutter conçue pour visualiser la valeur de votre temps en argent. Elle calcule et affiche vos gains en temps réel, basés sur un taux horaire configurable, avec support de 36 pays et leurs salaires minimums réels.

---



## ✨ État actuel (v1.4.2)

Version mineure publiée le 16/10/2025

### 🆕 Nouveautés v1.4.2
#### (voir CHANGELOG.txt pour détails)

- **Mode Minuteur Révolutionnaire** : Comptage à rebours avec montant cible configurable
- Affichage du temps restant en format dynamique (2 lignes avec heures)
- Édition du montant cible via dialogue pop-up (comme l'édition du temps)
- Bouton de switch mode désactivé visuellement quand timer actif
- Édition du montant cible accessible sur toute la zone (pas seulement l'icône)
- Bordure du timer quasi-invisible (0.01px) pour effet minimaliste
- Effet de bordure navigante légèrement augmenté pour meilleure visibilité

---

Voici les changements et améliorations notables présents dans la version 1.4.0 :

### 🌍 Base de Données Internationale (NOUVEAU)
- **36 pays** avec salaires minimums réels organisés par continent
- **Taux de conversion NET spécifiques** : de 68% (Belgique) à 95% (Thaïlande)
- **Heures hebdomadaires réelles** : de 35h (France) à 52h (Corée du Sud)
- **Application automatique** des paramètres pays lors de la sélection
- **Fourchette complète** : 0.10 $/h (Venezuela) à 24.50 CHF/h (Suisse)
- **Nouveaux pays** : Luxembourg, Irlande, Islande, Andorre, Venezuela, Ouganda, Soudan du Sud, Bangladesh, Pakistan, Nigeria

### ✏️ Édition Manuelle du Temps (NOUVEAU)
- **Clic sur l'affichage du temps** (quand timer en pause) pour éditer
- **Interface intuitive** avec 3 champs : Heures, Minutes, Secondes
- **Validation automatique** (minutes/secondes < 60)
- **Icône d'édition** visible uniquement sur timers arrêtés
- **Recalcul automatique** des gains après modification
- **Persistence immédiate** dans le stockage

### ⏰ Mode Minuteur Révolutionnaire (NOUVEAU)
- **Comptage à rebours** avec montant cible configurable
- **Affichage du temps restant** en format dynamique (2 lignes avec heures)
- **Édition du montant cible** via dialogue pop-up (comme l'édition du temps)
- **Icône sablier distinctive** et couleurs adaptées (ambre)
- **Calcul automatique** du temps nécessaire basé sur le taux horaire
- **Passage fluide** entre mode chrono (montée) et mode minuteur (descente)
- **Zone d'édition étendue** : clic sur tout le champ pour ouvrir le dialogue
- **Bouton de switch désactivé** visuellement quand timer actif

### 📊 Calculs Dynamiques par Pays (NOUVEAU)
- **Estimations basées sur heures réelles** : plus de valeur fixe 35h/sem
- **Affichage personnalisé** : "Base 42h/sem." pour Suisse, "Base 52h/sem." pour Corée
- **Calculs précis** : hoursPerMonth = (weeklyHours × 52) / 12
- **Exemples** :
  - France 35h : 151.67h/mois, 1820h/an
  - Suisse 42h : 182h/mois, 2184h/an (+20%)
  - Corée 52h : 226.67h/mois, 2704h/an (+48.6%)

### 🎯 Système Multi-Timer (v1.2.0)
- **Gestion de 2 timers simultanés** avec paramètres indépendants (taux, devise, réglages)
- **Affichage adaptatif** : 1 colonne (1 timer actif) ou 2 colonnes (2 timers actifs)
- **Zone centrale de contrôle** avec boutons de synchronisation
- **Activation/désactivation individuelle** des timers
- **Ajout/suppression dynamique** de timers (minimum 1, maximum 2)
- **Persistence complète** des états de tous les timers

### 🎨 Améliorations UI
- **Affichage du nom du préréglage** : "Kylian Mbappé", "Salaire Mensuel Brut", etc. au lieu de "Gains NETS"
- **Distinction visuelle par couleur** : Timer 1 en cyan, Timer 2 en orange
- **Hauteurs fixes** pour un alignement parfait en mode 2 colonnes
- **Indication claire** du timer en cours de modification dans les réglages

### 🏗️ Architecture
- Modèle `SingleTimer` avec setManualTime() pour édition
- Modèle `PresetRate` étendu avec netRatePercentage et weeklyHours
- `MultiTimerController` avec editTimerTime() pour persistence
- Widget `TimerDisplay` avec dialogue d'édition interactive
- Sérialisation JSON complète avec toutes les métadonnées
- Contrôles individuels et globaux (start/stop/reset/edit, synchronisation)

### 📋 Historique v1.1.0
- Architecture et tests avec interface `IStorageService`
- Tests unitaires avec fake storage
- `AnimatedHourglass` (CustomPainter) comme sablier animé fiable
- Fond animé de particules monétaires optimisé
- `FooterBar` avec version dynamique depuis pubspec.yaml
- Script `update_version.ps1` pour automatisation

---

## 🌐 Pays Disponibles (v1.4.1)

### 💎 Top 5 Pays Riches (Salaire Minimum)
1. **Suisse** : 24.50 CHF/h (88% NET, 42h/sem)
2. **Luxembourg** : 14.50 €/h (85% NET, 40h/sem)
3. **Australie** : 14.00 A$/h (83% NET, 38h/sem)
4. **Islande** : 13.85 €/h (84% NET, 40h/sem)
5. **Nouvelle-Zélande** : 13.20 NZ$/h (85% NET, 40h/sem)

### 💸 Top 5 Pays Pauvres (Salaire Minimum)
1. **Venezuela** : 0.10 $/h (88% NET, 40h/sem)
2. **Soudan du Sud** : 0.15 $/h (95% NET, 48h/sem)
3. **Ouganda** : 0.25 $/h (95% NET, 48h/sem)
4. **Bangladesh** : 0.35 $/h (92% NET, 48h/sem)
5. **Pakistan** : 0.40 $/h (90% NET, 48h/sem)

### 🌍 Autres Pays Disponibles
Europe : France, Allemagne, Belgique, Pays-Bas, Irlande, Espagne, Portugal, Royaume-Uni, Pologne, Russie, Andorre  
Amériques : USA, Canada, Brésil, Argentine, Mexique  
Asie : Japon, Corée du Sud, Chine, Thaïlande, Inde  
Afrique : Afrique du Sud, Maroc, Kenya, Égypte, Nigeria

---

## 🛠️ Installation et Démarrage

### Pré-requis

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.0.0)
- Un éditeur (VS Code, Android Studio, ...)

### Étapes rapides

1. Cloner le dépôt :
   ```bash
   git clone https://github.com/WolwX/timeismoney.git
   cd TimeIsMoney
   ```

2. Installer les dépendances :
   ```bash
   flutter pub get
   ```

3. Lancer l'application :
   ```bash
   flutter run -d chrome  # Pour le web
   flutter run -d windows # Pour Windows
   ```

### Notes sur la version

- La version affichée dans le footer provient dynamiquement du `pubspec.yaml`
- Format : `v1.4.1.151025` (version.buildNumber, affichage dynamique depuis pubspec.yaml)
- Le build number suit le format DDMMYY (date de release)

## 🚀 Fonctionnalités à venir

### Priorité 1 : Import/Export de Configurations

### Priorité 2 : Historique des Sessions
- Modèle `Session` pour enregistrer les sessions de travail
- Écran `HistoryScreen` pour consulter l'historique
- Statistiques et graphiques de gains

Voir `PROJECT_REFERENCE.txt` pour plus de détails.

---

## � Documentation

- `CHANGELOG.txt` : Historique détaillé des versions
- `PROJECT_CONTEXT.md` : Vue d'ensemble du projet et architecture
- `PROJECT_REFERENCE.txt` : Documentation technique complète

---

## 👨‍💻 Créé par XR

**Time Is Money** - Parce que votre temps a de la valeur ! ⏱️💰