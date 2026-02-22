import 'package:ca_joue/core/spaced_repetition/mastery_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('typingProbability', () {
    test('returns 0.0 for zero reps', () {
      expect(typingProbability(0), 0.0);
    });

    test('returns 0.15 for 1 rep', () {
      expect(typingProbability(1), 0.15);
    });

    test('returns 0.30 for 2 reps', () {
      expect(typingProbability(2), 0.30);
    });

    test('returns 0.60 for 3 reps', () {
      expect(typingProbability(3), 0.60);
    });

    test('returns 0.80 for 4 reps', () {
      expect(typingProbability(4), 0.80);
    });

    test('returns 0.95 for 5 reps', () {
      expect(typingProbability(5), 0.95);
    });

    test('clamps at 0.95 for reps above 5', () {
      expect(typingProbability(10), 0.95);
      expect(typingProbability(100), 0.95);
    });

    test('clamps negative reps to 0.0', () {
      expect(typingProbability(-1), 0.0);
      expect(typingProbability(-10), 0.0);
    });
  });
}
