import 'package:ca_joue/core/spaced_repetition/sm2_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 2, 16);

  group('calculateSm2 — correct answers (quality >= 3)', () {
    test('first correct answer: reps=1, interval=1, EF increases', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 1.0);
      expect(result.easinessFactor, 2.6);
      expect(result.nextReview, now.add(const Duration(days: 1)));
    });

    test('second correct answer: reps=2, interval=6', () {
      final result = calculateSm2(
        easinessFactor: 2.6,
        interval: 1,
        repetitions: 1,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.repetitions, 2);
      expect(result.interval, 6.0);
      expect(result.easinessFactor, 2.7);
      expect(result.nextReview, now.add(const Duration(days: 6)));
    });

    test('third correct answer: reps=3, interval=previous*EF', () {
      final result = calculateSm2(
        easinessFactor: 2.7,
        interval: 6,
        repetitions: 2,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.repetitions, 3);
      expect(result.interval, closeTo(16.2, 0.01));
      expect(result.easinessFactor, closeTo(2.8, 0.01));
      // interval 16.2 → ceil = 17 days
      expect(result.nextReview, now.add(const Duration(days: 17)));
    });

    test('long correct streak: intervals grow monotonically', () {
      var ef = 2.5;
      var interval = 0.0;
      var reps = 0;
      var prevInterval = 0.0;

      for (var i = 0; i < 7; i++) {
        final result = calculateSm2(
          easinessFactor: ef,
          interval: interval,
          repetitions: reps,
          quality: sm2QualityCorrect,
          now: now,
        );

        // After the first two fixed intervals (1, 6), intervals should grow.
        if (i >= 2) {
          expect(
            result.interval,
            greaterThan(prevInterval),
            reason: 'Interval should grow at step $i',
          );
        }

        prevInterval = result.interval;
        ef = result.easinessFactor;
        interval = result.interval;
        reps = result.repetitions;
      }

      // EF should have increased from 2.5 after many correct answers.
      expect(ef, greaterThan(2.5));
    });

    test(
      'quality 3 (barely correct): EF decreases slightly, interval advances',
      () {
        final result = calculateSm2(
          easinessFactor: 2.5,
          interval: 0,
          repetitions: 0,
          quality: 3,
          now: now,
        );

        expect(result.repetitions, 1);
        expect(result.interval, 1.0);
        // q=3: EF + (0.1 - 2*(0.08 + 2*0.02)) = EF + (0.1 - 0.24) = EF - 0.14
        expect(result.easinessFactor, closeTo(2.36, 0.01));
      },
    );

    test('quality 4 (neutral): EF stays exactly the same', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: 4,
        now: now,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 1.0);
      // q=4: EF + (0.1 - 1*(0.08 + 1*0.02)) = EF + (0.1 - 0.1) = EF + 0.0
      expect(result.easinessFactor, 2.5);
    });
  });

  group('calculateSm2 — incorrect answers (quality < 3)', () {
    test('incorrect from fresh state: reps=0, interval=1, EF decreases', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: sm2QualityIncorrect,
        now: now,
      );

      expect(result.repetitions, 0);
      expect(result.interval, 1.0);
      // q=1: EF + (0.1 - 4*(0.08 + 4*0.02)) = EF + (0.1 - 0.64) = EF - 0.54
      expect(result.easinessFactor, closeTo(1.96, 0.01));
      expect(result.nextReview, now.add(const Duration(days: 1)));
    });

    test('incorrect after correct streak: resets reps and interval', () {
      final result = calculateSm2(
        easinessFactor: 2.8,
        interval: 16.2,
        repetitions: 3,
        quality: sm2QualityIncorrect,
        now: now,
      );

      expect(result.repetitions, 0);
      expect(result.interval, 1.0);
      expect(result.easinessFactor, closeTo(2.26, 0.01));
      expect(result.nextReview, now.add(const Duration(days: 1)));
    });

    test('quality 0 (complete blackout): large EF decrease, still >= 1.3', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 6,
        repetitions: 2,
        quality: 0,
        now: now,
      );

      expect(result.repetitions, 0);
      expect(result.interval, 1.0);
      // q=0: EF + (0.1 - 5*(0.08 + 5*0.02)) = EF + (0.1 - 0.9) = EF - 0.8
      expect(result.easinessFactor, closeTo(1.7, 0.01));
    });
  });

  group('calculateSm2 — EF floor', () {
    test('EF never drops below 1.3 after repeated incorrect answers', () {
      var ef = 2.5;
      var interval = 0.0;
      var reps = 0;

      for (var i = 0; i < 10; i++) {
        final result = calculateSm2(
          easinessFactor: ef,
          interval: interval,
          repetitions: reps,
          quality: sm2QualityIncorrect,
          now: now,
        );

        expect(
          result.easinessFactor,
          greaterThanOrEqualTo(1.3),
          reason: 'EF must not drop below 1.3 at iteration $i',
        );

        ef = result.easinessFactor;
        interval = result.interval;
        reps = result.repetitions;
      }
    });

    test('EF floors at 1.3 when already at minimum', () {
      final result = calculateSm2(
        easinessFactor: 1.3,
        interval: 1,
        repetitions: 0,
        quality: sm2QualityIncorrect,
        now: now,
      );

      expect(result.easinessFactor, 1.3);
    });
  });

  group('calculateSm2 — alternating correct/incorrect', () {
    test('alternating pattern produces expected state transitions', () {
      var ef = 2.5;
      var interval = 0.0;
      var reps = 0;

      // Correct answer 1.
      var result = calculateSm2(
        easinessFactor: ef,
        interval: interval,
        repetitions: reps,
        quality: sm2QualityCorrect,
        now: now,
      );
      expect(result.repetitions, 1);
      expect(result.interval, 1.0);
      ef = result.easinessFactor;
      interval = result.interval;
      reps = result.repetitions;

      // Incorrect answer — resets.
      result = calculateSm2(
        easinessFactor: ef,
        interval: interval,
        repetitions: reps,
        quality: sm2QualityIncorrect,
        now: now,
      );
      expect(result.repetitions, 0);
      expect(result.interval, 1.0);
      ef = result.easinessFactor;
      interval = result.interval;
      reps = result.repetitions;

      // Correct again — starts from reps=0.
      result = calculateSm2(
        easinessFactor: ef,
        interval: interval,
        repetitions: reps,
        quality: sm2QualityCorrect,
        now: now,
      );
      expect(result.repetitions, 1);
      expect(result.interval, 1.0);
    });
  });

  group('calculateSm2 — nextReview date', () {
    test('nextReview is now + interval days (ceiling)', () {
      final result = calculateSm2(
        easinessFactor: 2.7,
        interval: 6,
        repetitions: 2,
        quality: sm2QualityCorrect,
        now: now,
      );

      // interval = 6 * 2.7 = 16.2, ceil = 17
      expect(result.nextReview, DateTime(2026, 3, 5));
    });

    test('nextReview is now + 1 day for first correct', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 0,
        repetitions: 0,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.nextReview, DateTime(2026, 2, 17));
    });

    test('nextReview is now + 1 day for incorrect', () {
      final result = calculateSm2(
        easinessFactor: 2.5,
        interval: 6,
        repetitions: 2,
        quality: sm2QualityIncorrect,
        now: now,
      );

      expect(result.nextReview, DateTime(2026, 2, 17));
    });
  });

  group('calculateSm2 — default initial values', () {
    test(
      'matches Progress.initial() defaults (EF=2.5, interval=0, reps=0)',
      () {
        final result = calculateSm2(
          easinessFactor: 2.5,
          interval: 0,
          repetitions: 0,
          quality: sm2QualityCorrect,
          now: now,
        );

        expect(result.repetitions, 1);
        expect(result.interval, 1.0);
        expect(result.easinessFactor, 2.6);
      },
    );
  });

  group('calculateSm2 — quality constants', () {
    test('sm2QualityCorrect is 5', () {
      expect(sm2QualityCorrect, 5);
    });

    test('sm2QualityIncorrect is 1', () {
      expect(sm2QualityIncorrect, 1);
    });
  });

  group('calculateSm2 — DB integration contract', () {
    test('accepts integer-typed values cast via num.toDouble()', () {
      // Simulates sqflite returning int for REAL columns (e.g., interval=0).
      final simulatedRow = <String, dynamic>{
        'easiness_factor': 2.5, // double from sqflite
        'interval': 0, // int — sqflite may return int for REAL default 0
        'repetitions': 0, // int — always int from INTEGER column
      };

      final ef = (simulatedRow['easiness_factor']! as num).toDouble();
      final interval = (simulatedRow['interval']! as num).toDouble();
      final reps = simulatedRow['repetitions']! as int;

      final result = calculateSm2(
        easinessFactor: ef,
        interval: interval,
        repetitions: reps,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.repetitions, 1);
      expect(result.interval, 1.0);
      expect(result.easinessFactor, 2.6);
    });

    test('handles EF at exact integer value (3.0 after streak)', () {
      // After 5 consecutive correct answers, EF reaches 3.0 — an exact int.
      // sqflite might return this as int 3 instead of double 3.0.
      final simulatedRow = <String, dynamic>{
        'easiness_factor': 3, // int — EF=3.0 stored as integer by SQLite
        'interval': 45, // int — exact integer interval
        'repetitions': 5,
      };

      final ef = (simulatedRow['easiness_factor']! as num).toDouble();
      final interval = (simulatedRow['interval']! as num).toDouble();
      final reps = simulatedRow['repetitions']! as int;

      final result = calculateSm2(
        easinessFactor: ef,
        interval: interval,
        repetitions: reps,
        quality: sm2QualityCorrect,
        now: now,
      );

      expect(result.repetitions, 6);
      // interval = oldInterval * oldEF = 45 * 3.0 = 135.0
      expect(result.interval, closeTo(135.0, 0.01));
      expect(result.easinessFactor, closeTo(3.1, 0.01));
    });
  });
}
