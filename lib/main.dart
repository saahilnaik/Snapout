import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/entitlement_store.dart';
import 'core/services/protected_apps_store.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(ProtectedAppsStore.boxName);
  // Apply saved theme + accent before the first frame.
  final store = EntitlementStore();
  AppColors.applyTheme(_brightnessFor(store.themeMode));
  AppColors.applyAccent(AccentPreset.byKey(store.accentKey));
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: SnapOutApp()));
}

Brightness _brightnessFor(ThemeMode mode) => switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };

class SnapOutApp extends ConsumerStatefulWidget {
  const SnapOutApp({super.key});

  @override
  ConsumerState<SnapOutApp> createState() => _SnapOutAppState();
}

class _SnapOutAppState extends ConsumerState<SnapOutApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final detection = ref.read(detectionServiceProvider);
    // Warm path: native pushes a route while we're alive.
    detection.onLaunchRoute(_go);
    detection.onLauncherLaunch(_clearBreathingRoute);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Cold path: pull any route stashed before Dart was ready.
      final route = await detection.consumeLaunchRoute();
      if (route != null) _go(route);
      // Resume protection if apps are configured but the service isn't running
      // (after an app restart/update or reboot).
      final apps = ref.read(protectedAppsProvider);
      if (apps.isNotEmpty && !await detection.isServiceRunning()) {
        await detection.startService(apps.map((a) => a.packageName).toList());
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // React to OS light/dark switches when in system mode.
    if (mounted) setState(() {});
  }

  void _clearBreathingRoute() {
    final current = appRouter.routerDelegate.currentConfiguration.uri.path;
    if (current == '/breathing') {
      appRouter.go('/home');
    }
  }

  void _go(String route) {
    // Don't stack a second breathing screen if one is already showing (repeated
    // triggers each carry a different ?pkg=, so compare path only).
    final current = appRouter.routerDelegate.currentConfiguration.uri.path;
    final target = Uri.parse(route).path;
    if (current != target) {
      appRouter.push(route);
    } else {
      // Replace the current route to reset breathing progress and update parameters.
      appRouter.replace(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recompute palette when accent or theme mode changes (or OS brightness).
    final mode = ref.watch(themeModeProvider);
    final accentKey = ref.watch(accentProvider);
    final brightness = _brightnessFor(mode);
    AppColors.applyTheme(brightness);
    AppColors.applyAccent(AccentPreset.byKey(accentKey));
    SystemChrome.setSystemUIOverlayStyle(AppTheme.overlayFor(brightness));
    return MaterialApp.router(
      // Re-key on theme/accent so widgets reading the (static) AppColors — incl.
      // go_router's cached shell — rebuild. Router state lives in appRouter, so
      // navigation is preserved across the rekey.
      key: ValueKey('${brightness.name}_$accentKey'),
      title: 'SnapOut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme(brightness),
      routerConfig: appRouter,
    );
  }
}
