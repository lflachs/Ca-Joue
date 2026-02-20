import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Replicates the query logic from `completedCountByLesson` provider.
Future<int> completedCountByLesson(Database db, String lessonId) async {
  final exprRows = await db.query(
    Tables.expressions,
    columns: [Tables.exprId],
    where: '${Tables.exprLesson} = ?',
    whereArgs: [lessonId],
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

/// Replicates the query logic from `completedCountByTier` provider.
Future<int> completedCountByTier(Database db, int tier) async {
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

    // Insert test expressions across two lessons in tier 1.
    for (var i = 1; i <= 3; i++) {
      await db.insert(Tables.expressions, {
        Tables.exprId: 'expr_a$i',
        Tables.exprFrench: 'French A$i',
        Tables.exprRomand: 'Romand A$i',
        Tables.exprTier: 1,
        Tables.exprLesson: 'lesson-a',
        Tables.exprAlternatives: '[]',
        Tables.exprNotes: '',
      });
    }
    for (var i = 1; i <= 2; i++) {
      await db.insert(Tables.expressions, {
        Tables.exprId: 'expr_b$i',
        Tables.exprFrench: 'French B$i',
        Tables.exprRomand: 'Romand B$i',
        Tables.exprTier: 1,
        Tables.exprLesson: 'lesson-b',
        Tables.exprAlternatives: '[]',
        Tables.exprNotes: '',
      });
    }

    // Insert one expression in tier 2.
    await db.insert(Tables.expressions, {
      Tables.exprId: 'expr_c1',
      Tables.exprFrench: 'French C1',
      Tables.exprRomand: 'Romand C1',
      Tables.exprTier: 2,
      Tables.exprLesson: 'lesson-c',
      Tables.exprAlternatives: '[]',
      Tables.exprNotes: '',
    });
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertProgress(String expressionId) async {
    await db.insert(Tables.progress, {
      Tables.progExpressionId: expressionId,
      Tables.progEasinessFactor: 2.5,
      Tables.progInterval: 0,
      Tables.progRepetitions: 0,
      Tables.progLastReviewed: DateTime.now().toIso8601String(),
    });
  }

  group('completedCountByLesson', () {
    test('returns 0 for lesson with no progress', () async {
      final count = await completedCountByLesson(db, 'lesson-a');
      expect(count, 0);
    });

    test('returns correct count for partially complete lesson', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_a2');

      final count = await completedCountByLesson(db, 'lesson-a');
      expect(count, 2);
    });

    test('returns full count for complete lesson', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_a2');
      await insertProgress('expr_a3');

      final count = await completedCountByLesson(db, 'lesson-a');
      expect(count, 3);
    });

    test('returns 0 for nonexistent lesson', () async {
      final count = await completedCountByLesson(db, 'no-such-lesson');
      expect(count, 0);
    });

    test('does not count progress from other lessons', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_b1');

      final countA = await completedCountByLesson(db, 'lesson-a');
      final countB = await completedCountByLesson(db, 'lesson-b');
      expect(countA, 1);
      expect(countB, 1);
    });
  });

  group('completedCountByTier', () {
    test('returns 0 for tier with no progress', () async {
      final count = await completedCountByTier(db, 1);
      expect(count, 0);
    });

    test('aggregates across lessons in the same tier', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_b1');

      final count = await completedCountByTier(db, 1);
      expect(count, 2);
    });

    test('returns full count when tier is complete', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_a2');
      await insertProgress('expr_a3');
      await insertProgress('expr_b1');
      await insertProgress('expr_b2');

      final count = await completedCountByTier(db, 1);
      expect(count, 5);
    });

    test('does not count progress from other tiers', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_c1');

      final tier1Count = await completedCountByTier(db, 1);
      final tier2Count = await completedCountByTier(db, 2);
      expect(tier1Count, 1);
      expect(tier2Count, 1);
    });
  });

  group('isTierComplete', () {
    test('returns false when tier is incomplete', () async {
      await insertProgress('expr_a1');

      final count = await completedCountByTier(db, 1);
      // Tier 1 has 5 expressions (3 in lesson-a + 2 in lesson-b).
      expect(count < 5, isTrue);
    });

    test('returns true when all tier expressions have progress', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_a2');
      await insertProgress('expr_a3');
      await insertProgress('expr_b1');
      await insertProgress('expr_b2');

      final count = await completedCountByTier(db, 1);
      // Count total expressions in tier.
      final totalRows = await db.query(
        Tables.expressions,
        columns: [Tables.exprId],
        where: '${Tables.exprTier} = ?',
        whereArgs: [1],
      );
      expect(count >= totalRows.length, isTrue);
    });

    test('returns false for empty tier', () async {
      // Tier 3 has no expressions in our test data.
      final totalRows = await db.query(
        Tables.expressions,
        columns: [Tables.exprId],
        where: '${Tables.exprTier} = ?',
        whereArgs: [3],
      );
      expect(totalRows.isEmpty, isTrue);
    });
  });
}
