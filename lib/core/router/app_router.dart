import 'package:go_router/go_router.dart';

import '../../features/home/view/home_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../../features/stats/view/stats_screen.dart';

/// App routes. Home is the entry point for now; onboarding will gate it later.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
