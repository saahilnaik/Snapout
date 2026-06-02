import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_tokens.dart';

/// Bottom-nav shell wrapping the three primary tabs. Minimal: hairline top
/// border, lime for the active tab, muted for the rest.
class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = [
    (icon: Icons.shield_outlined, active: Icons.shield, label: 'Home'),
    (icon: Icons.insights_outlined, active: Icons.insights, label: 'Stats'),
    (icon: Icons.settings_outlined, active: Icons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final current = navigationShell.currentIndex;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (var i = 0; i < _items.length; i++)
                  _NavButton(
                    item: _items[i],
                    selected: i == current,
                    onTap: () => navigationShell.goBranch(
                      i,
                      initialLocation: i == current,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});

  final ({IconData icon, IconData active, String label}) item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : AppColors.textFaint;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  selected ? item.active : item.icon,
                  key: ValueKey(selected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
