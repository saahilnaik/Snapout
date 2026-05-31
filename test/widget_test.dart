// Basic smoke test for the SnapOut shell.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snapout/core/router/app_router.dart';
import 'package:snapout/core/theme/app_theme.dart';

void main() {
  testWidgets('Home renders with CTA and bottom nav', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Add an app to protect'), findsOneWidget);
    expect(find.text('Preview the breathing exercise'), findsOneWidget);
    // Bottom nav tabs.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
