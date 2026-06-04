import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/providers.dart';
import '../../../core/services/stats_store.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/fade_slide_in.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  final _shareCardKey = GlobalKey();

  Future<void> _shareCard() async {
    try {
      final boundary =
          _shareCardKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!
          .buffer
          .asUint8List();
      final file = File('${Directory.systemTemp.path}/snapout_stats.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text: 'My focus stats, courtesy of SnapOut 🌿',
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't create the card.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stats = ref.watch(statsProvider);
    final isPro = ref.watch(proProvider).isPro;
    final hours = stats.minutesSaved ~/ 60;
    final mins = stats.minutesSaved % 60;
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time saved', style: t.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text('${hours}h ${mins}m',
                          style: t.displayLarge?.copyWith(color: AppColors.accent)),
                      const SizedBox(height: 4),
                      Text(
                        stats.totalSkips == 0
                            ? 'Skipped opens add up. Start protecting an app to see this grow.'
                            : 'Estimated from ${stats.totalSkips} skipped opens (~15 min each).',
                        style: t.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Row(
                  children: [
                    Expanded(child: _Metric(value: '${stats.totalSkips}', label: 'Total skips')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                        child: _Metric(
                            value: '${stats.streakDays}', label: 'Day streak', accent: true)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 160),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('This week', style: t.titleMedium),
                      const SizedBox(height: AppSpacing.xl),
                      _WeekBars(counts: stats.weekSkips),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                delay: const Duration(milliseconds: 240),
                child: isPro
                    ? _ProStatsSection(
                        shareCardKey: _shareCardKey,
                        stats: stats,
                        onShare: _shareCard,
                      )
                    : const _LockedProCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProStatsSection extends StatelessWidget {
  const _ProStatsSection({
    required this.shareCardKey,
    required this.stats,
    required this.onShare,
  });

  final GlobalKey shareCardKey;
  final StatsSummary stats;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: RepaintBoundary(
            key: shareCardKey,
            child: _ShareCard(stats: stats),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Share my stats',
          icon: Icons.ios_share_rounded,
          onPressed: onShare,
        ),
      ],
    );
  }
}

// Hardcoded dark palette — card must look branded even in light-mode app.
const _cardBg = Color(0xFF0A0B0D);
const _cardAccent = Color(0xFFBFFF00);
const _cardTextPrimary = Color(0xFFF4F5F7);
const _cardTextMuted = Color(0xFF9BA1AC);
const _cardTextFaint = Color(0xFF6B7280);
const _cardBorder = Color(0xFF262A30);

/// The branded card captured for sharing. Always dark regardless of app theme.
class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.stats});
  final StatsSummary stats;

  @override
  Widget build(BuildContext context) {
    final hours = stats.minutesSaved ~/ 60;
    final mins = stats.minutesSaved % 60;
    final timeLabel = hours > 0
        ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h')
        : '${mins}m';

    return Container(
      width: 320,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E100A), _cardBg],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: _cardAccent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _cardAccent.withValues(alpha: 0.18),
            blurRadius: 48,
            spreadRadius: -4,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _cardAccent.withValues(alpha: 0.06),
            blurRadius: 100,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg - 1),
        child: Stack(
          children: [
            // Decorative radial orb — top-right corner
            Positioned(
              top: -70,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _cardAccent.withValues(alpha: 0.13),
                      _cardAccent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // Top accent strip
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00BFFF00),
                      _cardAccent,
                      Color(0x55BFFF00),
                    ],
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.xl + 3, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Branding row — full-width header
                  Row(
                    children: [
                      const SnapMark(size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      const Wordmark(fontSize: 18),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _cardAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: _cardAccent.withValues(alpha: 0.4)),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            color: _cardAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Hero number
                  Text(
                    '${stats.totalSkips}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 88,
                      fontWeight: FontWeight.w700,
                      color: _cardAccent,
                      height: 0.88,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'mindless opens blocked',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _cardTextPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Week bars with day labels
                  _MiniWeekBars(counts: stats.weekSkips),
                  const SizedBox(height: AppSpacing.xl),

                  // Divider
                  Container(height: 1, color: _cardBorder),
                  const SizedBox(height: AppSpacing.lg),

                  // Supporting stats row — evenly spaced
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _CardStat(value: '${stats.streakDays}d', label: 'streak', centered: true),
                      _CardStat(value: timeLabel, label: 'reclaimed', centered: true),
                      _CardStat(
                        value: '${stats.todaySkipped}',
                        label: 'today',
                        accentValue: true,
                        centered: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Footer
                  const Text(
                    'snapout.app',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      color: _cardTextFaint,
                      letterSpacing: 0.3,
                    ),
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

class _MiniWeekBars extends StatelessWidget {
  const _MiniWeekBars({required this.counts});
  final List<int> counts;
  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final max = counts.fold<int>(1, (m, c) => c > m ? c : m);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 6 + 52.0 * (counts[i] / max),
                decoration: BoxDecoration(
                  color: counts[i] > 0 ? _cardAccent : _cardBorder,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: counts[i] > 0
                      ? [
                          BoxShadow(
                            color: _cardAccent.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _labels[i],
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 10,
                  color: _cardTextFaint,
                ),
              ),
            ],
          ),
          if (i < 6) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _CardStat extends StatelessWidget {
  const _CardStat({
    required this.value,
    required this.label,
    this.accentValue = false,
    this.centered = false,
  });
  final String value;
  final String label;
  final bool accentValue;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'ClashDisplay',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: accentValue ? _cardAccent : _cardTextPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            color: _cardTextMuted,
          ),
        ),
      ],
    );
  }
}

class _LockedProCard extends StatelessWidget {
  const _LockedProCard();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.textFaint),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shareable stats card', style: t.titleMedium),
                const SizedBox(height: 2),
                Text('Part of SnapOut Pro', style: t.bodyMedium?.copyWith(fontSize: 13)),
              ],
            ),
          ),
          _ProBadge(),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, this.accent = false});
  final String value;
  final String label;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: t.displayMedium?.copyWith(
                fontSize: 36,
                color: accent ? AppColors.accent : AppColors.textPrimary,
              )),
          const SizedBox(height: 2),
          Text(label, style: t.bodyMedium?.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.counts});
  final List<int> counts;
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final max = counts.fold<int>(0, (m, c) => c > m ? c : m);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Column(
            children: [
              if (counts[i] > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${counts[i]}',
                      style: t.bodyMedium?.copyWith(fontSize: 11, color: AppColors.accent)),
                ),
              Container(
                width: 26,
                height: counts[i] == 0 ? 6.0 : 16.0 + 64.0 * (counts[i] / (max == 0 ? 1 : max)),
                decoration: BoxDecoration(
                  color: counts[i] > 0 ? AppColors.accent : AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(_days[i], style: t.bodyMedium?.copyWith(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('PRO',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.onAccent,
                fontSize: 12,
              )),
    );
  }
}
