import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lesson_progress_provider.g.dart';

/// Returns the number of completed expressions for a given lesson.
///
/// A "completed" expression is one that has a row in the [Tables.progress]
/// table, meaning the user has encountered and answered it at least once.
@riverpod
Future<int> completedCountByLesson(Ref ref, String lessonId) async {
  final db = await ref.watch(databaseProvider.future);

  // Get expression IDs for this lesson.
  final exprRows = await db.query(
    Tables.expressions,
    columns: [Tables.exprId],
    where: '${Tables.exprLesson} = ?',
    whereArgs: [lessonId],
  );
  final ids = exprRows.map((r) => r[Tables.exprId]! as String).toList();

  if (ids.isEmpty) return 0;

  // Count how many have progress rows.
  final placeholders = List.filled(ids.length, '?').join(',');
  final progressRows = await db.query(
    Tables.progress,
    where: '${Tables.progExpressionId} IN ($placeholders)',
    whereArgs: ids,
  );

  return progressRows.length;
}

/// Returns the number of completed expressions for a given tier.
@riverpod
Future<int> completedCountByTier(Ref ref, int tier) async {
  final db = await ref.watch(databaseProvider.future);

  // Get expression IDs for this tier.
  final exprRows = await db.query(
    Tables.expressions,
    columns: [Tables.exprId],
    where: '${Tables.exprTier} = ?',
    whereArgs: [tier],
  );
  final ids = exprRows.map((r) => r[Tables.exprId]! as String).toList();

  if (ids.isEmpty) return 0;

  final placeholders = List.filled(ids.length, '?').join(',');
  final progressRows = await db.query(
    Tables.progress,
    where: '${Tables.progExpressionId} IN ($placeholders)',
    whereArgs: ids,
  );

  return progressRows.length;
}

/// Returns whether all expressions in a tier are complete.
@riverpod
Future<bool> isTierComplete(Ref ref, int tier) async {
  final db = await ref.watch(databaseProvider.future);

  // Count total expressions in this tier.
  final totalRows = await db.query(
    Tables.expressions,
    columns: [Tables.exprId],
    where: '${Tables.exprTier} = ?',
    whereArgs: [tier],
  );

  if (totalRows.isEmpty) return false;

  final completedCount = await ref.watch(
    completedCountByTierProvider(tier).future,
  );

  return completedCount >= totalRows.length;
}
