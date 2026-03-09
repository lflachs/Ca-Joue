import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reset_provider.g.dart';

/// Provides reset operations for user progress.
@riverpod
class ResetNotifier extends _$ResetNotifier {
  @override
  void build() {}

  /// Resets all user progress, points, streak, and onboarding flag.
  ///
  /// Clears the progress table and resets the sessions row to defaults.
  /// The expressions table is left untouched.
  Future<void> resetAll() async {
    final db = await ref.read(databaseProvider.future);

    await db.delete(Tables.progress);

    await db.update(
      Tables.sessions,
      {
        Tables.sessStreakCount: 0,
        Tables.sessStreakLastDate: null,
        Tables.sessTotalPoints: 0,
        Tables.sessCurrentLessonPosition: null,
        Tables.sessFirstLaunchCompleted: 0,
      },
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );
  }

  /// Resets only the onboarding flag so the placement test is offered again.
  ///
  /// Keeps all existing progress, points, and streak intact.
  Future<void> resetPlacement() async {
    final db = await ref.read(databaseProvider.future);

    await db.update(
      Tables.sessions,
      {Tables.sessFirstLaunchCompleted: 0},
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );
  }
}
