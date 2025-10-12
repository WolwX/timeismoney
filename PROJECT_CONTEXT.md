# PROJECT_CONTEXT (machine-friendly)

Last updated: 2025-10-12

## Overview
- **Project**: Time Is Money (Flutter app)
- **Version**: 1.2.0 (pubspec.yaml: 1.2.0+121025)
- **Framework**: Flutter (SDK >=3.0.0)
- **State management**: Provider (ChangeNotifier)
- **Persistence**: SharedPreferences behind IStorageService
- **Platforms**: Web, Windows, Android, iOS, macOS, Linux

## Architecture Summary

### Core Models
- `SingleTimer` (`lib/models/single_timer.dart`): Encapsulates individual timer state
  - Properties: id, name, isActive, isRunning, elapsedDuration, hourlyRate, currency, rateTitle, etc.
  - Methods: calculateGains(), recalculateTime(), toJson()/fromJson()
  
- `PresetRate` (`lib/models/preset_rates.dart`): Predefined rate templates
  - ~70 presets grouped by category (Standard, Santé, Sport, etc.)

### Controllers
- `MultiTimerController` (`lib/providers/multi_timer_controller.dart`): Main state management
  - Manages List<SingleTimer> (max 2 timers)
  - Individual controls: startTimer(index), stopTimer(index), resetTimer(index)
  - Global controls: startAllTimers(), stopAllTimers(), resetAllTimers(), synchronizeTimers()
  - Settings: setHourlyRate(), setCurrency(), setRateTitle(), updateHourlyRateOnly()
  - Persistence via IStorageService (JSON serialization)

### UI Components
- `TimerDisplay` (`lib/widgets/timer_display.dart`): Reusable timer widget
  - Modes: compact (2 columns) and full (1 column)
  - Fixed heights for perfect alignment
  - Color-coded borders (Timer 1: cyan, Timer 2: orange)
  
- `FooterBar` (`lib/widgets/footer_bar.dart`): Version display
  - Reads version from pubspec.yaml → PackageInfo fallback
  - Format: v1.2.0.121025

### Screens
- `SplashScreen`: Animated hourglass intro
- `HomeScreen`: Main timer display (adaptive 1 or 2 columns)
- `SettingsScreen`: Timer management and configuration

## Key Features (v1.2.0)

### Multi-Timer System
- Manage up to 2 independent timers simultaneously
- Each timer has separate: rate, currency, title, settings
- Active/inactive toggle per timer
- Add/remove timers dynamically (min 1, max 2)
- JSON persistence with full state restoration

### Visual Enhancements
- Rate title display (e.g., "Kylian Mbappé" instead of "Gains NETS")
- Color-coded timers (cyan/orange borders)
- Fixed-height sections for perfect column alignment
- Timer identification in settings "(Timer 1)"

### Synchronization
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
  "hourlyRate": 15.0,
  "currency": "€",
  "rateTitle": "Kylian Mbappé",
  // ... etc
}
```

### State Management Flow
1. User action in UI (e.g., start timer)
2. Widget calls controller method (e.g., `controller.startTimer(0)`)
3. Controller updates SingleTimer state
4. Controller calls `saveTimers()` for persistence
5. Controller calls `notifyListeners()`
6. UI rebuilds via Consumer/context.watch

### Version Management
- pubspec.yaml: `version: 1.2.0+121025`
- Format: MAJOR.MINOR.PATCH+BUILDNUMBER
- Build number: DDMMYY (release date)
- Footer displays: v1.2.0.121025

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