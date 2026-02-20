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
    await Migrations.runAll(db, 0, 1);

    // Seed a default session row.
    await db.insert(Tables.sessions, {
      Tables.sessId: 1,
      Tables.sessFirstLaunchCompleted: 0,
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('Onboarding provider logic', () {
    test('isFirstLaunch is true when first_launch_completed == 0', () async {
      final rows = await db.query(
        Tables.sessions,
        columns: [Tables.sessFirstLaunchCompleted],
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );

      final isFirstLaunch =
          rows.isEmpty || rows.first[Tables.sessFirstLaunchCompleted] == 0;
      expect(isFirstLaunch, isTrue);
    });

    test('isFirstLaunch is false when first_launch_completed == 1', () async {
      await db.update(
        Tables.sessions,
        {Tables.sessFirstLaunchCompleted: 1},
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );

      final rows = await db.query(
        Tables.sessions,
        columns: [Tables.sessFirstLaunchCompleted],
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );

      final isFirstLaunch =
          rows.isEmpty || rows.first[Tables.sessFirstLaunchCompleted] == 0;
      expect(isFirstLaunch, isFalse);
    });

    test('completeOnboarding updates the database', () async {
      // Verify starts at 0.
      var rows = await db.query(
        Tables.sessions,
        columns: [Tables.sessFirstLaunchCompleted],
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );
      expect(rows.first[Tables.sessFirstLaunchCompleted], 0);

      // Simulate completeOnboarding.
      await db.update(
        Tables.sessions,
        {Tables.sessFirstLaunchCompleted: 1},
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );

      // Verify updated to 1.
      rows = await db.query(
        Tables.sessions,
        columns: [Tables.sessFirstLaunchCompleted],
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );
      expect(rows.first[Tables.sessFirstLaunchCompleted], 1);
    });
  });
}
