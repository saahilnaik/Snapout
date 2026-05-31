// Basic smoke test for the SnapOut hello-world shell.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snapout/core/router/app_router.dart';
import 'package:snapout/core/theme/app_theme.dart';

void main() {
  testWidgets('Home screen shows branding and nav', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: AppTheme.dark,
          routerConfig: appRouter,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SnapOut'), findsOneWidget);
    expect(find.text('Start onboarding'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
