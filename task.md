# Tasks: Implement Tiered Pricing Model (₹499/yr & ₹799 lifetime)

- `[x]` Configure IAP Billing Bridge in `purchase_service.dart`
  - Update product IDs constants to `snapout_pro_annual` and `snapout_pro_lifetime`
  - Retrieve both products in `queryProducts()`
  - Support `buySubscription()` and `buyNonConsumable()`
- `[x]` Update State & Providers in `providers.dart`
  - Extend `ProState` to store `priceAnnual`, `priceLifetime`, `annualProduct`, and `lifetimeProduct`
  - Modify `ProController` to initialize and set state for both products with default fallbacks
  - Support both `buyAnnual()` and `buyLifetime()` purchase routines
- `[x]` Update Settings Screen UI in `settings_screen.dart`
  - Redesign `_ProCard` to present both options clearly
  - Connect separate action hooks to `buyAnnual()` and `buyLifetime()`
- `[x]` Verification
  - Run `flutter analyze` inside `C:\dev\snapout` to check for compilation and lint issues
  - Run `flutter build apk --debug` to confirm a successful build
