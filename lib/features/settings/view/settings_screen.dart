import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FadeSlideIn(child: _ProCard()),
              const SizedBox(height: AppSpacing.xl),
              const _Section('Protection'),
              const _SettingsGroup(rows: [
                (icon: Icons.apps_rounded, title: 'Protected apps', trailing: '1 of 1'),
                (icon: Icons.air_rounded, title: 'Intervention', trailing: '3 breaths'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const _Section('App'),
              const _SettingsGroup(rows: [
                (icon: Icons.palette_outlined, title: 'Appearance', trailing: 'Dark'),
                (icon: Icons.notifications_none_rounded, title: 'Reminders', trailing: 'Off'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const _Section('Support'),
              const _SettingsGroup(rows: [
                (icon: Icons.restore_rounded, title: 'Restore purchases', trailing: ''),
                (icon: Icons.star_outline_rounded, title: 'Rate SnapOut', trailing: ''),
                (icon: Icons.info_outline_rounded, title: 'About', trailing: 'v0.1.0'),
              ]),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text('Made for focus • SnapOut',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textFaint,
                          fontSize: 12,
                        )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard();
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      color: AppColors.accentSoft,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('SnapOut Pro', style: t.headlineSmall?.copyWith(color: AppColors.accent)),
              const SizedBox(width: AppSpacing.sm),
              Text('₹149 · one-time',
                  style: t.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...const [
            'Protect unlimited apps',
            'Full stats, streaks & shareable card',
            'All future features, forever',
          ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    const Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(s, style: t.bodyLarge?.copyWith(color: AppColors.textPrimary))),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Unlock Pro — ₹149', onPressed: () {}),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textFaint,
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});
  final List<({IconData icon, String title, String trailing})> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _SettingsRow(row: rows[i]),
            if (i != rows.length - 1)
              const Divider(indent: AppSpacing.xl, endIndent: AppSpacing.lg),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.row});
  final ({IconData icon, String title, String trailing}) row;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        child: Row(
          children: [
            Icon(row.icon, color: AppColors.textMuted, size: 22),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(row.title, style: t.titleMedium)),
            if (row.trailing.isNotEmpty)
              Text(row.trailing, style: t.bodyMedium?.copyWith(fontSize: 13)),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}
