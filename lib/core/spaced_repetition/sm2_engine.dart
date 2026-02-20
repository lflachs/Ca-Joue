/// SM-2 spaced repetition algorithm by Piotr Wozniak (1987).
///
/// Pure function implementation with no side effects or dependencies.
/// See: https://super-memory.com/english/ol/sm2.htm
library;

/// Result of an SM-2 calculation.
typedef Sm2Result = ({
  double easinessFactor,
  double interval,
  int repetitions,
  DateTime nextReview,
});

/// Quality constant for a correct answer (perfect recall).
const int sm2QualityCorrect = 5;

/// Quality constant for an incorrect answer (failed recall).
const int sm2QualityIncorrect = 1;

/// Calculates the next SM-2 spaced repetition state.
///
/// Pure function — no side effects, no dependencies beyond `dart:core`.
///
/// [easinessFactor] is the current EF (default 2.5 for new expressions).
/// [interval] is the current interval in days (0 for never-reviewed).
/// [repetitions] is the current consecutive-correct count.
/// [quality] ranges from 0 (complete blackout) to 5 (perfect recall).
///   Quality >= 3 means successful recall; < 3 means failed recall.
/// [now] is the current date/time for computing the next review date.
Sm2Result calculateSm2({
  required double easinessFactor,
  required double interval,
  required int repetitions,
  required int quality,
  required DateTime now,
}) {
  assert(quality >= 0 && quality <= 5, 'Quality must be 0-5');

  // Step 1: Update repetitions and interval.
  int newReps;
  double newInterval;

  if (quality >= 3) {
    // Successful recall.
    newReps = repetitions + 1;
    if (newReps == 1) {
      newInterval = 1;
    } else if (newReps == 2) {
      newInterval = 6;
    } else {
      newInterval = interval * easinessFactor;
    }
  } else {
    // Failed recall — reset.
    newReps = 0;
    newInterval = 1;
  }

  // Step 2: Update easiness factor.
  final qDiff = 5 - quality;
  final newEf = easinessFactor + (0.1 - qDiff * (0.08 + qDiff * 0.02));
  final clampedEf = newEf < 1.3 ? 1.3 : newEf;

  // Step 3: Calculate next review date.
  final nextReview = now.add(Duration(days: newInterval.ceil()));

  return (
    easinessFactor: clampedEf,
    interval: newInterval,
    repetitions: newReps,
    nextReview: nextReview,
  );
}
