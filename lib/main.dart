import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Edge-to-edge with light icons on our dark canvas.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiOverlay);
  runApp(const ProviderScope(child: SnapOutApp()));
}

class SnapOutApp extends StatelessWidget {
  const SnapOutApp({super.key});

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
