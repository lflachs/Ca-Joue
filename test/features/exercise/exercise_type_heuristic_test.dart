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
  // Exact threshold values are tested in mastery_calculator_test.dart.
  // These tests verify behavioral properties of the 4-stage progression.
  group('Mastery-based exercise type selection', () {
    test('progression moves through all 4 types as reps increase', () {
      // At specific rolls we should see all 4 types across the rep range.
      final types = <ExerciseType>{};
      for (var reps = 0; reps <= 5; reps++) {
        // Try multiple roll values to capture different types.
        for (final roll in [0, 50, 99]) {
          types.add(
            exerciseTypeForRepetitions(reps, random: _FixedRandom(roll)),
          );
        }
      }
      expect(types, contains(ExerciseType.multipleChoice));
      expect(types, contains(ExerciseType.blankMultipleChoice));
      expect(types, contains(ExerciseType.typing));
      expect(types, contains(ExerciseType.blankTyping));
    });

    test('0 reps always returns MC regardless of roll', () {
      for (final roll in [0, 25, 50, 75, 99]) {
        expect(
          exerciseTypeForRepetitions(0, random: _FixedRandom(roll)),
          ExerciseType.multipleChoice,
        );
      }
    });

    test('high reps never return MC (stage has moved past it)', () {
      for (final roll in [0, 25, 50, 75, 99]) {
        final type = exerciseTypeForRepetitions(5, random: _FixedRandom(roll));
        expect(type, isNot(ExerciseType.multipleChoice));
        expect(type, isNot(ExerciseType.blankMultipleChoice));
      }
    });

    test('hasSentences fallback collapses blank types', () {
      // BlankMC at 2 reps, roll 50 → MC when no sentences.
      expect(
        exerciseTypeForRepetitions(
          2,
          hasSentences: false,
          random: _FixedRandom(50),
        ),
        ExerciseType.multipleChoice,
      );

      // BlankTyping at 5 reps, roll 50 → Typing when no sentences.
      expect(
        exerciseTypeForRepetitions(
          5,
          hasSentences: false,
          random: _FixedRandom(50),
        ),
        ExerciseType.typing,
      );
    });
  });
}
