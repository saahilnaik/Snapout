import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/view/home_screen.dart';
import '../../features/intervention/view/breathing_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/settings/view/settings_screen.dart';
import '../../features/stats/view/stats_screen.dart';
import '../widgets/scaffold_with_nav.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Three primary tabs live inside a bottom-nav shell. Onboarding and the
/// breathing intervention are full-screen routes pushed over everything.
final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNav(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stats', builder: (c, s) => const StatsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/breathing',
      parentNavigatorKey: _rootKey,
      builder: (c, s) => const BreathingScreen(),
    ),
  ],
);
