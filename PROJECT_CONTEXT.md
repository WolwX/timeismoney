# PROJECT_CONTEXT (machine-friendly)

Last updated: 2025-10-15

## Overview
- **Project**: Time Is Money (Flutter app)
- **Version**: 1.4.1 (pubspec.yaml: 1.4.1+151025)
- **Framework**: Flutter (SDK >=3.0.0)
- **State management**: Provider (ChangeNotifier)
- **Persistence**: SharedPreferences behind IStorageService
- **Platforms**: Web, Windows, Android, iOS, macOS, Linux

## Architecture Summary

### Core Models
- `SingleTimer` (`lib/models/single_timer.dart`): Encapsulates individual timer state
  - Properties: id, name, isActive, isRunning, elapsedDuration, hourlyRate, currency, rateTitle, netRatePercentage, weeklyHours
  - Methods: calculateGains(), recalculateTime(), setManualTime(Duration), toJson()/fromJson()
  - NEW in v1.3.0: setManualTime() for manual time editing
  
- `PresetRate` (`lib/models/preset_rates.dart`): Predefined rate templates
  - 36 international minimum wages with country-specific metadata
  - Properties: title, rate, currency, category, netRatePercentage (68-95%), weeklyHours (35-52h)
  - Geographic categories: Europe (14), Pays Riches (3), Amériques (6), Asie (7), Afrique (6)
  - Range: Venezuela 0.10$/h to Switzerland 24.50 CHF/h (1:245 ratio)
  - NEW in v1.3.0: netRatePercentage and weeklyHours fields per country

### Controllers
- `MultiTimerController` (`lib/providers/multi_timer_controller.dart`): Main state management
  - Manages List<SingleTimer> (max 2 timers)
  - Individual controls: startTimer(index), stopTimer(index), resetTimer(index), editTimerTime(index)
  - Global controls: startAllTimers(), stopAllTimers(), resetAllTimers(), synchronizeTimers()
  - Settings: setHourlyRate(), setCurrency(), setRateTitle(), updateHourlyRateOnly(), setNetRatePercentage(), setWeeklyHours()
  - Persistence via IStorageService (JSON serialization)
  - NEW in v1.3.0: editTimerTime() to persist manual time edits

### UI Components
- `TimerDisplay` (`lib/widgets/timer_display.dart`): Refonte UI/UX, widget réutilisable, modes compact (2 colonnes) et plein écran (1 colonne)
- Page Réglages : navigation par tuiles, overlays par catégorie, gestion avancée des presets (filtres, liens sources, feedback visuel)
- Système Multi-Timer : gestion de 2 timers indépendants, synchronisation, activation/désactivation, affichage dynamique
# v1.4.1 (15/10/2025)
- Refonte UI/UX complète des réglages et timers
- Dialogues overlays, filtres avancés pour presets, liens sources
- Système multi-timer robuste, synchronisation, feedback visuel
- Corrections bugs, robustesse accrue, compatibilité Flutter Web

- **NEW in v1.4.1**
  - Affichage des presets par catégorie sous forme de menu accordéon (ExpansionPanelList)
  - Amélioration de l’ergonomie des dialogues de presets (espacement, compacité)
  - Correction de détails visuels sur les dialogues de réglages
  - Voir CHANGELOG.txt pour l’historique complet
- `FooterBar` (`lib/widgets/footer_bar.dart`): Version display
  - Reads version from pubspec.yaml → PackageInfo fallback
  - Format: v1.3.0.141025

### Screens
- `SplashScreen`: Animated hourglass intro
- `HomeScreen`: Main timer display (adaptive 1 or 2 columns)
  - NEW in v1.3.0: All TimerDisplay widgets receive onTimeEdited callback
- `SettingsScreen`: Timer management and configuration
  - NEW in v1.3.0: _applyPreset() now applies 4 parameters (rate, currency, netRatePercentage, weeklyHours)

## Key Features (v1.3.0)

### International Minimum Wage Database (NEW)
- 36 countries with real minimum wage data
- Country-specific NET conversion rates (68% Belgium to 95% Thailand/Uganda)
- Country-specific weekly working hours (35h France to 52h South Korea)
- Automatic application of tax rates and hours when selecting country presets
- Geographic organization: Europe, Rich Countries, Americas, Asia, Africa

### Manual Time Editing (NEW)
- Click on time display when timer is paused to edit
- Dialog with 3 input fields: Hours, Minutes, Seconds
- Visual format with `:` separators between fields
- Input validation (minutes/seconds < 60)
- Edit icon (✏️) shown only when timer stopped
- Automatic gain recalculation and persistence
- Success confirmation message

### Dynamic Working Hours Calculations (NEW)
- Timer-specific weekly hours used for all estimations
- Monthly hours: (weeklyHours × 52) / 12
- Yearly hours: weeklyHours × 52
- Display shows actual hours: "Estimations Annuelles (Base 42h/sem.)" for Switzerland
- Examples:
  * France 35h/week: 151.67h/month, 1820h/year
  * Switzerland 42h/week: 182h/month, 2184h/year (+20%)
  * South Korea 52h/week: 226h/month, 2704h/year (+48.6%)

### Multi-Timer System (v1.2.0)
- Manage up to 2 independent timers simultaneously
- Each timer has separate: rate, currency, title, netRatePercentage, weeklyHours
- Active/inactive toggle per timer
- Add/remove timers dynamically (min 1, max 2)
- JSON persistence with full state restoration

