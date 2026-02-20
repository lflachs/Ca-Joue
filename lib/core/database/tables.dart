/// Database table and column name constants.
///
/// All SQL schema definitions live here to keep raw SQL
/// contained within `lib/core/database/`.
abstract final class Tables {
  // -- Table names --

  /// Expressions table name.
  static const String expressions = 'expressions';

  /// Progress table name.
  static const String progress = 'progress';

  /// Sessions table name.
  static const String sessions = 'sessions';

  // -- Expressions columns --

  /// Expression primary key.
  static const String exprId = 'id';

  /// Standard French equivalent.
  static const String exprFrench = 'french';

  /// Swiss-Romand expression.
  static const String exprRomand = 'romand';

  /// Difficulty tier (1-4).
  static const String exprTier = 'tier';

  /// Lesson identifier.
  static const String exprLesson = 'lesson';

  /// JSON-encoded list of alternative answers.
  static const String exprAlternatives = 'alternatives';

  /// Cultural notes / backstory.
  static const String exprNotes = 'notes';

  // -- Progress columns --

  /// Foreign key to expressions.id.
  static const String progExpressionId = 'expression_id';

  /// SM-2 easiness factor.
  static const String progEasinessFactor = 'easiness_factor';

  /// SM-2 interval in days.
  static const String progInterval = 'interval';

  /// SM-2 repetition count.
  static const String progRepetitions = 'repetitions';

  /// Next review date (ISO 8601).
  static const String progNextReview = 'next_review';

  /// Last reviewed date (ISO 8601).
  static const String progLastReviewed = 'last_reviewed';

  // -- Sessions columns --

  /// Session singleton row id.
  static const String sessId = 'id';

  /// Current streak count.
  static const String sessStreakCount = 'streak_count';

  /// Last streak date (ISO 8601).
  static const String sessStreakLastDate = 'streak_last_date';

  /// Total accumulated points.
  static const String sessTotalPoints = 'total_points';

  /// Current lesson position (e.g., "1:everyday-greetings:3").
  static const String sessCurrentLessonPosition = 'current_lesson_position';

  /// Whether first launch onboarding is completed (0/1).
  static const String sessFirstLaunchCompleted = 'first_launch_completed';

  // -- CREATE TABLE SQL --

  /// SQL to create the expressions table.
  static const String createExpressions = '''
    CREATE TABLE $expressions (
      $exprId TEXT PRIMARY KEY,
      $exprFrench TEXT NOT NULL,
      $exprRomand TEXT NOT NULL,
      $exprTier INTEGER NOT NULL,
      $exprLesson TEXT NOT NULL,
      $exprAlternatives TEXT NOT NULL DEFAULT '[]',
      $exprNotes TEXT NOT NULL DEFAULT ''
    )
  ''';

  /// SQL to create the progress table.
  static const String createProgress = '''
    CREATE TABLE $progress (
      $progExpressionId TEXT PRIMARY KEY,
      $progEasinessFactor REAL NOT NULL DEFAULT 2.5,
      $progInterval REAL NOT NULL DEFAULT 0,
      $progRepetitions INTEGER NOT NULL DEFAULT 0,
      $progNextReview TEXT,
      $progLastReviewed TEXT,
      FOREIGN KEY ($progExpressionId) REFERENCES $expressions($exprId)
    )
  ''';

  /// SQL to create the sessions table.
  static const String createSessions = '''
    CREATE TABLE $sessions (
      $sessId INTEGER PRIMARY KEY DEFAULT 1,
      $sessStreakCount INTEGER NOT NULL DEFAULT 0,
      $sessStreakLastDate TEXT,
      $sessTotalPoints INTEGER NOT NULL DEFAULT 0,
      $sessCurrentLessonPosition TEXT,
      $sessFirstLaunchCompleted INTEGER NOT NULL DEFAULT 0
    )
  ''';
}
