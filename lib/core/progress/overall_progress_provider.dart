import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overall_progress_provider.g.dart';

/// Returns the total number of expressions the user has completed.
///
/// A "completed" expression is one with a row in the [Tables.progress]
/// table. Since [Tables.progExpressionId] is the primary key, no
/// duplicates are possible.
@riverpod
Future<int> totalCompletedExpressions(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  final result = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM ${Tables.progress}',
  );
  return result.first['c']! as int;
}
