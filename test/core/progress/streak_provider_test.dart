import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/core/progress/streak_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('calculateStreak (pure function)', () {
    test('first session ever returns count 1', () {
      final result = calculateStreak(
        currentCount: 0,
        lastDate: null,
        now: DateTime(2026, 2, 23),
      );

      expect(result.newCount, 1);
      expect(result.newDate, '2026-02-23');
    });

    test('same day does not change count', () {
      final result = calculateStreak(
        currentCount: 5,
        lastDate: '2026-02-23',
        now: DateTime(2026, 2, 23, 18, 30),
      );

      expect(result.newCount, 5);
      expect(result.newDate, '2026-02-23');
    });

    test('consecutive day increments count', () {
      final result = calculateStreak(
        currentCount: 3,
        lastDate: '2026-02-22',
        now: DateTime(2026, 2, 23),
      );

      expect(result.newCount, 4);
      expect(result.newDate, '2026-02-23');
    });

    test('gap of 2 days resets count to 1', () {
      final result = calculateStreak(
        currentCount: 10,
        lastDate: '2026-02-20',
        now: DateTime(2026, 2, 23),
      );

      expect(result.newCount, 1);
      expect(result.newDate, '2026-02-23');
    });

    test('gap of 3+ days resets count to 1', () {
      final result = calculateStreak(
        currentCount: 50,
        lastDate: '2026-01-01',
        now: DateTime(2026, 2, 23),
      );

      expect(result.newCount, 1);
      expect(result.newDate, '2026-02-23');
    });

    test('multi-day streak build-up', () {
      var count = 0;
      String? lastDate;

      // Day 1: first session.
      var r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 20),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 1);

      // Day 2: consecutive.
      r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 21),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 2);

      // Day 2 again: same day, no change.
      r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 21, 22, 0),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 2);

      // Day 3: consecutive.
      r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 22),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 3);

      // Day 4: consecutive.
      r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 23),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 4);

      // Day 6: gap — reset.
      r = calculateStreak(
        currentCount: count,
        lastDate: lastDate,
        now: DateTime(2026, 2, 25),
      );
      count = r.newCount;
      lastDate = r.newDate;
      expect(count, 1);
    });
  });

  group('streak DB integration', () {
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

    Future<({int count, String? lastDate})> readStreak() async {
      final rows = await db.query(
        Tables.sessions,
        columns: [Tables.sessStreakCount, Tables.sessStreakLastDate],
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );
      if (rows.isEmpty) return (count: 0, lastDate: null);
      return (
        count: rows.first[Tables.sessStreakCount]! as int,
        lastDate: rows.first[Tables.sessStreakLastDate] as String?,
      );
    }

    Future<void> writeStreak(int count, String date) async {
      await db.update(
        Tables.sessions,
        {
          Tables.sessStreakCount: count,
          Tables.sessStreakLastDate: date,
        },
        where: '${Tables.sessId} = ?',
        whereArgs: [1],
      );
    }

    test('defaults to count 0 and null lastDate', () async {
      final streak = await readStreak();
      expect(streak.count, 0);
      expect(streak.lastDate, isNull);
    });

    test('records first session correctly', () async {
      final result = calculateStreak(
        currentCount: 0,
        lastDate: null,
        now: DateTime(2026, 2, 23),
      );
      await writeStreak(result.newCount, result.newDate);

      final streak = await readStreak();
      expect(streak.count, 1);
      expect(streak.lastDate, '2026-02-23');
    });

    test('same-day session does not double-count', () async {
      await writeStreak(1, '2026-02-23');

      final result = calculateStreak(
        currentCount: 1,
        lastDate: '2026-02-23',
        now: DateTime(2026, 2, 23, 20, 0),
      );
      await writeStreak(result.newCount, result.newDate);

      final streak = await readStreak();
      expect(streak.count, 1);
    });

    test('persists across separate reads', () async {
      await writeStreak(3, '2026-02-22');

      final first = await readStreak();
      expect(first.count, 3);

      final result = calculateStreak(
        currentCount: first.count,
        lastDate: first.lastDate,
        now: DateTime(2026, 2, 23),
      );
      await writeStreak(result.newCount, result.newDate);

      final second = await readStreak();
      expect(second.count, 4);
      expect(second.lastDate, '2026-02-23');
    });
  });
}
