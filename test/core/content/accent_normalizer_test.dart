import 'package:ca_joue/core/content/accent_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAccents', () {
    test('strips acute accents from e', () {
      expect(normalizeAccents('café'), 'cafe');
    });

    test('strips grave accents', () {
      expect(normalizeAccents('à là'), 'ala');
    });

    test('strips circumflex accents', () {
      expect(normalizeAccents('goûter'), 'gouter');
    });

    test('strips diaeresis', () {
      expect(normalizeAccents('naïve'), 'naive');
    });

    test('strips cedilla', () {
      expect(normalizeAccents('ça joue'), 'cajoue');
    });

    test('handles all French accent types on e', () {
      expect(normalizeAccents('è'), 'e');
      expect(normalizeAccents('é'), 'e');
      expect(normalizeAccents('ê'), 'e');
      expect(normalizeAccents('ë'), 'e');
    });

    test('handles all French accent types on a', () {
      expect(normalizeAccents('à'), 'a');
      expect(normalizeAccents('â'), 'a');
      expect(normalizeAccents('ä'), 'a');
    });

    test('handles all French accent types on u', () {
      expect(normalizeAccents('ù'), 'u');
      expect(normalizeAccents('û'), 'u');
      expect(normalizeAccents('ü'), 'u');
    });

    test('handles accents on i and o', () {
      expect(normalizeAccents('î'), 'i');
      expect(normalizeAccents('ï'), 'i');
      expect(normalizeAccents('ô'), 'o');
    });

    test('converts to lowercase', () {
      expect(normalizeAccents('CAFÉ'), 'cafe');
      expect(normalizeAccents('Ça Joue'), 'cajoue');
    });

    test('trims whitespace', () {
      expect(normalizeAccents('  café  '), 'cafe');
      expect(normalizeAccents('\ttest\n'), 'test');
    });

    test('returns empty string for empty input', () {
      expect(normalizeAccents(''), '');
    });

    test('returns empty string for whitespace-only input', () {
      expect(normalizeAccents('   '), '');
    });

    test('passes through unaccented text unchanged', () {
      expect(normalizeAccents('hello world'), 'helloworld');
    });

    test('handles ñ', () {
      expect(normalizeAccents('señor'), 'senor');
    });

    test('strips spaces and punctuation', () {
      expect(normalizeAccents("c'est la vie"), 'cestlavie');
      expect(normalizeAccents('bien-sûr !'), 'biensur');
    });

    test('matches with or without apostrophes and hyphens', () {
      expect(
        normalizeAccents("l'école"),
        normalizeAccents('lecole'),
      );
      expect(
        normalizeAccents('peut-être'),
        normalizeAccents('peut etre'),
      );
    });
  });
}
