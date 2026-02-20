import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

/// Manages the onboarding/first-launch state.
///
/// Reads and writes the `first_launch_completed` flag in the sessions table.
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  Future<bool> build() async {
    final db = await ref.watch(databaseProvider.future);

    final rows = await db.query(
      Tables.sessions,
      columns: [Tables.sessFirstLaunchCompleted],
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    // If no row or value is 0, it's the first launch.
    if (rows.isEmpty) return true;
    return rows.first[Tables.sessFirstLaunchCompleted] == 0;
  }

  /// Marks onboarding as completed and refreshes state.
  Future<void> completeOnboarding() async {
    final db = await ref.read(databaseProvider.future);

    await db.update(
      Tables.sessions,
      {Tables.sessFirstLaunchCompleted: 1},
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (ref.mounted) ref.invalidateSelf();
  }
}
