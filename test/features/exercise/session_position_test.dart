import 'package:ca_joue/features/exercise/providers/session_position_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionPositionNotifier.parsePosition', () {
    test('returns null for null input', () {
      final result = SessionPositionNotifier.parsePosition(null);
      expect(result, isNull);
    });

    test('returns null for empty string', () {
      final result = SessionPositionNotifier.parsePosition('');
      expect(result, isNull);
    });

    test('returns null for string without colon', () {
      final result = SessionPositionNotifier.parsePosition(
        'everyday-greetings',
      );
      expect(result, isNull);
    });

    test('returns null for non-numeric index', () {
      final result = SessionPositionNotifier.parsePosition(
        'everyday-greetings:abc',
      );
      expect(result, isNull);
    });

    test('returns null for too many colons', () {
      final result = SessionPositionNotifier.parsePosition(
        'a:b:c',
      );
      expect(result, isNull);
    });

    test('parses valid position string', () {
      final result = SessionPositionNotifier.parsePosition(
        'everyday-greetings:3',
      );
      expect(result, isNotNull);
      expect(result!.lessonId, 'everyday-greetings');
      expect(result.index, 3);
    });

    test('parses position at index 0', () {
      final result = SessionPositionNotifier.parsePosition(
        'food-and-drink:0',
      );
      expect(result, isNotNull);
      expect(result!.lessonId, 'food-and-drink');
      expect(result.index, 0);
    });
  });
}
