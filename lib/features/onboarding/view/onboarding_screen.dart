import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  int _selectedApp = -1;

  static const _last = 2;

  void _next() {
    if (_page < _last) {
      _pageController.nextPage(duration: AppMotion.medium, curve: AppMotion.curve);
    } else {
      context.pop();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAdvance = _page != _last || _selectedApp != -1;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  const _WelcomePage(),
                  const _PermissionsPage(),
                  _PickAppPage(
                    selected: _selectedApp,
                    onSelect: (i) => setState(() => _selectedApp = i),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  _Dots(count: _last + 1, active: _page),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _page == _last ? 'Start protecting' : 'Continue',
                    onPressed: canAdvance ? _next : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared scaffold for an onboarding page: optional hero, title, body.
class _OnboardPage extends StatelessWidget {
  const _OnboardPage({required this.hero, required this.title, required this.body, this.extra});
  final Widget hero;
  final String title;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          hero,
          const SizedBox(height: AppSpacing.xl),
          Text(title, style: t.displayMedium?.copyWith(fontSize: 34)),
          const SizedBox(height: AppSpacing.md),
          Text(body, style: t.bodyLarge),
          if (extra != null) ...[const SizedBox(height: AppSpacing.xl), extra!],
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();
  @override
  Widget build(BuildContext context) {
    return _OnboardPage(
      hero: Row(
        children: const [SnapMark(size: 64), SizedBox(width: AppSpacing.lg), Wordmark(fontSize: 40)],
      ),
      title: "Your phone's bouncer.",
      body:
          "Mindless app-opening is a reflex, not a decision. SnapOut steps in for a few seconds so you get to choose. No blocking, no shame — just a beat to breathe.",
    );
  }
}

class _PermissionsPage extends StatelessWidget {
  const _PermissionsPage();
  @override
  Widget build(BuildContext context) {
    return _OnboardPage(
      hero: const _CircleIcon(icon: Icons.lock_outline_rounded),
      title: 'Two quick permissions',
      body: "SnapOut needs these to notice when a protected app opens and to show the breathing screen on top. Nothing leaves your phone.",
      extra: Column(
        children: const [
          _PermissionRow(
            icon: Icons.bar_chart_rounded,
            title: 'Usage access',
            desc: 'To detect which app comes to the foreground.',
          ),
          SizedBox(height: AppSpacing.md),
          _PermissionRow(
            icon: Icons.layers_rounded,
            title: 'Display over other apps',
            desc: 'To show the breathing screen before the app opens.',
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.icon, required this.title, required this.desc});
  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleMedium),
                const SizedBox(height: 2),
                Text(desc, style: t.bodyMedium?.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickAppPage extends StatelessWidget {
  const _PickAppPage({required this.selected, required this.onSelect});
  final int selected;
  final ValueChanged<int> onSelect;

  // Placeholder set — real installed-app list comes with the detection phase.
  static const _apps = [
    (name: 'Instagram', icon: Icons.camera_alt_rounded),
    (name: 'YouTube', icon: Icons.play_circle_fill_rounded),
    (name: 'X', icon: Icons.tag_rounded),
    (name: 'Reddit', icon: Icons.forum_rounded),
    (name: 'TikTok', icon: Icons.music_note_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _OnboardPage(
      hero: const _CircleIcon(icon: Icons.touch_app_rounded),
      title: 'Pick your first app',
      body: 'Free covers one app. Choose the one that eats your time.',
      extra: Column(
        children: [
          for (var i = 0; i < _apps.length; i++) ...[
            AppCard(
              onTap: () => onSelect(i),
              color: selected == i ? AppColors.accentSoft : null,
              child: Row(
                children: [
                  Icon(_apps[i].icon,
                      color: selected == i ? AppColors.accent : AppColors.textMuted),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: Text(_apps[i].name, style: t.titleMedium)),
                  Icon(
                    selected == i ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: selected == i ? AppColors.accent : AppColors.textFaint,
                  ),
                ],
              ),
            ),
            if (i != _apps.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentSoft,
        border: Border.all(color: AppColors.accent, width: 2),
      ),
      child: Icon(icon, color: AppColors.accent, size: 32),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.fast,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == active ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == active ? AppColors.accent : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
