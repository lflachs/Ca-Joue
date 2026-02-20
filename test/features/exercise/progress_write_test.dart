import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

    // Insert a test expression for foreign key.
    await db.insert(Tables.expressions, {
      Tables.exprId: 'expr_progress_test',
      Tables.exprFrench: 'Bonjour',
      Tables.exprRomand: 'Adieu',
      Tables.exprTier: 1,
      Tables.exprLesson: 'everyday-greetings',
      Tables.exprAlternatives: '[]',
      Tables.exprNotes: '',
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('progress write', () {
    test('inserts progress row with default SM-2 values', () async {
      await db.insert(
        Tables.progress,
        {
          Tables.progExpressionId: 'expr_progress_test',
          Tables.progEasinessFactor: 2.5,
          Tables.progInterval: 0,
          Tables.progRepetitions: 0,
          Tables.progLastReviewed: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_progress_test'],
      );
      expect(rows, hasLength(1));
      expect(rows.first[Tables.progEasinessFactor], 2.5);
      expect(rows.first[Tables.progInterval], 0);
      expect(rows.first[Tables.progRepetitions], 0);
      expect(rows.first[Tables.progLastReviewed], isNotNull);
    });

    test('upsert replaces existing progress row', () async {
      final firstDate = DateTime(2026).toIso8601String();
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_progress_test',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 0,
        Tables.progRepetitions: 0,
        Tables.progLastReviewed: firstDate,
      });

      final secondDate = DateTime(2026, 2, 16).toIso8601String();
      await db.insert(
        Tables.progress,
        {
          Tables.progExpressionId: 'expr_progress_test',
          Tables.progEasinessFactor: 2.5,
          Tables.progInterval: 0,
          Tables.progRepetitions: 0,
          Tables.progLastReviewed: secondDate,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_progress_test'],
      );
      expect(rows, hasLength(1));
      expect(rows.first[Tables.progLastReviewed], secondDate);
    });

    test('progress row makes expression no longer first encounter', () async {
      // Before insert: no progress row.
      var rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_progress_test'],
        limit: 1,
      );
      expect(rows.isEmpty, isTrue);

      // Insert progress.
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_progress_test',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 0,
        Tables.progRepetitions: 0,
        Tables.progLastReviewed: DateTime.now().toIso8601String(),
      });

      // After insert: progress row exists.
      rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_progress_test'],
        limit: 1,
      );
      expect(rows.isEmpty, isFalse);
    });
  });
}
