import 'package:ca_joue/core/content/lesson_model.dart';

/// A difficulty tier containing lessons and expressions.
class Tier {
  /// Creates a [Tier].
  const Tier({
    required this.number,
    required this.name,
    required this.lessons,
    required this.isUnlocked,
  });

  /// Tier number (1-4).
  final int number;

  /// Display name for this tier.
  final String name;

  /// Lessons within this tier.
  final List<Lesson> lessons;

  /// Whether this tier is unlocked (Tier 1 always, others require
  /// completion of the previous tier).
  final bool isUnlocked;

  /// Total number of expressions across all lessons.
  int get expressionCount =>
      lessons.fold(0, (sum, lesson) => sum + lesson.expressionCount);

  /// Returns the display name for a given tier number.
  static String nameForTier(int tier) {
    return switch (tier) {
      1 => 'La Vallée',
      2 => "L'Alpage",
      3 => 'Le Sommet',
      4 => "L'Aiguille",
      _ => 'Tier $tier',
    };
  }
}
