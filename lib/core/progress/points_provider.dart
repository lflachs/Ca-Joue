import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'points_provider.g.dart';

/// Manages the user's total accumulated points in the sessions table.
///
/// Points are stored in the [Tables.sessions] singleton row (id = 1).
/// The value only increases — correct answers award +1 via [increment],
/// incorrect answers have no effect.
@riverpod
class TotalPointsNotifier extends _$TotalPointsNotifier {
  @override
  Future<int> build() async {
    final db = await ref.watch(databaseProvider.future);
    final rows = await db.query(
      Tables.sessions,
      columns: [Tables.sessTotalPoints],
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (rows.isEmpty) return 0;
    return rows.first[Tables.sessTotalPoints]! as int;
  }

  /// Increments total_points by 1 in the sessions singleton row.
  Future<void> increment() async {
    final db = await ref.read(databaseProvider.future);
    await db.rawUpdate(
      'UPDATE ${Tables.sessions} '
      'SET ${Tables.sessTotalPoints} = ${Tables.sessTotalPoints} + 1 '
      'WHERE ${Tables.sessId} = 1',
    );
    ref.invalidateSelf();
  }
}
