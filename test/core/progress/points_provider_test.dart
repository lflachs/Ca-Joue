import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Replicates the query logic from `totalPoints` provider.
Future<int> totalPoints(Database db) async {
  final rows = await db.query(
    Tables.sessions,
    columns: [Tables.sessTotalPoints],
    where: '${Tables.sessId} = ?',
    whereArgs: [1],
  );

  if (rows.isEmpty) return 0;
  return rows.first[Tables.sessTotalPoints]! as int;
}

/// Replicates the SQL used by `_awardPoint()` in ExerciseNotifier.
Future<void> awardPoint(Database db) async {
  await db.rawUpdate(
    'UPDATE ${Tables.sessions} '
    'SET ${Tables.sessTotalPoints} = ${Tables.sessTotalPoints} + 1 '
    'WHERE ${Tables.sessId} = 1',
  );
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

    // Seed the sessions singleton row (replicates SeedData).
    await db.insert(Tables.sessions, {
      Tables.sessId: 1,
      Tables.sessStreakCount: 0,
      Tables.sessStreakLastDate: null,
      Tables.sessTotalPoints: 0,
      Tables.sessCurrentLessonPosition: null,
      Tables.sessFirstLaunchCompleted: 0,
    });
  });

  tearDown(() async {
    await db.close();
  });

  group('totalPoints', () {
    test('returns 0 when no points have been awarded', () async {
      final points = await totalPoints(db);
      expect(points, 0);
    });

    test('increments after awarding points', () async {
      await awardPoint(db);
      await awardPoint(db);
      await awardPoint(db);

      final points = await totalPoints(db);
      expect(points, 3);
    });

    test('does not change when no award is called', () async {
      await awardPoint(db);
      final before = await totalPoints(db);

      // Simulate an incorrect answer: no awardPoint call.
      final after = await totalPoints(db);

      expect(before, 1);
      expect(after, 1);
    });

    test('persists across separate reads', () async {
      await awardPoint(db);
      final first = await totalPoints(db);

      await awardPoint(db);
      final second = await totalPoints(db);

      expect(first, 1);
      expect(second, 2);
    });
  });
}
