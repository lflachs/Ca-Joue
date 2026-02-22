import 'package:ca_joue/core/spaced_repetition/mastery_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Threshold values (0→0.0, 1→0.15, ..., 5→0.95) are tested in
  // mastery_calculator_test.dart. These tests verify behavioral properties.
  group('Mastery-based exercise type selection', () {
    test('probability increases monotonically with repetitions', () {
      var previous = -1.0;
      for (var reps = 0; reps <= 5; reps++) {
        final prob = typingProbability(reps);
        expect(
          prob,
          greaterThan(previous),
          reason: 'Probability at $reps reps should exceed $previous',
        );
        previous = prob;
      }
    });

    test('probability is never exactly 1.0 (MC always possible)', () {
      // Even at maximum mastery, there is a 5% chance of MC.
      for (var reps = 0; reps <= 100; reps++) {
        expect(
          typingProbability(reps),
          lessThanOrEqualTo(0.95),
          reason: 'Probability at $reps reps should not exceed 0.95',
        );
      }
    });

    test('transition is not abrupt between 2 and 3 reps', () {
      final prob2 = typingProbability(2);
      final prob3 = typingProbability(3);
      // Gap should be <= 0.30 (gradual, not 0.0 to 1.0 jump).
      expect(prob3 - prob2, closeTo(0.30, 0.001));
    });
  });
}
