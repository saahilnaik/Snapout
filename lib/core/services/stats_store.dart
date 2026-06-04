import 'package:hive/hive.dart';

/// What the user chose at the breathing screen for one trigger.
enum InterventionOutcome { skipped, opened }

class InterventionEvent {
  const InterventionEvent({
    required this.outcome,
    required this.packageName,
    required this.timestamp,
  });

  final InterventionOutcome outcome;
  final String packageName;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'outcome': outcome.name,
        'package': packageName,
        'ts': timestamp.millisecondsSinceEpoch,
      };

  factory InterventionEvent.fromMap(Map map) => InterventionEvent(
        outcome: InterventionOutcome.values.firstWhere(
          (o) => o.name == map['outcome'],
          orElse: () => InterventionOutcome.opened,
        ),
        packageName: map['package'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['ts'] as int? ?? 0),
      );
}

/// Aggregated, display-ready stats. Estimate: each skip saves ~15 minutes.
class StatsSummary {
  const StatsSummary({
    required this.todaySkipped,
    required this.todayOpened,
    required this.totalSkips,
    required this.streakDays,
    required this.minutesSaved,
    required this.weekSkips,
    required this.monthSkips,
  });

  final int todaySkipped;
  final int todayOpened;
  final int totalSkips;
  final int streakDays;
  final int minutesSaved;

  /// Skips per weekday for the current week, Monday..Sunday (length 7).
  final List<int> weekSkips;

  /// Skips per day for the last 30 days, index 0 = 29 days ago, 29 = today.
  final List<int> monthSkips;

  static const empty = StatsSummary(
    todaySkipped: 0,
    todayOpened: 0,
    totalSkips: 0,
    streakDays: 0,
    minutesSaved: 0,
    weekSkips: [0, 0, 0, 0, 0, 0, 0],
    monthSkips: [
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    ],
  );

  static const minutesPerSkip = 15;
}

/// Persists intervention events in Hive and derives [StatsSummary] from them.
class StatsStore {
  static const boxName = 'snapout';
  static const _key = 'events';

  Box? get _box => Hive.isBoxOpen(boxName) ? Hive.box(boxName) : null;

  List<InterventionEvent> all() {
    final raw = _box?.get(_key) as List?;
    if (raw == null) return const [];
    return raw.map((e) => InterventionEvent.fromMap(e as Map)).toList();
  }

  Future<void> add(InterventionEvent event) async {
    final list = [...all(), event];
    await _box?.put(_key, list.map((e) => e.toMap()).toList());
  }

  StatsSummary summary() => computeSummary(all());

  static StatsSummary computeSummary(List<InterventionEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var todaySkipped = 0;
    var todayOpened = 0;
    var totalSkips = 0;
    final skipDays = <DateTime>{};
    final week = List<int>.filled(7, 0);
    final month = List<int>.filled(30, 0);
    // Monday of the current week.
    final monday = today.subtract(Duration(days: today.weekday - 1));
    // Day 0 of the 30-day window.
    final monthStart = today.subtract(const Duration(days: 29));

    for (final e in events) {
      final day = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final isSkip = e.outcome == InterventionOutcome.skipped;
      if (isSkip) {
        totalSkips++;
        skipDays.add(day);
      }
      if (day == today) {
        if (isSkip) {
          todaySkipped++;
        } else {
          todayOpened++;
        }
      }
      if (isSkip && !day.isBefore(monday)) {
        final idx = day.difference(monday).inDays;
        if (idx >= 0 && idx < 7) week[idx]++;
      }
      if (isSkip && !day.isBefore(monthStart)) {
        final idx = day.difference(monthStart).inDays;
        if (idx >= 0 && idx < 30) month[idx]++;
      }
    }

    // Streak: consecutive days with a skip, ending today (or yesterday if today empty).
    var streak = 0;
    var cursor = today;
    if (!skipDays.contains(today) && skipDays.contains(today.subtract(const Duration(days: 1)))) {
      cursor = today.subtract(const Duration(days: 1));
    }
    while (skipDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StatsSummary(
      todaySkipped: todaySkipped,
      todayOpened: todayOpened,
      totalSkips: totalSkips,
      streakDays: streak,
      minutesSaved: totalSkips * StatsSummary.minutesPerSkip,
      weekSkips: week,
      monthSkips: month,
    );
  }
}
