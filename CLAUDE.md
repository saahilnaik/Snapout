# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

SnapOut — an Android-only Flutter app that intercepts launches of user-chosen apps and shows a 3-breath breathing intervention before letting the user proceed. Free tier guards 1 app; **SnapOut Pro** (₹499/year or ₹799 lifetime via `in_app_purchase`) unlocks more.

## Commands

```bash
flutter pub get                 # after any pubspec change
flutter analyze                 # lint MUST stay clean; lints enforce braces on flow control
flutter run                     # to a connected physical device (see gotcha below)
flutter test                    # full suite
flutter test path/to/file_test.dart -p 'name'   # single test by name
flutter build apk --release
```

- **Run on a physical phone, not an emulator** — detection relies on `UsageStatsManager`, which emulators report unreliably.
- Project must stay at a **space-free path** (`C:\dev\snapout`); Android Gradle breaks on spaces.
- Android SDK levels: `minSdk 26`, `targetSdk 35`, `compileSdk 36` (`android/app/build.gradle.kts`). compileSdk 36 + core-library desugaring are required by plugins.

## Architecture

MVVM-ish: `lib/features/{feature}/view/` for screens, shared code in `lib/core/{services,theme,router,widgets}` + the single `lib/core/providers.dart` wiring file. No iOS target.

### Native detection bridge (the core mechanism)
The interception is **half Kotlin, half Dart**. Kotlin lives in `android/app/src/main/kotlin/com/snapout/snapout/`:
- `DetectionService.kt` — foreground service polling `UsageStatsManager` (~0.8s) for the foreground package; on a protected package it launches `MainActivity` with route `/breathing?live=1&pkg=<package>`.
- `MainActivity.kt` — `MethodChannel('snapout/detection')` (permissions, start/stop service, `goHome`, `moveToBack`, `consumeLaunchRoute`) + `EventChannel('snapout/events')` (detections).
- `BootReceiver.kt` — resumes the service after reboot.

Dart side is [lib/core/services/detection_service.dart](lib/core/services/detection_service.dart) (thin channel wrapper). Routing has three paths, all handled in [lib/main.dart](lib/main.dart):
- **Warm** — native calls `onLaunchRoute` while Dart is alive.
- **Cold** — Dart calls `consumeLaunchRoute()` post-first-frame to pull a route stashed before it was ready.
- **Launcher** — `onLauncherLaunch` resets a stuck `/breathing` route back to `/home`.
- Repeated detections must not stack breathing screens: `_go` compares **path only** (each push carries a different `?pkg=`) and `push`es a new path but `replace`s a same-path re-trigger.

### State (Riverpod 3.x)
Use `Notifier`/`NotifierProvider` only — `StateNotifier` is removed in 3.x. All providers are declared in [lib/core/providers.dart](lib/core/providers.dart): detection, protected apps, stats, Pro entitlement/purchases, accent, reminders, theme mode. `setState` is acceptable only for local widget animation (e.g. the breath controller).

### Storage (Hive)
Two boxes. `ProtectedAppsStore` opens box `snapout` in `main()` before `runApp`; reminder/theme controllers read that same box lazily and guard `Hive.isBoxOpen`. Store getters may return `const []` — **never mutate a list returned by a getter**.

### Theme (the rekey trick — read before touching chrome)
Design tokens are mutable statics in [lib/core/theme/app_tokens.dart](lib/core/theme/app_tokens.dart) (`AppColors.applyTheme(brightness)` / `applyAccent(preset)`); the theme is built in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart). Because widgets read static `AppColors` directly (not `Theme.of(context)`), the app root **re-keys `MaterialApp` on `brightness_accent`** to force a full rebuild — including go_router's cached shell. Router state lives in `appRouter`, so navigation survives the rekey. When adding chrome that must recolor on theme/accent change, rely on the rekey, **not** `Theme.of`.

### IAP / Pro
`ProController` in providers.dart drives two products (`snapout_pro_annual`, `snapout_pro_lifetime` — IDs in `PurchaseService`). `debugUnlock()` is the testing shortcut while Play products aren't live. Entitlement persists via `EntitlementStore`.

## Conventions

- Platform-channel calls: catch `PlatformException` where failure is plausible.
- Intervention UX is a hard rule: back is disabled until the breaths complete; the screen dismisses only via its two decision buttons.
- Design: dark default, neon-lime `#BFFF00` accent used sparingly, no serif fonts, no blue/purple gradients. Tokens only — screens reference tokens, never color/spacing literals.
