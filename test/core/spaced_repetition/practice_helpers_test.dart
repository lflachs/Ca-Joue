import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isPracticeMode', () {
    test('returns true for valid practice sentinel', () {
      expect(isPracticeMode('__practice_tier_2__'), isTrue);
    });

    test('returns true for all tier numbers', () {
      for (var i = 1; i <= 4; i++) {
        expect(isPracticeMode('__practice_tier_${i}__'), isTrue);
      }
    });

    test('returns false for regular lesson id', () {
      expect(isPracticeMode('everyday-greetings'), isFalse);
    });

    test('returns false for review sentinel', () {
      expect(isPracticeMode(reviewLessonId), isFalse);
    });

    test('returns false for empty string', () {
      expect(isPracticeMode(''), isFalse);
    });
  });

  group('practiceTierNum', () {
    test('extracts tier number from valid sentinel', () {
      expect(practiceTierNum('__practice_tier_3__'), equals(3));
    });

    test('extracts tier 1', () {
      expect(practiceTierNum('__practice_tier_1__'), equals(1));
    });

    test('extracts tier 4', () {
      expect(practiceTierNum('__practice_tier_4__'), equals(4));
    });

    test('returns null for non-numeric tier', () {
      expect(practiceTierNum('__practice_tier_invalid__'), isNull);
    });

    test('returns null for review sentinel', () {
      expect(practiceTierNum(reviewLessonId), isNull);
    });

    test('returns null for regular lesson id', () {
      expect(practiceTierNum('everyday-greetings'), isNull);
    });

    test('returns null for empty string', () {
      expect(practiceTierNum(''), isNull);
    });
  });
}
