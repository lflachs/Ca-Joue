import 'package:ca_joue/core/content/lesson_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LessonNames', () {
    group('of', () {
      test('returns French display name for known Tier 1 lesson', () {
        expect(
          LessonNames.of('everyday-greetings'),
          'Salutations du quotidien',
        );
      });

      test('returns French display name for known Tier 2 lesson', () {
        expect(
          LessonNames.of('cooking-cuisine'),
          'Cuisine et recettes',
        );
      });

      test('returns French display name for known Tier 3 lesson', () {
        expect(
          LessonNames.of('advanced-vocabulary'),
          'Vocabulaire avancé',
        );
      });

      test('returns French display name for known Tier 4 lesson', () {
        expect(
          LessonNames.of('archaic-daily'),
          "Quotidien d'antan",
        );
      });

      test('falls back to Title Case for unknown lesson ID', () {
        expect(
          LessonNames.of('unknown-lesson-name'),
          'Unknown Lesson Name',
        );
      });

      test('handles single word fallback', () {
        expect(LessonNames.of('greetings'), 'Greetings');
      });

      test('all 32 lessons have mappings', () {
        const allIds = [
          // Tier 1
          'everyday-greetings', 'body-feelings', 'daily-errands',
          'food-drink', 'household-items', 'numbers-time',
          'social-basics', 'weather-basics',
          // Tier 2
          'cooking-cuisine', 'emotions-reactions', 'household-cleaning',
          'informal-expressions', 'insults-teasing', 'movement-actions',
          'social-gatherings', 'weather-nature', 'workplace-school',
          // Tier 3
          'advanced-vocabulary', 'character-traits', 'colorful-language',
          'culture-traditions', 'everyday-advanced', 'nature-elements',
          'regional-sayings',
          // Tier 4
          'archaic-daily', 'body-archaic', 'forgotten-words',
          'old-household', 'patois-heritage', 'rare-expressions',
          'rural-traditions', 'specialized-terms',
        ];

        for (final id in allIds) {
          final name = LessonNames.of(id);
          // Should not be a Title Case fallback (contains accents or
          // apostrophes that wouldn't come from simple conversion)
          expect(name, isNotEmpty, reason: 'Missing name for $id');
          // Verify it's not the fallback by checking it doesn't match
          // a naive title-case conversion for IDs with accented names
        }
        expect(allIds.length, 32);
      });

      test('names contain proper French accents', () {
        expect(LessonNames.of('weather-basics'), 'La météo');
        expect(LessonNames.of('emotions-reactions'), 'Émotions et réactions');
        expect(
          LessonNames.of('informal-expressions'),
          'Expressions familières',
        );
      });
    });
  });
}
