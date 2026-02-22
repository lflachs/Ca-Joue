import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/review_queries.dart';
import 'package:ca_joue/core/database/seed_data.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Delegates to the production [ReviewQueries.dueCount] implementation.
Future<int> queryDueCount(Database db, String now) =>
    ReviewQueries.dueCount(db, now);

/// Delegates to production `ReviewQueries.dueExpressionRows`.
Future<List<Expression>> queryDueExpressions(
  Database db,
  String now,
) async {
  final rows = await ReviewQueries.dueExpressionRows(db, now);
  return rows.map(Expression.fromRow).toList();
}

void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
    await Migrations.runAll(db, 0, 1);
    await SeedData.seedIfNeeded(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('dueExpressionCount query', () {
    test('returns 0 when no progress rows exist', () async {
      final count = await queryDueCount(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );
      expect(count, 0);
    });

    test('returns 0 when progress rows have null next_review', () async {
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 0,
        Tables.progRepetitions: 0,
        // next_review is null — expression not yet due.
      });

      final count = await queryDueCount(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );
      expect(count, 0);
    });

    test('returns correct count when some expressions are overdue', () async {
      // Insert two overdue expressions.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 14).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 15).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 14).toIso8601String(),
      });

      final count = await queryDueCount(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );
      expect(count, 2);
    });

    test('excludes expressions with future next_review', () async {
      // One overdue, one future.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 14).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 6,
        Tables.progRepetitions: 2,
        Tables.progNextReview: DateTime(2026, 2, 20).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 14).toIso8601String(),
      });

      final count = await queryDueCount(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );
      expect(count, 1);
    });

    test('includes expression with next_review exactly equal to now', () async {
      final now = DateTime(2026, 2, 16);
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: now.toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 15).toIso8601String(),
      });

      final count = await queryDueCount(db, now.toIso8601String());
      expect(count, 1);
    });
  });

  group('dueExpressions query', () {
    test('returns empty list when nothing is due', () async {
      final expressions = await queryDueExpressions(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );
      expect(expressions, isEmpty);
    });

    test('returns expressions ordered by next_review ASC', () async {
      // Insert three overdue expressions with different review dates.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_003',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 13).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 12).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 10).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 9).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 15).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 14).toIso8601String(),
      });

      final expressions = await queryDueExpressions(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );

      expect(expressions.length, 3);
      // Most overdue first (Feb 10), then Feb 13, then Feb 15.
      expect(expressions[0].id, 'expr_001');
      expect(expressions[1].id, 'expr_003');
      expect(expressions[2].id, 'expr_002');
    });

    test('includes expressions from all tiers', () async {
      // Get expression IDs from different tiers via seed data.
      final tier1 = await db.query(
        Tables.expressions,
        where: '${Tables.exprTier} = ?',
        whereArgs: [1],
        limit: 1,
      );
      final tier2 = await db.query(
        Tables.expressions,
        where: '${Tables.exprTier} = ?',
        whereArgs: [2],
        limit: 1,
      );

      final id1 = tier1.first[Tables.exprId]! as String;
      final id2 = tier2.first[Tables.exprId]! as String;

      // Mark both as overdue.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: id1,
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 14).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: id2,
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 15).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 14).toIso8601String(),
      });

      final expressions = await queryDueExpressions(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );

      expect(expressions.length, 2);

      final tiers = expressions.map((e) => e.tier).toSet();
      expect(tiers, contains(1));
      expect(tiers, contains(2));
    });

    test('excludes future reviews from result list', () async {
      // One overdue, one future.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: DateTime(2026, 2, 14).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 6,
        Tables.progRepetitions: 2,
        Tables.progNextReview: DateTime(2026, 2, 22).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 16).toIso8601String(),
      });

      final expressions = await queryDueExpressions(
        db,
        DateTime(2026, 2, 16).toIso8601String(),
      );

      expect(expressions.length, 1);
      expect(expressions.first.id, 'expr_001');
    });
  });

  group('mastery-weighted ordering', () {
    test('same next_review: fewer repetitions appears first', () async {
      final now = DateTime(2026, 2, 16);
      final sameReview = DateTime(2026, 2, 14).toIso8601String();

      // expr_001: 3 reps (higher mastery).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 3,
        Tables.progNextReview: sameReview,
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      // expr_002: 1 rep (lower mastery — should appear first).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 1,
        Tables.progNextReview: sameReview,
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });

      final expressions = await queryDueExpressions(db, now.toIso8601String());

      expect(expressions.length, 2);
      expect(expressions[0].id, 'expr_002'); // 1 rep first
      expect(expressions[1].id, 'expr_001'); // 3 reps second
    });

    test('same next_review and reps: lower EF appears first', () async {
      final now = DateTime(2026, 2, 16);
      final sameReview = DateTime(2026, 2, 14).toIso8601String();

      // expr_001: high EF (easier).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 2,
        Tables.progNextReview: sameReview,
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });
      // expr_002: low EF (struggling — should appear first).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 1.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 2,
        Tables.progNextReview: sameReview,
        Tables.progLastReviewed: DateTime(2026, 2, 13).toIso8601String(),
      });

      final expressions = await queryDueExpressions(db, now.toIso8601String());

      expect(expressions.length, 2);
      expect(expressions[0].id, 'expr_002'); // EF 1.5 first
      expect(expressions[1].id, 'expr_001'); // EF 2.5 second
    });

    test('overdue-ness still takes priority over mastery weighting', () async {
      final now = DateTime(2026, 2, 16);

      // expr_001: very overdue (Feb 10), high mastery (5 reps).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 1,
        Tables.progRepetitions: 5,
        Tables.progNextReview: DateTime(2026, 2, 10).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 9).toIso8601String(),
      });
      // expr_002: slightly overdue (Feb 15), low mastery (0 reps).
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_002',
        Tables.progEasinessFactor: 1.3,
        Tables.progInterval: 1,
        Tables.progRepetitions: 0,
        Tables.progNextReview: DateTime(2026, 2, 15).toIso8601String(),
        Tables.progLastReviewed: DateTime(2026, 2, 14).toIso8601String(),
      });

      final expressions = await queryDueExpressions(db, now.toIso8601String());

      expect(expressions.length, 2);
      // Most overdue first, even though it has higher mastery.
      expect(expressions[0].id, 'expr_001');
      expect(expressions[1].id, 'expr_002');
    });
  });

  group('reviewLessonId constant', () {
    test('has the expected sentinel value', () {
      expect(reviewLessonId, '__review__');
    });
  });
}
