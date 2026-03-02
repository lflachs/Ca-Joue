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

/// Lesson ID prefix sentinel used to signal practice mode.
///
/// When a `lessonId` starts with this prefix, the exercise system loads
/// all expressions for the embedded tier number instead of a specific lesson.
/// Example: `'__practice_tier_2__'` loads all tier-2 expressions.
const String practiceLessonIdPrefix = '__practice_tier_';

/// Lesson ID sentinel for "practice all seen expressions" mode.
const String practiceAllLessonId = '__practice_all__';

/// Returns `true` if [lessonId] represents a free practice session.
bool isPracticeMode(String lessonId) =>
    lessonId.startsWith(practiceLessonIdPrefix) ||
    lessonId == practiceAllLessonId;

/// Extracts the tier number from a practice sentinel string.
///
/// Returns the tier number (e.g. 2 from `'__practice_tier_2__'`),
/// or `null` if the string is not a valid practice sentinel.
int? practiceTierNum(String lessonId) {
  if (!isPracticeMode(lessonId)) return null;
  final stripped = lessonId.substring(practiceLessonIdPrefix.length);
  final numStr = stripped.replaceAll('_', '');
  return int.tryParse(numStr);
}

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

/// Returns all expressions the user has encountered so far.
@riverpod
Future<List<Expression>> seenExpressions(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  final rows = await ReviewQueries.seenExpressionRows(db);
  return rows.map(Expression.fromRow).toList();
}
