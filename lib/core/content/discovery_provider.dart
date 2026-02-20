import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discovery_provider.g.dart';

/// Returns `true` if the expression has never been encountered before.
///
/// Checks the [Tables.progress] table for the given [expressionId].
/// No row means the user has never interacted with this expression.
@riverpod
Future<bool> isFirstEncounter(Ref ref, String expressionId) async {
  final db = await ref.watch(databaseProvider.future);
  final rows = await db.query(
    Tables.progress,
    where: '${Tables.progExpressionId} = ?',
    whereArgs: [expressionId],
    limit: 1,
  );
  return rows.isEmpty;
}
