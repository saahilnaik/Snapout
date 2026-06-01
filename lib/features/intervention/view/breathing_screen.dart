import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';

/// The intervention. Three guided breaths, then a gentle choice.
///
/// When fired by the detection service the route carries `?live=1&pkg=<package>`:
/// the decision is logged and we either drop the user on their launcher (skip)
/// or reveal the protected app (open). Opened from Home without those params it
/// is just a preview that pops back.
class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  static const int totalBreaths = 3;

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with SingleTickerProviderStateMixin {
  // One cycle = 4s inhale + 4s exhale (a calm, even breath).
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8));

  int _breath = 1;
  bool _isInhale = true;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _c
      ..addListener(_onTick)
      ..addStatusListener(_onStatus);
    HapticFeedback.lightImpact();
    _c.forward();
  }

  void _onTick() {
    final inhale = _c.value < 0.5;
    if (inhale != _isInhale) {
      setState(() => _isInhale = inhale);
      HapticFeedback.lightImpact();
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_breath < BreathingScreen.totalBreaths) {
      setState(() {
        _breath++;
        _isInhale = true;
      });
      _c
        ..reset()
        ..forward();
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _done = true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Sinusoidal breath fraction: 0 fully exhaled .. 1 fully inhaled.
  /// Smooth at both turns (no jerk), peaking at mid-cycle — like real lungs.
  static double breathPhase(double value) => (1 - math.cos(value * 2 * math.pi)) / 2;

  ({bool live, String pkg}) _params() {
    final q = GoRouterState.of(context).uri.queryParameters;
    return (live: q['live'] == '1', pkg: q['pkg'] ?? '');
  }

  Future<void> _onSkip() async {
    final p = _params();
    if (!p.live) {
      context.pop();
      return;
    }
    await ref.read(statsProvider.notifier).logSkip(p.pkg);
    if (mounted) context.pop();
    await ref.read(detectionServiceProvider).goHome();
  }

  Future<void> _onOpen() async {
    final p = _params();
    if (!p.live) {
      context.pop();
      return;
    }
    await ref.read(statsProvider.notifier).logOpen(p.pkg);
    if (mounted) context.pop();
    await ref.read(detectionServiceProvider).moveToBack();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return PopScope(
      // Block back until the breaths are done — dismiss only via buttons.
      canPop: _done,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.1,
              colors: [Color(0xFF14180A), AppColors.bg],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Stack(
                children: [
                  // Header pinned to the top.
                  Align(
                    alignment: Alignment.topCenter,
                    child: _Header(done: _done, breath: _breath),
                  ),
                  // Orb + label centered.
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _BreathCircle(controller: _c),
                        const SizedBox(height: AppSpacing.xxl),
                        Text(
                          _done
                              ? 'How do you feel?'
                              : (_isInhale ? 'Breathe in' : 'Breathe out'),
                          style: t.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  // Decision pinned to the bottom — only once breaths are done.
                  if (_done)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _Decision(onSkip: _onSkip, onOpen: _onOpen),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.done, required this.breath});
  final bool done;
  final int breath;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: done ? 0 : 1,
          duration: AppMotion.fast,
          child: Text(
            'Breath $breath of ${BreathingScreen.totalBreaths}',
            style: t.bodyMedium?.copyWith(letterSpacing: 1.5),
          ),
        ),
      ],
    );
  }
}

/// An organic "breathing" orb: a core that expands on inhale and contracts on
/// exhale, wrapped in soft aura rings that swell outward and a glow that
/// brightens as the lungs fill — so the motion reads like a breath, not a pulse.
class _BreathCircle extends StatelessWidget {
  const _BreathCircle({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // Recomputed every frame from the controller, so the orb grows and
        // shrinks continuously rather than jumping at phase changes.
        final t = _BreathingScreenState.breathPhase(controller.value); // 0..1
        final scale = 0.45 + t * 0.55; // 0.45 exhaled .. 1.0 inhaled
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Aura rings swell a little more than the core as you inhale.
              _auraRing(diameter: 300, alpha: 0.04 + 0.08 * t, scale: scale * 1.08),
              _auraRing(diameter: 260, alpha: 0.07 + 0.12 * t, scale: scale * 1.04),
              // Core orb.
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.accent, const Color(0xFF6F8F00)],
                    ),
                    boxShadow: [
                      // Glow grows brighter and wider on the inhale.
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.15 + 0.30 * t),
                        blurRadius: 40 + 50 * t,
                        spreadRadius: 4 + 14 * t,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _auraRing({required double diameter, required double alpha, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: alpha),
        ),
      ),
    );
  }
}

class _Decision extends StatelessWidget {
  const _Decision({required this.onSkip, required this.onOpen});

  final VoidCallback onSkip;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Nah, I'm good" is the dominant target — nudge toward the healthier
        // choice without blocking.
        PrimaryButton(
          label: "Nah, I'm good",
          icon: Icons.check_rounded,
          onPressed: onSkip,
        ),
        const SizedBox(height: AppSpacing.md),
        GhostButton(
          label: 'Open anyway',
          onPressed: onOpen,
        ),
      ],
    );
  }
}
