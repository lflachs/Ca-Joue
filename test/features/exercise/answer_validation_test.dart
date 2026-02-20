import 'package:ca_joue/core/content/accent_normalizer.dart';
import 'package:ca_joue/core/content/expression_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Test the validation logic directly without Riverpod overhead.
// The provider is a thin wrapper around normalizeAccents comparison.
bool _validate(String userInput, Expression expression) {
  final normalized = normalizeAccents(userInput);

  if (normalized == normalizeAccents(expression.romand)) {
    return true;
  }

  for (final alt in expression.alternatives) {
    if (normalized == normalizeAccents(alt)) {
      return true;
    }
  }

  return false;
}

Expression _expr({
  String romand = 'ça joue',
  List<String> alternatives = const [],
}) {
  return Expression(
    id: 'test_001',
    french: 'ça marche',
    romand: romand,
    tier: 1,
    lesson: 'test-lesson',
    alternatives: alternatives,
    notes: '',
  );
}

void main() {
  group('answer validation', () {
    test('exact match against romand field', () {
      expect(_validate('ça joue', _expr()), true);
    });

    test('accent-forgiving match against romand', () {
      expect(_validate('ca joue', _expr()), true);
    });

    test('case-insensitive match', () {
      expect(_validate('Ça Joue', _expr()), true);
      expect(_validate('CA JOUE', _expr()), true);
    });

    test('match against alternatives array', () {
      final expr = _expr(
        romand: 'adieu',
        alternatives: ['salut', 'bonjour'],
      );
      expect(_validate('salut', expr), true);
      expect(_validate('bonjour', expr), true);
    });

    test('accent-forgiving match against alternatives', () {
      final expr = _expr(
        romand: 'goûter',
        alternatives: ['déguster'],
      );
      expect(_validate('gouter', expr), true);
      expect(_validate('deguster', expr), true);
    });

    test('no match returns false', () {
      expect(_validate('wrong answer', _expr()), false);
    });

    test('empty input returns false', () {
      expect(_validate('', _expr()), false);
    });

    test('whitespace-only input returns false', () {
      expect(_validate('   ', _expr()), false);
    });

    test('empty alternatives array still checks romand', () {
      expect(_validate('ça joue', _expr(alternatives: [])), true);
      expect(_validate('nope', _expr(alternatives: [])), false);
    });

    test('trims whitespace from input', () {
      expect(_validate('  ça joue  ', _expr()), true);
    });
  });
}
