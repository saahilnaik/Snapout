import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScaffold(
      title: 'Settings',
      note: 'Theme, Pro unlock (₹149), restore purchases (Phase 6).',
    );
  }
}
