import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Replicates the query logic from `totalCompletedExpressions` provider.
Future<int> totalCompletedExpressions(Database db) async {
  final result = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM ${Tables.progress}',
  );
  return result.first['c']! as int;
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

    // Insert test expressions across two tiers.
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
    await db.insert(Tables.expressions, {
      Tables.exprId: 'expr_b1',
      Tables.exprFrench: 'French B1',
      Tables.exprRomand: 'Romand B1',
      Tables.exprTier: 2,
      Tables.exprLesson: 'lesson-b',
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

  group('totalCompletedExpressions', () {
    test('returns 0 when no progress rows exist', () async {
      final count = await totalCompletedExpressions(db);
      expect(count, 0);
    });

    test('returns correct count after inserting progress rows', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_a2');

      final count = await totalCompletedExpressions(db);
      expect(count, 2);
    });

    test('counts distinct expressions across tiers', () async {
      await insertProgress('expr_a1');
      await insertProgress('expr_b1');

      final count = await totalCompletedExpressions(db);
      expect(count, 2);
    });
  });
}
