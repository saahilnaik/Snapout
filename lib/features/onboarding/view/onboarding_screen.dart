import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import '../../../core/providers.dart';
import '../../../core/services/protected_apps_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  final _pageController = PageController();
  int _page = 0;

  bool _usageGranted = false;
  bool _overlayGranted = false;

  List<AppInfo>? _apps;
  AppInfo? _selected;

  static const _last = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
    _loadApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check after the user returns from a system permission screen.
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final d = ref.read(detectionServiceProvider);
    final usage = await d.hasUsageAccess();
    final overlay = await d.hasOverlayPermission();
    if (mounted) {
      setState(() {
        _usageGranted = usage;
        _overlayGranted = overlay;
      });
    }
  }

  Future<void> _loadApps() async {
    final apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      excludeNonLaunchableApps: true,
      withIcon: true,
    );
    if (mounted) setState(() => _apps = apps);
  }

  bool get _canAdvance {
    switch (_page) {
      case 1:
        return _usageGranted && _overlayGranted;
      case _last:
        return _selected != null;
      default:
        return true;
    }
  }

  Future<void> _next() async {
    if (_page < _last) {
      _pageController.nextPage(duration: AppMotion.medium, curve: AppMotion.curve);
      return;
    }
    // Final page: persist + start the service, then leave onboarding.
    final app = _selected!;
    await ref.read(protectedAppsProvider.notifier).setApps([
      ProtectedApp(packageName: app.packageName, name: app.name),
    ]);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
                  _PermissionsPage(
                    usageGranted: _usageGranted,
                    overlayGranted: _overlayGranted,
                    onRequestUsage: () =>
                        ref.read(detectionServiceProvider).requestUsageAccess(),
                    onRequestOverlay: () =>
                        ref.read(detectionServiceProvider).requestOverlayPermission(),
                  ),
                  _PickAppPage(
                    apps: _apps,
                    selected: _selected,
                    onSelect: (a) => setState(() => _selected = a),
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
                    onPressed: _canAdvance ? _next : null,
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
  const _PermissionsPage({
    required this.usageGranted,
    required this.overlayGranted,
    required this.onRequestUsage,
    required this.onRequestOverlay,
  });

  final bool usageGranted;
  final bool overlayGranted;
  final VoidCallback onRequestUsage;
  final VoidCallback onRequestOverlay;

  @override
  Widget build(BuildContext context) {
    return _OnboardPage(
      hero: const _CircleIcon(icon: Icons.lock_outline_rounded),
      title: 'Two quick permissions',
      body: "SnapOut needs these to notice when a protected app opens and to show the breathing screen on top. Nothing leaves your phone.",
      extra: Column(
        children: [
          _PermissionRow(
            icon: Icons.bar_chart_rounded,
            title: 'Usage access',
            desc: 'To detect which app comes to the foreground.',
            granted: usageGranted,
            onRequest: onRequestUsage,
          ),
          const SizedBox(height: AppSpacing.md),
          _PermissionRow(
            icon: Icons.layers_rounded,
            title: 'Display over other apps',
            desc: 'To show the breathing screen before the app opens.',
            granted: overlayGranted,
            onRequest: onRequestOverlay,
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.granted,
    required this.onRequest,
  });

  final IconData icon;
  final String title;
  final String desc;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      onTap: granted ? null : onRequest,
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
          const SizedBox(width: AppSpacing.sm),
          if (granted)
            const Icon(Icons.check_circle_rounded, color: AppColors.accent)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text('Grant',
                  style: t.bodyMedium?.copyWith(color: AppColors.accent, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _PickAppPage extends StatelessWidget {
  const _PickAppPage({required this.apps, required this.selected, required this.onSelect});
  final List<AppInfo>? apps;
  final AppInfo? selected;
  final ValueChanged<AppInfo> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return _OnboardPage(
      hero: const _CircleIcon(icon: Icons.touch_app_rounded),
      title: 'Pick your first app',
      body: 'Free covers one app. Choose the one that eats your time.',
      extra: apps == null
          ? const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxl),
              child: Center(child: CircularProgressIndicator(color: AppColors.accent)),
            )
          : Column(
              children: [
                for (final app in apps!) ...[
                  AppCard(
                    onTap: () => onSelect(app),
                    color: selected?.packageName == app.packageName ? AppColors.accentSoft : null,
                    child: Row(
                      children: [
                        _AppIcon(app: app),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(child: Text(app.name, style: t.titleMedium)),
                        Icon(
                          selected?.packageName == app.packageName
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: selected?.packageName == app.packageName
                              ? AppColors.accent
                              : AppColors.textFaint,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon({required this.app});
  final AppInfo app;

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;
    if (icon == null) {
      return const Icon(Icons.android, color: AppColors.textMuted);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Image.memory(icon, width: 36, height: 36, gaplessPlayback: true),
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