### Visual Enhancements (v1.2.0)
- Rate title display (e.g., "SMIC Français" or "Salaire Minimum Suisse")
- Color-coded timers (cyan/orange borders)
- Fixed-height sections for perfect column alignment
- Timer identification in settings "(Timer 1)"

### Synchronization (v1.2.0)
- Central control zone with sync buttons
- `synchronizeTimers()`: Copy first active timer's time to others
- Independent start/stop/reset per timer
- Global start/stop/reset all active timers

## Technical Details

### Persistence Strategy
```dart
// Timer data stored as JSON array
await storage.setString('timers', jsonEncode(timersList));

// Each SingleTimer serializes to:
{
  "id": 1,
  "name": "Timer 1",
  "isActive": true,
  "isRunning": false,
  "hourlyRate": 11.88,
  "currency": "€",
  "rateTitle": "SMIC Français",
  "netRatePercentage": 77.6,
  "weeklyHours": 35.0,
  // ... etc
}
```

### State Management Flow
1. User action in UI (e.g., edit time, select preset)
2. Widget calls controller method (e.g., `controller.editTimerTime(0)`)
3. Controller updates SingleTimer state
4. Controller calls `saveTimers()` for persistence
5. Controller calls `notifyListeners()`
6. UI rebuilds via Consumer/context.watch

### Manual Time Editing Flow (NEW v1.3.0)
1. User clicks time display (when timer paused)
2. Dialog opens with current time pre-filled
3. User edits hours/minutes/seconds
4. Validation checks (minutes/seconds < 60)
5. timer.setManualTime(newDuration) updates state
6. onTimeEdited() callback triggers controller.editTimerTime(index)
7. Controller saves and notifies listeners
8. Success message displayed

### Preset Application Flow (UPDATED v1.3.0)
1. User selects country preset in SettingsScreen
2. _applyPreset() applies 4 parameters:
   - setCurrency(preset.currency)
   - setRateTitle(preset.title)
   - setNetRatePercentage(preset.netRatePercentage)
   - setWeeklyHours(preset.weeklyHours)
   - updateHourlyRateOnly(preset.rate)
3. All estimations automatically recalculate with new hours/tax rate
4. Display updates: "Base XXh/sem." shows country-specific hours

### Version Management
- pubspec.yaml: `version: 1.3.0+141025`
- Format: MAJOR.MINOR.PATCH+BUILDNUMBER
- Build number: DDMMYY (release date)
- Footer displays: v1.3.0.141025

## Country Data Examples (v1.3.0)

### Richest Countries (Minimum Wage)
- Switzerland: 24.50 CHF/h, 88% NET, 42h/week
- Luxembourg: 14.50 €/h, 85% NET, 40h/week
- Australia: 14.00 A$/h, 83% NET, 38h/week
- New Zealand: 13.20 NZ$/h, 85% NET, 40h/week
- Iceland: 13.85 €/h, 84% NET, 40h/week

### Poorest Countries (Minimum Wage)
- Venezuela: 0.10 $/h, 88% NET, 40h/week
- South Sudan: 0.15 $/h, 95% NET, 48h/week
- Uganda: 0.25 $/h, 95% NET, 48h/week
- Bangladesh: 0.35 $/h, 92% NET, 48h/week
- Pakistan: 0.40 $/h, 90% NET, 48h/week

### Tax Rate Extremes
- Lowest taxes (highest NET %): Thailand, Uganda, South Sudan (95%)
- Highest taxes (lowest NET %): Belgium (68%), France (77.6%)

## Known Issues & Notes

### Web Platform
- Heavy per-frame painting can stall UI
- Particle system uses reduced count and periodic updates
- Hot reload may crash - prefer full restart or F5 refresh

### Asset Loading
- pubspec.yaml must be in flutter.assets for embedded version reading
- Run `flutter pub get` after version changes
- Web requires full rebuild for asset updates

### Multi-Timer Limitations
- Maximum 2 timers (UI space constraint)
- Minimum 1 timer (app requires at least one)
- Timer sync copies from first active timer only

## Development Workflow

### Version Update Process
1. Edit `pubspec.yaml` version
2. Update `CHANGELOG.txt`
3. Update `splash_screen.dart` hardcoded version
4. Run `flutter pub get`
5. Test on target platform
6. Commit and push

### Testing
```bash
# Run unit tests
flutter test

# Run on web
flutter run -d chrome

# Run on Windows
flutter run -d windows

# Build for production
flutter build web
flutter build windows
```

### Debugging Multi-Timer
- Check `activeTimers` list for layout logic
- Verify `selectedTimerIndex` for settings
- Inspect JSON in SharedPreferences for persistence issues
- Use `debugPrint` in controller methods

## Next Development Tasks

### Priority 1: Import/Export (v1.3.0)
- Save timer configuration to JSON file
- Load timer configuration from file
- Share configurations between devices
- UI: Export/Import buttons in settings

### Priority 2: Session History (v1.4.0)
- `Session` model (startTime, endTime, gains, rate)
- `HistoryScreen` with session list
- Statistics and charts
- Export history to CSV

### Priority 3: Enhancements
- More than 2 timers (grid layout)
- Timer categories/tags
- Dark/Light theme toggle
- Sound notifications

## CI/CD Recommendations
- GitHub Actions workflow for automated builds
- Version stamping from git commits
- Automated testing before merge
- Multi-platform builds (web, Windows, Android)

## Contact & Maintenance
- **Created by**: XR
- **Repository**: https://github.com/WolwX/timeismoney
- **License**: [Specify license]
- **Issues**: Use GitHub Issues for bug reports and feature requests