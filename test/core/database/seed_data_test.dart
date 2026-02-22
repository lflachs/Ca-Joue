import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/seed_data.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' show Sqflite;
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
  });

  tearDown(() async {
    await db.close();
  });

  group('SeedData', () {
    test('seeds expressions from JSON asset', () async {
      // Load the actual asset for testing
      final jsonString = await rootBundle.loadString(
        'assets/data/expressions.json',
      );
      expect(jsonString, isNotEmpty);

      await SeedData.seedIfNeeded(db);

      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${Tables.expressions}'),
      );
      expect(count, 253);
    });

    test('seeds initial session row', () async {
      await SeedData.seedIfNeeded(db);

      final sessions = await db.query(Tables.sessions);
      expect(sessions, hasLength(1));
      expect(sessions.first[Tables.sessId], 1);
      expect(sessions.first[Tables.sessStreakCount], 0);
      expect(sessions.first[Tables.sessTotalPoints], 0);
      expect(sessions.first[Tables.sessFirstLaunchCompleted], 0);
    });

    test('does not re-seed on subsequent calls', () async {
      await SeedData.seedIfNeeded(db);
      await SeedData.seedIfNeeded(db);

      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${Tables.expressions}'),
      );
      expect(count, 253);
    });

    test('expressions have all required fields', () async {
      await SeedData.seedIfNeeded(db);

      final rows = await db.query(Tables.expressions, limit: 1);
      expect(rows, hasLength(1));

      final row = rows.first;
      expect(row['id'], isNotNull);
      expect(row['french'], isNotNull);
      expect(row['romand'], isNotNull);
      expect(row['tier'], isNotNull);
      expect(row['lesson'], isNotNull);
      expect(row['alternatives'], isNotNull);
    });

    test('all four tiers are represented', () async {
      await SeedData.seedIfNeeded(db);

      for (var tier = 1; tier <= 4; tier++) {
        final count = Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${Tables.expressions} WHERE tier = ?',
            [tier],
          ),
        );
        expect(count, greaterThan(0), reason: 'Tier $tier should have data');
      }
    });
  });
}
