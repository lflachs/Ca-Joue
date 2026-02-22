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

  group('distractor generation', () {
    test('tier has at least 4 expressions for distractor pool', () async {
      // Each tier must have enough expressions so 3 distractors can
      // always be drawn (excluding the current expression).
      for (var tier = 1; tier <= 4; tier++) {
        final rows = await db.query(
          Tables.expressions,
          where: '${Tables.exprTier} = ?',
          whereArgs: [tier],
        );
        expect(
          rows.length,
          greaterThanOrEqualTo(4),
          reason: 'Tier $tier must have >= 4 expressions',
        );
      }
    });

    test('same-tier expressions have distinct romand values', () async {
      for (var tier = 1; tier <= 4; tier++) {
        final rows = await db.query(
          Tables.expressions,
          columns: [Tables.exprRomand],
          where: '${Tables.exprTier} = ?',
          whereArgs: [tier],
        );
        final romands = rows.map((r) => r[Tables.exprRomand]! as String);
        final unique = romands.toSet();
        expect(
          unique.length,
          romands.length,
          reason: 'Tier $tier should have no duplicate romand values',
        );
      }
    });

    test('expressions by lesson returns correct group', () async {
      final rows = await db.query(
        Tables.expressions,
        where: '${Tables.exprLesson} = ?',
        whereArgs: ['everyday-greetings'],
      );
      expect(rows, isNotEmpty);
      for (final row in rows) {
        expect(row[Tables.exprLesson], 'everyday-greetings');
      }
    });

    test('filtering out current expression leaves candidates', () async {
      final rows = await db.query(
        Tables.expressions,
        where: '${Tables.exprTier} = ?',
        whereArgs: [1],
      );
      final first = rows.first;
      final candidates = rows.where(
        (r) => r[Tables.exprId] != first[Tables.exprId],
      );
      expect(candidates.length, greaterThanOrEqualTo(3));
    });
  });
}
