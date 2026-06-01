import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'core/services/protected_apps_store.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(ProtectedAppsStore.boxName);
  // Edge-to-edge with light icons on our dark canvas.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlay);
  runApp(const ProviderScope(child: SnapOutApp()));
}

class SnapOutApp extends ConsumerStatefulWidget {
  const SnapOutApp({super.key});

  @override
  ConsumerState<SnapOutApp> createState() => _SnapOutAppState();
}

class _SnapOutAppState extends ConsumerState<SnapOutApp> {
  @override
  void initState() {
    super.initState();
    final detection = ref.read(detectionServiceProvider);
    // Warm path: native pushes a route while we're alive.
    detection.onLaunchRoute(_go);
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

  void _go(String route) {
    if (appRouter.routerDelegate.currentConfiguration.uri.toString() != route) {
      appRouter.push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SnapOut',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
