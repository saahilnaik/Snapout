import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_scaffold.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Onboarding',
      note: 'Welcome → permissions → pick your first app (Phase 4).',
    );
  }
}
