import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_scaffold.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Stats',
      note: 'Interventions, streaks, hours saved, shareable card (Phase 5).',
    );
  }
}
