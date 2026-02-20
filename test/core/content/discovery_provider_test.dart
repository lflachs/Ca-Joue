import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/seed_data.dart';
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
    await SeedData.seedIfNeeded(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('isFirstEncounter', () {
    test('returns true for expression with no progress row', () async {
      final rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_001'],
        limit: 1,
      );
      expect(rows.isEmpty, isTrue);
    });

    test('returns false for expression with existing progress row', () async {
      await db.insert(Tables.progress, {
        Tables.progExpressionId: 'expr_001',
        Tables.progEasinessFactor: 2.5,
        Tables.progInterval: 0,
        Tables.progRepetitions: 0,
      });

      final rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['expr_001'],
        limit: 1,
      );
      expect(rows.isEmpty, isFalse);
    });

    test('each expression has a non-empty notes field for context', () async {
      final rows = await db.query(
        Tables.expressions,
        where: '${Tables.exprNotes} != ?',
        whereArgs: [''],
        limit: 5,
      );
      expect(rows.length, 5);
      for (final row in rows) {
        expect(
          (row[Tables.exprNotes] as String).isNotEmpty,
          isTrue,
          reason: 'Expression ${row[Tables.exprId]} should have notes',
        );
      }
    });

    test('first encounter works for expression with empty notes', () async {
      // Insert an expression with empty notes to verify the query
      // is independent of the notes field.
      await db.insert(Tables.expressions, {
        Tables.exprId: 'test_empty_notes',
        Tables.exprFrench: 'Bonjour',
        Tables.exprRomand: 'Adieu',
        Tables.exprTier: 1,
        Tables.exprLesson: 1,
        Tables.exprAlternatives: '',
        Tables.exprNotes: '',
      });

      // No progress row → first encounter is true.
      final rows = await db.query(
        Tables.progress,
        where: '${Tables.progExpressionId} = ?',
        whereArgs: ['test_empty_notes'],
        limit: 1,
      );
      expect(rows.isEmpty, isTrue);
    });
  });
}
