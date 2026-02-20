/// SM-2 spaced repetition progress for a single expression.
class Progress {
  /// Creates a [Progress] instance.
  const Progress({
    required this.expressionId,
    required this.easinessFactor,
    required this.interval,
    required this.repetitions,
    this.nextReview,
    this.lastReviewed,
  });

  /// Creates initial progress for a new expression.
  factory Progress.initial(String expressionId) {
    return Progress(
      expressionId: expressionId,
      easinessFactor: 2.5,
      interval: 0,
      repetitions: 0,
    );
  }

  /// Creates a [Progress] from a SQLite row.
  ///
  /// Dates are stored as ISO 8601 strings in the database.
  factory Progress.fromRow(Map<String, dynamic> row) {
    return Progress(
      expressionId: row['expression_id'] as String,
      easinessFactor: row['easiness_factor'] as double,
      interval: row['interval'] as double,
      repetitions: row['repetitions'] as int,
      nextReview: row['next_review'] != null
          ? DateTime.parse(row['next_review'] as String)
          : null,
      lastReviewed: row['last_reviewed'] != null
          ? DateTime.parse(row['last_reviewed'] as String)
          : null,
    );
  }

  /// Foreign key to expressions.id.
  final String expressionId;

  /// SM-2 easiness factor (default 2.5).
  final double easinessFactor;

  /// SM-2 interval in days.
  final double interval;

  /// SM-2 repetition count.
  final int repetitions;

  /// Next scheduled review date.
  final DateTime? nextReview;

  /// Last time this expression was reviewed.
  final DateTime? lastReviewed;

  /// Converts to a SQLite row map.
  ///
  /// DateTimes are encoded as ISO 8601 strings.
  Map<String, dynamic> toRow() {
    return {
      'expression_id': expressionId,
      'easiness_factor': easinessFactor,
      'interval': interval,
      'repetitions': repetitions,
      'next_review': nextReview?.toIso8601String(),
      'last_reviewed': lastReviewed?.toIso8601String(),
    };
  }
}
