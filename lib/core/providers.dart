import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'services/detection_service.dart';
import 'services/entitlement_store.dart';
import 'services/protected_apps_store.dart';
import 'services/purchase_service.dart';
import 'services/stats_store.dart';
import 'theme/app_tokens.dart';

final detectionServiceProvider = Provider<DetectionService>((ref) => DetectionService());

final protectedAppsStoreProvider = Provider<ProtectedAppsStore>((ref) => ProtectedAppsStore());

final statsStoreProvider = Provider<StatsStore>((ref) => StatsStore());

/// Aggregated stats, recomputed whenever an intervention is logged.
class StatsNotifier extends Notifier<StatsSummary> {
  @override
  StatsSummary build() => ref.read(statsStoreProvider).summary();

  Future<void> _log(InterventionOutcome outcome, String packageName) async {
    final store = ref.read(statsStoreProvider);
    await store.add(InterventionEvent(
      outcome: outcome,
      packageName: packageName,
      timestamp: DateTime.now(),
    ));
    state = store.summary();
  }

  Future<void> logSkip(String packageName) => _log(InterventionOutcome.skipped, packageName);
  Future<void> logOpen(String packageName) => _log(InterventionOutcome.opened, packageName);
}

final statsProvider = NotifierProvider<StatsNotifier, StatsSummary>(StatsNotifier.new);

// --- Pro entitlement + purchases ---

final entitlementStoreProvider = Provider<EntitlementStore>((ref) => EntitlementStore());
final purchaseServiceProvider = Provider<PurchaseService>((ref) => PurchaseService());

class ProState {
  const ProState({required this.isPro, required this.priceLabel, required this.storeReady});

  /// Pro unlocked (purchased, restored, or debug-unlocked).
  final bool isPro;

  /// Display price — real from Play when available, else the planned default.
  final String priceLabel;

  /// True when the Play product is queryable (a real purchase can be started).
  final bool storeReady;

  ProState copyWith({bool? isPro, String? priceLabel, bool? storeReady}) => ProState(
        isPro: isPro ?? this.isPro,
        priceLabel: priceLabel ?? this.priceLabel,
        storeReady: storeReady ?? this.storeReady,
      );
}

class ProController extends Notifier<ProState> {
  late final PurchaseService _svc;
  late final EntitlementStore _store;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  @override
  ProState build() {
    _svc = ref.read(purchaseServiceProvider);
    _store = ref.read(entitlementStoreProvider);
    _sub = _svc.purchaseStream.listen(_onPurchases);
    ref.onDispose(() => _sub?.cancel());
    _init();
    return ProState(isPro: _store.isPro, priceLabel: '₹149', storeReady: false);
  }

  Future<void> _init() async {
    if (!await _svc.available()) return;
    _product = await _svc.proProduct();
    if (_product != null) {
      state = state.copyWith(priceLabel: _product!.price, storeReady: true);
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        await _store.setPro(true);
        state = state.copyWith(isPro: true);
      }
      if (p.pendingCompletePurchase) await _svc.complete(p);
    }
  }

  /// Start the real Google Play purchase (no-op until the store is ready).
  Future<void> buy() async {
    final product = _product;
    if (product != null) await _svc.buy(product);
  }

  Future<void> restore() => _svc.restore();

  /// Testing shortcut while there's no Play product yet.
  Future<void> debugUnlock() async {
    await _store.setPro(true);
    state = state.copyWith(isPro: true);
  }
}

final proProvider = NotifierProvider<ProController, ProState>(ProController.new);

// --- Accent theme (Pro) ---

/// Holds the selected accent key and keeps [AppColors] in sync. The app root
/// watches this and rebuilds the theme when it changes.
class AccentController extends Notifier<String> {
  @override
  String build() {
    final key = ref.read(entitlementStoreProvider).accentKey;
    AppColors.applyAccent(AccentPreset.byKey(key));
    return key;
  }

  Future<void> setAccent(String key) async {
    await ref.read(entitlementStoreProvider).setAccentKey(key);
    AppColors.applyAccent(AccentPreset.byKey(key));
    state = key;
  }
}

final accentProvider = NotifierProvider<AccentController, String>(AccentController.new);

/// The list of guarded apps, kept in sync with Hive and the native service.
class ProtectedAppsNotifier extends Notifier<List<ProtectedApp>> {
  @override
  List<ProtectedApp> build() => ref.read(protectedAppsStoreProvider).getAll();

  Future<void> setApps(List<ProtectedApp> apps) async {
    await ref.read(protectedAppsStoreProvider).setAll(apps);
    state = apps;
    final detection = ref.read(detectionServiceProvider);
    final packages = apps.map((a) => a.packageName).toList();
    if (packages.isEmpty) {
      await detection.stopService();
    } else {
      await detection.startService(packages);
    }
  }
}

final protectedAppsProvider =
    NotifierProvider<ProtectedAppsNotifier, List<ProtectedApp>>(ProtectedAppsNotifier.new);
