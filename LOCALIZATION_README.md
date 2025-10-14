# 🌍 Système de Localisation - Time Is Money

## ✅ Implémentation terminée

Le système de localisation multilingue est maintenant entièrement configuré dans l'application !

### 📦 Packages installés
- `flutter_localizations` - Localisation Flutter officielle
- `intl ^0.20.2` - Internationalisation
- `shared_preferences` - Sauvegarde de la langue choisie

### 🗣️ Langues supportées
1. **Français** 🇫🇷 (par défaut)
2. **English** 🇬🇧
3. **Español** 🇪🇸
4. **Langue du système** 🌍 (détection automatique)

---

## 📁 Fichiers créés

### Structure de localisation :
```
lib/l10n/
├── app_localizations.dart        # Classe abstraite + Delegate
├── app_localizations_fr.dart     # Traductions françaises
├── app_localizations_en.dart     # Traductions anglaises
└── app_localizations_es.dart     # Traductions espagnoles

lib/providers/
└── locale_provider.dart           # Gestion de la langue sélectionnée

lib/screens/
└── language_settings_screen.dart  # Écran de sélection de langue
```

---

## 🚀 Comment l'utiliser dans le code

### 1. Accéder aux traductions dans n'importe quel widget :

```dart
import 'package:timeismoney/l10n/app_localizations.dart';

// Dans votre méthode build :
final l10n = AppLocalizations.of(context);

// Utiliser les traductions :
Text(l10n.start)        // "Démarrer" / "Start" / "Iniciar"
Text(l10n.stop)         // "Arrêter" / "Stop" / "Detener"
Text(l10n.hourlyRate)   // "Taux horaire" / "Hourly rate" / "Tarifa por hora"
```

### 2. Changer la langue programmatiquement :

```dart
import 'package:provider/provider.dart';
import 'package:timeismoney/providers/locale_provider.dart';

// Changer vers le français
Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale('fr'));

// Changer vers l'anglais
Provider.of<LocaleProvider>(context, listen: false).setLocale(Locale('en'));

// Revenir à la langue du système
Provider.of<LocaleProvider>(context, listen: false).setLocale(null);
```

### 3. Ouvrir l'écran de sélection de langue :

```dart
import 'package:timeismoney/screens/language_settings_screen.dart';

// Dans votre bouton ou ListTile :
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const LanguageSettingsScreen(),
  ),
);
```

---

## 📝 Traductions disponibles

### Exemple de traductions clés :

| Français | English | Español |
|----------|---------|---------|
| Démarrer | Start | Iniciar |
| Arrêter | Stop | Detener |
| Réinitialiser | Reset | Reiniciar |
| Taux horaire | Hourly rate | Tarifa por hora |
| Paramètres | Settings | Ajustes |
| Plus de détails | More details | Más detalles |
| Timers synchronisés | Timers synced | Temporizadores sincronizados |
| Langue du système | System default | Idioma del sistema |

**Toutes les traductions sont disponibles dans les fichiers `app_localizations_*.dart`**

---

## 🎯 Prochaines étapes recommandées

### Pour intégrer dans l'écran de paramètres existant :

1. **Ajouter un bouton/ListTile dans `settings_screen.dart` :**

```dart
ListTile(
  leading: const Icon(Icons.language, color: Color(0xFFFFD700)),
  title: Text(l10n.language),
  subtitle: Text(l10n.chooseLanguage),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LanguageSettingsScreen(),
      ),
    );
  },
)
```

2. **Remplacer tous les textes en dur par des appels à `l10n` :**

Exemple :
```dart
// Avant :
Text('Démarrer')

// Après :
Text(AppLocalizations.of(context).start)
```

3. **Tester sur différentes langues :**
   - Changer la langue du système
   - Vérifier que l'app détecte automatiquement
   - Tester le sélecteur manuel dans les paramètres

---

## 🔧 Ajouter une nouvelle langue

Pour ajouter une nouvelle langue (ex: Allemand 🇩🇪) :

1. Créer `lib/l10n/app_localizations_de.dart`
2. Implémenter toutes les méthodes de `AppLocalizations`
3. Ajouter `'de'` dans `isSupported()` et `load()` du delegate
4. Ajouter `Locale('de', '')` dans `supportedLocales` de `main.dart`
5. Ajouter l'option dans `language_settings_screen.dart`

---

## ✨ Fonctionnalités implémentées

- ✅ Détection automatique de la langue du système
- ✅ Sauvegarde de la langue choisie (persistance)
- ✅ Écran de sélection de langue élégant
- ✅ Provider pour gérer le changement de langue en temps réel
- ✅ Support complet de 3 langues (FR/EN/ES)
- ✅ Indicateur visuel de la langue active
- ✅ Drapeaux emoji pour chaque langue

---

## 📱 Comportement par défaut

1. **Premier lancement :** Langue du système détectée automatiquement
2. **Langues supportées :** Français, Anglais, Espagnol
3. **Langue non supportée :** Bascule automatiquement en français
4. **Changement manuel :** Sauvegardé et persistant entre les lancements

---

**🎉 Le système est prêt à être utilisé ! Il suffit maintenant de remplacer progressivement les textes en dur par les appels à `AppLocalizations.of(context)`.** 

Pour toute question ou ajout de traductions, consulter les fichiers dans `lib/l10n/`.
