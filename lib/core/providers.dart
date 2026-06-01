import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/detection_service.dart';
import 'services/protected_apps_store.dart';
import 'services/stats_store.dart';

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
