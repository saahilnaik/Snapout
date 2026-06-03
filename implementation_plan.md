# Implementation Plan: SnapOut Startup Scaffolding (Revised)

This updated implementation plan incorporates your design and execution feedback.

---

## Project Context & Architecture

We are continuing development on the Flutter codebase located at `C:\dev\snapout` (the directory chosen to avoid Gradle build errors caused by spaces in `c:\Personal Files\CODE WITH SAAHIL\SNAPOUT`).

- **Stack**: Flutter 3.44 (stable) + Riverpod 3.x + GoRouter + Hive.
- **Android Integration**: Kotlin platform channels are already built to communicate with `UsageStatsManager` (Foreground Service) and draw custom overlay panels (`SYSTEM_ALERT_WINDOW`) during launch interception.
- **Pricing Strategy (Updated)**:
  - **Free Tier**: Interception for 1 app, basic breathing intervention, today's stats.
  - **SnapOut Pro (Annual Subscription)**: ₹499/year
  - **SnapOut Pro (Lifetime Purchase)**: ₹799 one-time
- **Testing**: Using your connected physical Android device.
- **Firebase**: Postponed for future implementation phases.
- **AI Agent Reference File**: Using [ANTIGRAVITY.md](file:///C:/dev/snapout/ANTIGRAVITY.md) (and [ANTIGRAVITY.md](file:///c:/Personal%20Files/CODE%20WITH%20SAAHIL/SNAPOUT/ANTIGRAVITY.md) in the opened workspace) to track rules, command commands, and project status.

---

## User Review Required

> [!IMPORTANT]
> **Proposed Pricing Interface Adjustments:**
> - We will modify the Pro Upgrade card on the settings screen to show two buying options: **₹499/year** and **₹799 lifetime**.
> - The buttons will prompt purchases for product IDs `snapout_pro_annual` and `snapout_pro_lifetime` respectively.
> - We will update `PurchaseService` to fetch both products, handle subscription and non-consumable flows correctly, and update the entitlement state.
> - We will update `providers.dart` to support these two options in the `ProState` and `ProController`.

---

## Proposed Changes

### 1. Context Reference
- **[NEW]** [ANTIGRAVITY.md](file:///c:/Personal%20Files/CODE%20WITH%20SAAHIL/SNAPOUT/ANTIGRAVITY.md) (Workspace root)
- **[NEW]** [ANTIGRAVITY.md](file:///C:/dev/snapout/ANTIGRAVITY.md) (Dev project folder)
- **[DELETE]** [CLAUDE.md](file:///C:/dev/snapout/CLAUDE.md) (To avoid duplicates)

### 2. State & Providers
- **[MODIFY]** [providers.dart](file:///C:/dev/snapout/lib/core/providers.dart)
  - Modify `ProState` to contain `priceAnnual` and `priceLifetime`.
  - Update `ProController` to query both product IDs (`snapout_pro_annual` and `snapout_pro_lifetime`) using the updated `PurchaseService`.
  - Set default fallback prices to `₹499/yr` and `₹799` when the Play Store catalog is not queryable (e.g., local debug mode).
  - Update `buyAnnual()` and `buyLifetime()` triggers.

### 3. IAP Billing Bridge
- **[MODIFY]** [purchase_service.dart](file:///C:/dev/snapout/lib/core/services/purchase_service.dart)
  - Declare constants `productIdAnnual` (`snapout_pro_annual`) and `productIdLifetime` (`snapout_pro_lifetime`).
  - Query both product IDs via `queryProductDetails`.
  - Expose `buySubscription(ProductDetails product)` and `buyNonConsumable(ProductDetails product)`.

### 4. Settings Screen UI
- **[MODIFY]** [settings_screen.dart](file:///C:/dev/snapout/lib/features/settings/view/settings_screen.dart)
  - Update `_ProCard` layout to display both tiers (Annual at ₹499/year, Lifetime at ₹799 one-time).
  - Replace the single unlock button with separate buttons (or a selection layout + button) for the two options.

---

## Verification Plan

### Automated Tests
- Run `flutter analyze` inside `C:\dev\snapout` to ensure all imports, Riverpod 3.x patterns, and Dart features compile clean.
- Build the debug app to verify there are no compilation errors: `flutter build apk --debug`.

### Manual Verification
- Deploy to your physical test device and verify:
  - Settings screen shows the new pricing options (₹499/year and ₹799).
  - Tapping "Debug: unlock Pro" (available in debug builds) correctly unlocks all features (unlimited apps, custom accents, etc.).
  - Restoring purchases and real store buttons execute the proper method hooks.
