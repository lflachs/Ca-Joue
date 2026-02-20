import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/review_queries.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_provider.g.dart';

/// Lesson ID sentinel value used to signal review mode in the exercise system.
///
/// When passed as `lessonId` to `ExerciseNotifier`, the provider loads
/// expressions due for review instead of a specific lesson's expressions.
const String reviewLessonId = '__review__';

/// Returns the count of expressions currently due for review.
///
/// An expression is due when its next review date is in the past
/// or today. Returns 0 when no expressions need review.
@riverpod
Future<int> dueExpressionCount(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  final now = DateTime.now().toIso8601String();
  return ReviewQueries.dueCount(db, now);
}

/// Returns expressions due for review, ordered by most overdue first.
///
/// Joins the expressions table with the progress table to get full
/// [Expression] objects for expressions whose review date has passed.
/// Results are ordered by next review date ascending so the most
/// overdue expressions appear first in the review session.
@riverpod
Future<List<Expression>> dueExpressions(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  final now = DateTime.now().toIso8601String();
  final rows = await ReviewQueries.dueExpressionRows(db, now);
  return rows.map(Expression.fromRow).toList();
}
