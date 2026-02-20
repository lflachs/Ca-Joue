import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'expressions_by_lesson_provider.g.dart';

/// Provides all expressions for a given lesson ID.
@riverpod
Future<List<Expression>> expressionsByLesson(
  Ref ref,
  String lessonId,
) async {
  final db = await ref.watch(databaseProvider.future);
  final rows = await db.query(
    Tables.expressions,
    where: '${Tables.exprLesson} = ?',
    whereArgs: [lessonId],
  );
  return rows.map(Expression.fromRow).toList();
}
