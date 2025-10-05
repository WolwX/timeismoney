# PROJECT_CONTEXT (machine-friendly)

Last updated: 2025-10-01

Overview:
- Project: Time Is Money (Flutter app)
- Version: 1.1.0 (pubspec.yaml currently set to 1.1.0+051025 in repo)
- Framework: Flutter
- State management: Provider
- Persistence: SharedPreferences behind IStorageService

Key recent changes:
- Extracted persistence to `IStorageService` + `lib/services/storage_service.dart` (SharedPreferences implementation).
- `TimerController` refactored to accept `IStorageService` and expose async `init()`.
- Unit tests added for `TimerController` using a `FakeStorage`.
- `AnimatedHourglass` implemented in `lib/widgets/animated_hourglass.dart` (CustomPainter) as a local fallback for splash.
- `FallingCurrency` particle background implemented in `lib/widgets/falling_currency.dart` and used lightly on splash for a "snow of currency symbols" effect.
- `FooterBar` added (`lib/widgets/footer_bar.dart`) showing "Créé par XR" and the version.
- Version reading logic prioritizes: explicit widget param → `pubspec.yaml` asset → `PackageInfo.fromPlatform()`.
- `scripts/update_version.ps1` added to update the build number from git commit count and run `flutter pub get`.

Known issues / operational notes:
- The `pubspec.yaml` asset trick is fragile: the file must be present in the `assets:` section of `pubspec.yaml`, then `flutter pub get` and a rebuild must be run so the asset is bundled. If not, `FooterBar` falls back to `PackageInfo` or shows `v?.?`.
- On web, heavy per-frame text painting can stall the UI; the particle system uses a reduced count and periodic updates to limit CPU.

How to reproduce / fix footer showing `v?.?` locally:
1. Ensure `pubspec.yaml` includes itself in `flutter.assets:` (this repo already has that entry).
2. From project root (Windows PowerShell):
   - Run: `flutter pub get` ; wait for it to complete.
   - Rebuild the app (for web: `flutter run -d chrome`, for mobile: `flutter run -d <device>`).
3. If you want the build number to be automated from git commits, run the helper script first:
   - In PowerShell: `scripts\update_version.ps1` (the script will compute commit count, update `pubspec.yaml` `version:` to include `+<count>`, and run `flutter pub get`).

CI recommendation:
- Add a CI step before building that runs the update script (or a cross-platform equivalent) to stamp the build number.
- Prefer generating a small `assets/version.txt` at build-time via the CI pipeline instead of depending on `pubspec.yaml` being included in assets. This is more robust across platforms.

Next dev tasks (recommended):
- Implement `HistoryScreen` and session model + persist completed sessions via `IStorageService`.
- Add a small integration test verifying `FooterBar` reads the embedded asset when present.
- Add a GitHub Actions workflow that runs `scripts/update_version.ps1` or equivalent (PowerShell is supported on hosted Windows runners) before building and publishing.

Contact:
- Created/maintained by XR (see footer in the app).