import 'dart:math';

import 'package:ca_joue/core/spaced_repetition/mastery_calculator.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [Random] that always returns a fixed value from [nextInt].
class _FixedRandom implements Random {
  _FixedRandom(this._value);
  final int _value;

  @override
  int nextInt(int max) => _value.clamp(0, max - 1);

  @override
  double nextDouble() => _value / 100;

  @override
  bool nextBool() => false;
}

void main() {
  group('exerciseTypeForRepetitions', () {
    group('0 reps — always MC', () {
      test('returns MC at roll 0', () {
        expect(
          exerciseTypeForRepetitions(0, random: _FixedRandom(0)),
          ExerciseType.multipleChoice,
        );
      });

      test('returns MC at roll 99', () {
        expect(
          exerciseTypeForRepetitions(0, random: _FixedRandom(99)),
          ExerciseType.multipleChoice,
        );
      });
    });

    group('1 rep — MC/BlankMC 60/40', () {
      test('returns MC at roll 0', () {
        expect(
          exerciseTypeForRepetitions(1, random: _FixedRandom(0)),
          ExerciseType.multipleChoice,
        );
      });

      test('returns MC at roll 59', () {
        expect(
          exerciseTypeForRepetitions(1, random: _FixedRandom(59)),
          ExerciseType.multipleChoice,
        );
      });

      test('returns BlankMC at roll 60', () {
        expect(
          exerciseTypeForRepetitions(1, random: _FixedRandom(60)),
          ExerciseType.blankMultipleChoice,
        );
      });

      test('returns BlankMC at roll 99', () {
        expect(
          exerciseTypeForRepetitions(1, random: _FixedRandom(99)),
          ExerciseType.blankMultipleChoice,
        );
      });
    });

    group('2 reps — MC/BlankMC 15/85', () {
      test('returns MC at roll 0', () {
        expect(
          exerciseTypeForRepetitions(2, random: _FixedRandom(0)),
          ExerciseType.multipleChoice,
        );
      });

      test('returns BlankMC at roll 15', () {
        expect(
          exerciseTypeForRepetitions(2, random: _FixedRandom(15)),
          ExerciseType.blankMultipleChoice,
        );
      });
    });

    group('3 reps — BlankMC/Typing 40/60', () {
      test('returns BlankMC at roll 0', () {
        expect(
          exerciseTypeForRepetitions(3, random: _FixedRandom(0)),
          ExerciseType.blankMultipleChoice,
        );
      });

      test('returns Typing at roll 40', () {
        expect(
          exerciseTypeForRepetitions(3, random: _FixedRandom(40)),
          ExerciseType.typing,
        );
      });
    });

    group('4 reps — Typing/BlankTyping 50/50', () {
      test('returns Typing at roll 0', () {
        expect(
          exerciseTypeForRepetitions(4, random: _FixedRandom(0)),
          ExerciseType.typing,
        );
      });

      test('returns BlankTyping at roll 50', () {
        expect(
          exerciseTypeForRepetitions(4, random: _FixedRandom(50)),
          ExerciseType.blankTyping,
        );
      });
    });

    group('5+ reps — Typing/BlankTyping 10/90', () {
      test('returns Typing at roll 0', () {
        expect(
          exerciseTypeForRepetitions(5, random: _FixedRandom(0)),
          ExerciseType.typing,
        );
      });

      test('returns BlankTyping at roll 10', () {
        expect(
          exerciseTypeForRepetitions(5, random: _FixedRandom(10)),
          ExerciseType.blankTyping,
        );
      });

      test('clamps at 5+ for high reps', () {
        expect(
          exerciseTypeForRepetitions(100, random: _FixedRandom(10)),
          ExerciseType.blankTyping,
        );
      });
    });

    group('negative reps clamp to 0', () {
      test('returns MC for negative reps', () {
        expect(
          exerciseTypeForRepetitions(-5, random: _FixedRandom(0)),
          ExerciseType.multipleChoice,
        );
      });
    });

    group('hasSentences fallback', () {
      test('BlankMC collapses to MC when no sentences', () {
        expect(
          exerciseTypeForRepetitions(
            2,
            hasSentences: false,
            random: _FixedRandom(15),
          ),
          ExerciseType.multipleChoice,
        );
      });

      test('BlankTyping collapses to Typing when no sentences', () {
        expect(
          exerciseTypeForRepetitions(
            5,
            hasSentences: false,
            random: _FixedRandom(10),
          ),
          ExerciseType.typing,
        );
      });

      test('MC unchanged when no sentences', () {
        expect(
          exerciseTypeForRepetitions(
            0,
            hasSentences: false,
            random: _FixedRandom(0),
          ),
          ExerciseType.multipleChoice,
        );
      });

      test('Typing unchanged when no sentences', () {
        expect(
          exerciseTypeForRepetitions(
            4,
            hasSentences: false,
            random: _FixedRandom(0),
          ),
          ExerciseType.typing,
        );
      });
    });
  });
}
