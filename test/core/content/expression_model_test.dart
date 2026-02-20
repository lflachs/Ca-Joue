import 'dart:convert';

import 'package:ca_joue/core/content/expression_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expression', () {
    const sampleJson = {
      'id': 'expr_001',
      'french': "C'est bon / Ça marche",
      'romand': 'Ça joue',
      'tier': 1,
      'lesson': 'everyday-greetings',
      'alternatives': ['ça joue', 'ca joue'],
      'notes': 'Fun cultural note.',
    };

    final sampleRow = {
      'id': 'expr_001',
      'french': "C'est bon / Ça marche",
      'romand': 'Ça joue',
      'tier': 1,
      'lesson': 'everyday-greetings',
      'alternatives': jsonEncode(['ça joue', 'ca joue']),
      'notes': 'Fun cultural note.',
    };

    group('fromJson', () {
      test('parses all fields correctly', () {
        final expr = Expression.fromJson(sampleJson);

        expect(expr.id, 'expr_001');
        expect(expr.french, "C'est bon / Ça marche");
        expect(expr.romand, 'Ça joue');
        expect(expr.tier, 1);
        expect(expr.lesson, 'everyday-greetings');
        expect(expr.alternatives, ['ça joue', 'ca joue']);
        expect(expr.notes, 'Fun cultural note.');
      });

      test('defaults notes to empty string when missing', () {
        final jsonWithoutNotes = Map<String, dynamic>.from(sampleJson)
          ..remove('notes');
        final expr = Expression.fromJson(jsonWithoutNotes);

        expect(expr.notes, '');
      });

      test('handles empty alternatives list', () {
        final json = Map<String, dynamic>.from(sampleJson)
          ..['alternatives'] = <String>[];
        final expr = Expression.fromJson(json);

        expect(expr.alternatives, isEmpty);
      });
    });

    group('fromRow', () {
      test('parses all fields including JSON-encoded alternatives', () {
        final expr = Expression.fromRow(sampleRow);

        expect(expr.id, 'expr_001');
        expect(expr.french, "C'est bon / Ça marche");
        expect(expr.romand, 'Ça joue');
        expect(expr.tier, 1);
        expect(expr.lesson, 'everyday-greetings');
        expect(expr.alternatives, ['ça joue', 'ca joue']);
        expect(expr.notes, 'Fun cultural note.');
      });

      test('defaults notes to empty string when null', () {
        final row = Map<String, dynamic>.from(sampleRow)..['notes'] = null;
        final expr = Expression.fromRow(row);

        expect(expr.notes, '');
      });
    });

    group('toJson', () {
      test('produces correct JSON map', () {
        final expr = Expression.fromJson(sampleJson);
        final json = expr.toJson();

        expect(json['id'], 'expr_001');
        expect(json['alternatives'], isA<List<String>>());
        expect(json['alternatives'], ['ça joue', 'ca joue']);
        expect(json['notes'], 'Fun cultural note.');
      });
    });

    group('toRow', () {
      test('encodes alternatives as JSON string', () {
        final expr = Expression.fromJson(sampleJson);
        final row = expr.toRow();

        expect(row['id'], 'expr_001');
        expect(row['alternatives'], isA<String>());
        expect(
          jsonDecode(row['alternatives'] as String),
          ['ça joue', 'ca joue'],
        );
        expect(row['notes'], 'Fun cultural note.');
      });
    });

    group('round-trip', () {
      test('fromJson -> toJson preserves data', () {
        final expr = Expression.fromJson(sampleJson);
        final json = expr.toJson();

        expect(json, sampleJson);
      });

      test('fromRow -> toRow preserves data', () {
        final expr = Expression.fromRow(sampleRow);
        final row = expr.toRow();

        expect(row, sampleRow);
      });
    });
  });
}
