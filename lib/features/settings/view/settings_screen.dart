import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pro = ref.watch(proProvider);
    final apps = ref.watch(protectedAppsProvider);
    final accentKey = ref.watch(accentProvider);
    final reminder = ref.watch(reminderProvider);
    final themeMode = ref.watch(themeModeProvider);
    String themeLabel(ThemeMode m) => switch (m) {
          ThemeMode.light => 'Light',
          ThemeMode.dark => 'Dark',
          ThemeMode.system => 'System',
        };

    void snack(String msg) => ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.surfaceHigh));

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
              FadeSlideIn(
                child: _ProCard(
                  pro: pro,
                  onBuy: () async {
                    if (pro.storeReady) {
                      await ref.read(proProvider.notifier).buy();
                    } else {
                      snack('Purchases go live once SnapOut is on Google Play.');
                    }
                  },
                  onDebugUnlock: () => ref.read(proProvider.notifier).debugUnlock(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _Section('Protection'),
              _SettingsGroup(rows: [
                (
                  icon: Icons.apps_rounded,
                  title: 'Protected apps',
                  trailing: pro.isPro ? '${apps.length} apps' : '${apps.length} of 1',
                  onTap: null,
                ),
                (icon: Icons.air_rounded, title: 'Intervention', trailing: '3 breaths', onTap: null),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const _Section('App'),
              _SettingsGroup(rows: [
                (
                  icon: Icons.brightness_6_outlined,
                  title: 'Theme',
                  trailing: themeLabel(themeMode),
                  onTap: () => _showThemePicker(context, ref, themeMode),
                ),
                (
                  icon: Icons.palette_outlined,
                  title: 'Accent',
                  trailing: AccentPreset.byKey(accentKey).name,
                  onTap: pro.isPro
                      ? () => _showAccentPicker(context, ref, accentKey)
                      : () => snack('Custom themes are a Pro perk.'),
                ),
                (
                  icon: Icons.notifications_none_rounded,
                  title: 'Reminders',
                  trailing: reminder.enabled ? reminder.label : 'Off',
                  onTap: () => _showReminderSheet(context),
                ),
              ]),
              const SizedBox(height: AppSpacing.xl),
              const _Section('Support'),
              _SettingsGroup(rows: [
                (
                  icon: Icons.restore_rounded,
                  title: 'Restore purchases',
                  trailing: '',
                  onTap: () async {
                    await ref.read(proProvider.notifier).restore();
                    snack('Checking for previous purchases…');
                  },
                ),
                (icon: Icons.star_outline_rounded, title: 'Rate SnapOut', trailing: '', onTap: null),
                (icon: Icons.info_outline_rounded, title: 'About', trailing: 'v0.1.0', onTap: null),
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

void _showThemePicker(BuildContext context, WidgetRef ref, ThemeMode current) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (sheetContext) {
      final t = Theme.of(sheetContext).textTheme;
      const options = [
        (mode: ThemeMode.system, label: 'System', icon: Icons.brightness_auto_rounded),
        (mode: ThemeMode.light, label: 'Light', icon: Icons.light_mode_rounded),
        (mode: ThemeMode.dark, label: 'Dark', icon: Icons.dark_mode_rounded),
      ];
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: t.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final o in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(o.icon,
                      color: o.mode == current ? AppColors.accent : AppColors.textMuted),
                  title: Text(o.label, style: t.titleMedium),
                  trailing: o.mode == current
                      ? Icon(Icons.check_rounded, color: AppColors.accent)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setMode(o.mode);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

void _showReminderSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) => const _ReminderSheet(),
  );
}

class _ReminderSheet extends ConsumerWidget {
  const _ReminderSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final reminder = ref.watch(reminderProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily reminder', style: t.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('A gentle nudge to stay mindful.',
                style: t.bodyMedium?.copyWith(fontSize: 13)),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.accent,
              title: Text('Remind me', style: t.titleMedium),
              value: reminder.enabled,
              onChanged: (v) async {
                final result = await ref.read(reminderProvider.notifier).setEnabled(v);
                if (v && !result && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Allow notifications to enable reminders.')),
                  );
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: reminder.enabled,
              leading: Icon(Icons.schedule_rounded, color: AppColors.textMuted),
              title: Text('Time', style: t.titleMedium),
              trailing: Text(reminder.label,
                  style: t.bodyLarge?.copyWith(color: AppColors.accent)),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
                );
                if (picked != null) {
                  await ref.read(reminderProvider.notifier).setTime(picked.hour, picked.minute);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showAccentPicker(BuildContext context, WidgetRef ref, String currentKey) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (sheetContext) {
      final t = Theme.of(sheetContext).textTheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accent', style: t.titleMedium),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final p in AccentPreset.all)
                    GestureDetector(
                      onTap: () {
                        ref.read(accentProvider.notifier).setAccent(p.key);
                        Navigator.of(sheetContext).pop();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: p.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: p.key == currentKey ? Colors.white : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(p.name, style: t.bodyMedium?.copyWith(fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ProCard extends StatelessWidget {
  const _ProCard({required this.pro, required this.onBuy, required this.onDebugUnlock});

  final ProState pro;
  final VoidCallback onBuy;
  final VoidCallback onDebugUnlock;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (pro.isPro) {
      return AppCard(
        color: AppColors.accentSoft,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Icon(Icons.verified_rounded, color: AppColors.accent, size: 32),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SnapOut Pro', style: t.headlineSmall?.copyWith(color: AppColors.accent)),
                  const SizedBox(height: 2),
                  Text('Active — thanks for the support.', style: t.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
              Text('${pro.priceLabel} · one-time',
                  style: t.bodyMedium?.copyWith(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ...const [
            'Protect unlimited apps',
            'Full stats, streaks & shareable card',
            'Custom accent themes',
            'All future features, forever',
          ].map((s) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(s, style: t.bodyLarge?.copyWith(color: AppColors.textPrimary))),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Unlock Pro — ${pro.priceLabel}', onPressed: onBuy),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: TextButton(
                onPressed: onDebugUnlock,
                child: Text('Debug: unlock Pro',
                    style: t.bodyMedium?.copyWith(color: AppColors.textFaint, fontSize: 12)),
              ),
            ),
          ],
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

typedef SettingsRowData = ({IconData icon, String title, String trailing, VoidCallback? onTap});

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});
  final List<SettingsRowData> rows;

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
  final SettingsRowData row;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: row.onTap,
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
            Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
          ],
        ),
      ),
    );
  }
}
