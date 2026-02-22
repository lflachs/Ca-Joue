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
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 1),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Migrations', () {
    group('version 1', () {
      test('creates expressions table', () async {
        await Migrations.runAll(db, 0, 1);

        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [Tables.expressions],
        );
        expect(tables, hasLength(1));
      });

      test('creates progress table', () async {
        await Migrations.runAll(db, 0, 1);

        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [Tables.progress],
        );
        expect(tables, hasLength(1));
      });

      test('creates sessions table', () async {
        await Migrations.runAll(db, 0, 1);

        final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [Tables.sessions],
        );
        expect(tables, hasLength(1));
      });

      test('expressions table has correct columns', () async {
        await Migrations.runAll(db, 0, 1);

        final columns = await db.rawQuery(
          'PRAGMA table_info(${Tables.expressions})',
        );
        final columnNames = columns.map((c) => c['name']! as String).toSet();

        expect(
          columnNames,
          containsAll([
            'id',
            'french',
            'romand',
            'tier',
            'lesson',
            'alternatives',
            'notes',
          ]),
        );
      });

      test('can insert and read an expression', () async {
        await Migrations.runAll(db, 0, 1);

        await db.insert(Tables.expressions, {
          'id': 'expr_test',
          'french': 'Bonjour',
          'romand': 'Adieu',
          'tier': 1,
          'lesson': 'test-lesson',
          'alternatives': '["adieu"]',
          'notes': 'A test note.',
        });

        final rows = await db.query(Tables.expressions);
        expect(rows, hasLength(1));
        expect(rows.first['id'], 'expr_test');
      });
    });

    group('runAll', () {
      test('skips when oldVersion equals newVersion', () async {
        // Should not throw
        await Migrations.runAll(db, 1, 1);
      });

      test('throws for unknown version', () async {
        expect(
          () => Migrations.runAll(db, 0, 99),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
