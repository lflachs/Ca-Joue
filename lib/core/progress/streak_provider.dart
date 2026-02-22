import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'streak_provider.g.dart';

/// Pure streak calculation — testable without database.
///
/// Compares [lastDate] (ISO 8601 date string, e.g. "2026-02-23") to
/// [now] and returns the updated streak count and date.
({int newCount, String newDate}) calculateStreak({
  required int currentCount,
  required String? lastDate,
  required DateTime now,
}) {
  final todayDate = DateTime(now.year, now.month, now.day);
  final todayString = todayDate.toIso8601String().substring(0, 10);

  if (lastDate == null) {
    // First session ever.
    return (newCount: 1, newDate: todayString);
  }

  final last = DateTime.parse(lastDate);
  final lastDateOnly = DateTime(last.year, last.month, last.day);
  final difference = todayDate.difference(lastDateOnly).inDays;

  if (difference == 0) {
    // Already recorded today — no change.
    return (newCount: currentCount, newDate: todayString);
  }

  if (difference == 1) {
    // Consecutive day — increment.
    return (newCount: currentCount + 1, newDate: todayString);
  }

  // Gap of 2+ days — reset to 1.
  return (newCount: 1, newDate: todayString);
}

/// Manages the user's daily learning streak in the sessions table.
///
/// Streak data is stored in the [Tables.sessions] singleton row (id = 1).
/// Call [recordSession] when a lesson or review session completes.
@riverpod
class StreakNotifier extends _$StreakNotifier {
  @override
  Future<({int count, String? lastDate})> build() async {
    final db = await ref.watch(databaseProvider.future);
    final rows = await db.query(
      Tables.sessions,
      columns: [Tables.sessStreakCount, Tables.sessStreakLastDate],
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (rows.isEmpty) return (count: 0, lastDate: null);

    return (
      count: rows.first[Tables.sessStreakCount]! as int,
      lastDate: rows.first[Tables.sessStreakLastDate] as String?,
    );
  }

  /// Updates the streak based on today's date.
  ///
  /// Should be called once per session completion (lesson or review).
  Future<void> recordSession() async {
    final current = state.value;
    if (current == null) return;

    final result = calculateStreak(
      currentCount: current.count,
      lastDate: current.lastDate,
      now: DateTime.now(),
    );

    final db = await ref.read(databaseProvider.future);
    await db.update(
      Tables.sessions,
      {
        Tables.sessStreakCount: result.newCount,
        Tables.sessStreakLastDate: result.newDate,
      },
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    ref.invalidateSelf();
  }
}
