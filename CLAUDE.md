# CLAUDE.md — SnapOut Project Context

## What is this?
SnapOut is an Android app that intercepts app launches and shows a 3-breath breathing
exercise intervention before letting the user proceed. Built with Flutter, targeting
Indian Gen Z users. Pricing: free (1 app) + one-time **SnapOut Pro** unlock at ₹149.

## Architecture
- Flutter 3.44 (stable) with Riverpod (state), GoRouter (navigation), Hive (storage).
- Platform channels to Android Kotlin (FUTURE phases) for:
  - `UsageStatsManager` (foreground app detection)
  - Foreground service (persistent detection)
  - System overlay (intervention screen, `SYSTEM_ALERT_WINDOW`)
- MVVM pattern: `lib/features/{feature}/{view,viewmodel,model}`,
  shared code in `lib/core/{services,theme,router,widgets,utils}`.

## Current state
Session 1 complete: toolchain set up, project scaffolded, dark theme + GoRouter (4
routes) + Hive init wired, branded hello-world running on a physical device. Detection
service, overlay, onboarding logic, stats, and IAP are NOT built yet.

## Design Rules
- Dark theme default with neon lime (`#BFFF00`) accent — see `lib/core/theme/app_theme.dart`.
- Bold typography. Target fonts: Clash Display / Satoshi (Fontshare) — currently using
  Space Grotesk via `google_fonts` as a stand-in until the real fonts are bundled as
  local assets (google_fonts only serves the Google catalog).
- Micro-animations on interactions (spring physics).
- No serif fonts. No blue/purple gradients. No corporate feel.

## Code Rules
- Dart null safety enforced. Keep `flutter analyze` clean.
- All state via Riverpod providers, no `setState`.
- Platform channel error handling (future): always catch `PlatformException`.
- Intervention overlay (future) must: disable back button during breathing, lock
  rotation, dismiss only via buttons.

## Build / Run
- Android only for now. `minSdk 26`, `targetSdk 35`, `compileSdk 36`
  (`android/app/build.gradle.kts`). compileSdk is 36 because several plugins
  (flutter_local_notifications, in_app_purchase, share_plus) require it; core
  library desugaring is enabled for flutter_local_notifications.
- Project lives at `C:\dev\snapout` (NO spaces in path — Android Gradle breaks on spaces).
- Flutter SDK at `C:\dev\flutter`. Run: `flutter run` with a connected device.
