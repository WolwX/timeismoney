# 💰 Time Is Money
## Suivi de Gains en Temps Réel

Bienvenue dans **Time Is Money**, une application Flutter conçue pour visualiser la valeur de votre temps en argent. Elle calcule et affiche vos gains en temps réel, basés sur un taux horaire configurable.

---

## ✨ État actuel (v1.2.0)

Voici les changements et améliorations notables présents dans la version 1.2.0 :

### 🎯 Système Multi-Timer
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
- Nouveau modèle `SingleTimer` encapsulant l'état d'un timer
- `MultiTimerController` pour gérer la collection de timers
- Widget `TimerDisplay` réutilisable (modes compact/full)
- Sérialisation JSON pour la persistance
- Contrôles individuels et globaux (start/stop/reset, synchronisation)

### 📋 Historique v1.1.0
- Architecture et tests avec interface `IStorageService`
- Tests unitaires avec fake storage
- `AnimatedHourglass` (CustomPainter) comme sablier animé fiable
- Fond animé de particules monétaires optimisé
- `FooterBar` avec version dynamique depuis pubspec.yaml
- Script `update_version.ps1` pour automatisation

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

- La version affichée dans le footer provient directement du `pubspec.yaml`
- Format : `v1.2.0.121025` (version.buildNumber)
- Le build number suit le format DDMMYY (date de release)

---

## 🚀 Fonctionnalités à venir

### Priorité 1 : Import/Export de Configurations
- Sauvegarde des réglages d'un timer dans un fichier
- Import de configurations sauvegardées
- Partage de configurations entre appareils

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