import 'dart:convert';

/// A Swiss-Romand expression with its French equivalent and metadata.
class Expression {
  /// Creates an [Expression].
  const Expression({
    required this.id,
    required this.french,
    required this.romand,
    required this.tier,
    required this.lesson,
    required this.alternatives,
    required this.notes,
  });

  /// Creates an [Expression] from a JSON map (asset loading).
  factory Expression.fromJson(Map<String, dynamic> json) {
    return Expression(
      id: json['id'] as String,
      french: json['french'] as String,
      romand: json['romand'] as String,
      tier: json['tier'] as int,
      lesson: json['lesson'] as String,
      alternatives: List<String>.from(json['alternatives'] as List),
      notes: json['notes'] as String? ?? '',
    );
  }

  /// Creates an [Expression] from a SQLite row.
  ///
  /// Alternatives are stored as a JSON string in the database.
  factory Expression.fromRow(Map<String, dynamic> row) {
    return Expression(
      id: row['id'] as String,
      french: row['french'] as String,
      romand: row['romand'] as String,
      tier: row['tier'] as int,
      lesson: row['lesson'] as String,
      alternatives: List<String>.from(
        jsonDecode(row['alternatives'] as String) as List,
      ),
      notes: row['notes'] as String? ?? '',
    );
  }

  /// Unique identifier (e.g., "expr_001").
  final String id;

  /// Standard French equivalent.
  final String french;

  /// Swiss-Romand expression.
  final String romand;

  /// Difficulty tier (1-4).
  final int tier;

  /// Lesson identifier within the tier.
  final String lesson;

  /// Accepted alternative answers.
  final List<String> alternatives;

  /// Cultural backstory, etymology, or usage notes.
  final String notes;

  /// Converts to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'french': french,
      'romand': romand,
      'tier': tier,
      'lesson': lesson,
      'alternatives': alternatives,
      'notes': notes,
    };
  }

  /// Converts to a SQLite row map.
  ///
  /// Alternatives are encoded as a JSON string for storage.
  Map<String, dynamic> toRow() {
    return {
      'id': id,
      'french': french,
      'romand': romand,
      'tier': tier,
      'lesson': lesson,
      'alternatives': jsonEncode(alternatives),
      'notes': notes,
    };
  }
}
