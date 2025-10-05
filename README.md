# 💰 Time Is Money
## Suivi de Gains en Temps Réel

Bienvenue dans **Time Is Money**, une application Flutter conçue pour visualiser la valeur de votre temps en argent. Elle calcule et affiche vos gains en temps réel, basés sur un taux horaire configurable.

---

## ✨ État actuel (v1.1.0)

Voici les changements et améliorations notables présents dans la version 1.1.0 :

- Architecture et tests
    - Persistance extraite derrière une interface `IStorageService` et implémentation `SharedPreferences`.
    - Tests unitaires ajoutés (fake storage pour les tests) couvrant la logique du `TimerController`.

- UX / Splash
    - Un `AnimatedHourglass` (CustomPainter) fournit un sablier animé fiable comme fallback local (plus robuste que dépendances réseau).
    - Fond animé optionnel : particules de symboles monétaires (mode "neige"), optimisé pour faible consommation CPU.

- Divers
    - Nouvelle barre de footer `FooterBar` affichant les crédits ("Créé par XR") et la version du build.
    - Lecture de la version : priorité sur `pubspec.yaml` embarqué → fallback `PackageInfo`.
    - Script d'automatisation `scripts/update_version.ps1` pour incrémenter le build number d'après le nombre de commits Git et relancer `flutter pub get`.

---

## 🛠️ Installation et Démarrage

Pré-requis

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Un éditeur (VS Code, Android Studio, ...)

Étapes rapides

1. Cloner le dépôt :

     git clone [URL_DE_VOTRE_DEPOT]
     cd TimeIsMoney

2. Installer les dépendances :

     flutter pub get

3. Lancer l'application :

     flutter run

Notes sur la version affichée dans le footer

- La valeur affichée dans la barre de footer suit cette priorité :
    1) valeur fournie explicitement au widget (rare),
    2) lecture de `pubspec.yaml` (si le fichier est listé dans les assets et empaqueté),
    3) `PackageInfo.fromPlatform()` (fallback).
- Pour que la lecture depuis `pubspec.yaml` fonctionne, exécutez `flutter pub get` puis rebuild, ou utilisez le script `scripts/update_version.ps1` pour mettre à jour le champ `version` et réexécuter `flutter pub get`.

---

## 🚀 Prochaine fonctionnalité prioritaire

Implémenter l'Historique et la Journalisation des Sessions (modèle `Session`, écran `HistoryScreen`, stockage persistant des sessions). Voir `PROJECT_REFERENCE.txt`.