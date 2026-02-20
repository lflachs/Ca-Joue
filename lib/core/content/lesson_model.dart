import 'package:ca_joue/core/content/expression_model.dart';

/// A group of expressions within a tier, organized by lesson topic.
class Lesson {
  /// Creates a [Lesson].
  const Lesson({
    required this.name,
    required this.tier,
    required this.expressions,
  });

  /// Groups a flat list of expressions into [Lesson] objects by lesson field.
  static List<Lesson> groupByLesson(List<Expression> expressions) {
    final grouped = <String, List<Expression>>{};
    for (final expr in expressions) {
      grouped.putIfAbsent(expr.lesson, () => []).add(expr);
    }
    return grouped.entries
        .map(
          (entry) => Lesson(
            name: entry.key,
            tier: entry.value.first.tier,
            expressions: entry.value,
          ),
        )
        .toList();
  }

  /// Lesson identifier (e.g., "everyday-greetings").
  final String name;

  /// The tier this lesson belongs to.
  final int tier;

  /// The expressions in this lesson.
  final List<Expression> expressions;

  /// Number of expressions in this lesson.
  int get expressionCount => expressions.length;
}
