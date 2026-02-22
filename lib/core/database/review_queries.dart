import 'package:ca_joue/core/database/tables.dart';
import 'package:sqflite/sqflite.dart';

/// Database queries for spaced repetition review scheduling.
///
/// Encapsulates raw SQL for due-expression lookups, keeping
/// all SQL within `lib/core/database/` per project convention.
abstract final class ReviewQueries {
  /// Returns the count of expressions currently due for review.
  static Future<int> dueCount(Database db, String now) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as c FROM ${Tables.progress} '
      'WHERE ${Tables.progNextReview} IS NOT NULL '
      'AND ${Tables.progNextReview} <= ?',
      [now],
    );
    return result.first['c']! as int;
  }

  /// Returns rows for expressions due for review, prioritized by overdue-ness
  /// then mastery (lower mastery = higher priority).
  static Future<List<Map<String, Object?>>> dueExpressionRows(
    Database db,
    String now,
  ) async {
    return db.rawQuery(
      'SELECT e.* FROM ${Tables.expressions} e '
      'INNER JOIN ${Tables.progress} p '
      'ON e.${Tables.exprId} = p.${Tables.progExpressionId} '
      'WHERE p.${Tables.progNextReview} IS NOT NULL '
      'AND p.${Tables.progNextReview} <= ? '
      'ORDER BY p.${Tables.progNextReview} ASC, '
      'p.${Tables.progRepetitions} ASC, '
      'p.${Tables.progEasinessFactor} ASC',
      [now],
    );
  }
}
