# CLAUDE.md — SnapOut Project Context

## What is this?
SnapOut is an Android app that intercepts app launches and shows a 3-breath breathing
intervention before letting the user proceed. Built with Flutter, targeting Indian Gen Z.
Pricing: free (1 app) + one-time **SnapOut Pro** unlock at ₹149 (not built yet — prices
are plain text in `settings_screen.dart` for now; real price will come from Google Play
Console via `in_app_purchase`).

## Architecture
- Flutter 3.44 (stable). Riverpod 3.x (state), GoRouter (nav), Hive (storage).
- **Riverpod 3.x**: use `Notifier`/`NotifierProvider` — `StateNotifier` is gone.
- MVVM: `lib/features/{feature}/{view,viewmodel,model}`; shared code in
  `lib/core/{services,theme,router,widgets,utils}` + `lib/core/providers.dart`.
- **Native bridge (Android, built):** Kotlin `DetectionService` (foreground service)
  polls `UsageStatsManager` (~0.8s) for the foreground app; on a protected package it
  launches `MainActivity` with route `/breathing?live=1&pkg=<package>`. `MainActivity`
  exposes a MethodChannel `snapout/detection` (permissions, start/stop service, goHome,
  moveToBack, consumeLaunchRoute) and EventChannel `snapout/events` (detections).
  `BootReceiver` resumes after reboot. Kotlin lives in
  `android/app/src/main/kotlin/com/snapout/snapout/`.

## Key files
- `lib/core/services/detection_service.dart` — Dart side of the native bridge.
- `lib/core/services/protected_apps_store.dart` / `stats_store.dart` — Hive persistence.
- `lib/core/providers.dart` — `detectionServiceProvider`, `protectedAppsProvider`,
  `statsProvider`.
- `lib/features/intervention/view/breathing_screen.dart` — the intervention.
- `android/.../DetectionService.kt`, `MainActivity.kt`, `BootReceiver.kt`.

## Current state (progress)
1. ✅ Scaffold + dark theme + GoRouter + Hive (Session 1).
2. ✅ UI polish: design system/tokens, all screens (home/onboarding/stats/settings),
   bottom-nav shell, adaptive icon + splash.
3. ✅ Breathing screen: smooth sinusoidal lung-style orb (grows on inhale / shrinks on
   exhale, computed per-frame), aura + glow, haptics, decision buttons, back blocked.
4. ✅ Phase 2 detection: protected app opens → breathing fires over it; 30s cooldown.
   Onboarding uses a real `installed_apps` picker + permission gating; service auto-
   resumes on app start.
5. ✅ Decision behavior + real stats: skip → launcher (+log skip), open → reveal app
   (+log open); Home/Stats show live data (skips, streak, minutes saved, weekly bars).
6. ✅ IAP + Pro: `in_app_purchase` (non-consumable `snapout_pro`) + EntitlementStore
   (Hive `is_pro`); `proProvider`. Gates: unlimited apps (multi-select picker),
   shareable stats card (RepaintBoundary→PNG→share_plus), custom accent themes
   (mutable `AppColors` + presets, app root rebuilds on change). Real Play buy/restore
   wired; **debug-only unlock** in debug builds until the Play product exists (no
   account yet). The "Unlock Pro — ₹149" button no-ops with a snackbar until then.

7. ✅ Reminders: daily local notification (flutter_local_notifications + timezone),
   Settings sheet (switch + time picker), Hive-persisted; reschedules on reboot.
   Task-stack fix: main dedupes the `/breathing` push by path so repeated detections
   don't stack screens.
8. ✅ Light/dark/system theme: `AppColors` surfaces+text are mutable, `applyTheme(Brightness)`
   swaps them, `accentSoft` is a translucent accent. `themeModeProvider` (Hive) + Settings
   Theme picker; reacts to OS brightness in system mode. NOTE: widgets read static
   `AppColors` (no Theme dependency), so the app root **re-keys MaterialApp on
   brightness/accent** to force a full rebuild (incl. go_router's cached shell). When
   adding chrome that must recolor, rely on that rekey, not Theme.of.

NOT built yet: iOS, Play Console publishing. Backlog: bundle real fonts (Clash/Satoshi),
30-day stats view.

Known rough edge: repeated triggers can leave the SnapOut/breathing task stacked oddly
when re-entering from the launcher — pop the breathing route fully on dismiss in a
polish pass.

## Design Rules
- Dark default, neon lime (`#BFFF00`) accent used sparingly. Tokens in
  `lib/core/theme/app_tokens.dart`; theme in `app_theme.dart`.
- Aesthetic: professional, minimal, Gen-Z. Generous whitespace, smooth subtle motion.
- Bold type. Target fonts Clash Display / Satoshi (Fontshare) — currently Space Grotesk
  via `google_fonts` as a stand-in (google_fonts only serves the Google catalog; bundle
  the real fonts as local assets later).
- No serif fonts. No blue/purple gradients. No corporate feel.

## Code Rules
- Dart null safety; keep `flutter analyze` clean (lint enforces braces on flow control).
- Prefer Riverpod providers for app state; `setState` is fine for local widget animation
  (e.g. the breath controller).
- Platform-channel calls: catch `PlatformException` where failure is plausible.
- Intervention: back disabled until breaths done; dismiss only via the two buttons.
- Hive: `StatsStore`/`ProtectedAppsStore` guard against an unopened box and never mutate
  the list returned by a getter (it may be `const []`).

## Build / Run
- Android only. `minSdk 26`, `targetSdk 35`, `compileSdk 36` (`android/app/build.gradle.kts`);
  compileSdk 36 + core-library desugaring required by some plugins.
- Project at `C:\dev\snapout` (NO spaces — Android Gradle breaks on spaces). Flutter SDK
  at `C:\dev\flutter`. `flutter run` with a connected device.
- Test device: physical phone (RMX3360 / ColorOS) — emulators are unreliable for usage
  stats. **ColorOS blocks `adb shell appops set` / `settings put`**, so permissions and
  system settings must be granted manually on the device, not via adb.
- Repo: https://github.com/saahilnaik/Snapout (branch `main`).
