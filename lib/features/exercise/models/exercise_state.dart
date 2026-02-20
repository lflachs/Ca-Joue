import 'package:ca_joue/core/content/expression_model.dart';

/// The state of the exercise flow, modeled as a sealed class hierarchy.
sealed class ExerciseState {
  /// Creates an [ExerciseState].
  const ExerciseState();
}

/// Expressions are being loaded from the database.
class ExerciseLoading extends ExerciseState {
  /// Creates an [ExerciseLoading] state.
  const ExerciseLoading();
}

/// A new expression is being presented via the discovery card.
class ExerciseDiscovery extends ExerciseState {
  /// Creates an [ExerciseDiscovery] state.
  const ExerciseDiscovery({
    required this.expression,
    required this.progressIndex,
    required this.totalExpressions,
  });

  /// The expression being discovered.
  final Expression expression;

  /// Zero-based index of the current expression in the lesson.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;
}

/// The user is choosing from four answer options.
class ExerciseActive extends ExerciseState {
  /// Creates an [ExerciseActive] state.
  const ExerciseActive({
    required this.expression,
    required this.options,
    required this.progressIndex,
    required this.totalExpressions,
  });

  /// The current expression being quizzed.
  final Expression expression;

  /// Four Romand answer options (one correct, three distractors), shuffled.
  final List<String> options;

  /// Zero-based index of the current expression in the lesson.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;
}

/// The user has answered and feedback is displayed.
class ExerciseFeedback extends ExerciseState {
  /// Creates an [ExerciseFeedback] state.
  const ExerciseFeedback({
    required this.expression,
    required this.options,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.progressIndex,
    required this.totalExpressions,
  });

  /// The current expression.
  final Expression expression;

  /// The four options that were displayed.
  final List<String> options;

  /// The answer the user selected.
  final String selectedAnswer;

  /// The correct Romand answer.
  final String correctAnswer;

  /// Whether the user's answer was correct.
  final bool isCorrect;

  /// Zero-based index of the current expression in the lesson.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;
}

/// The user is typing an answer for the current expression.
class ExerciseTypingActive extends ExerciseState {
  /// Creates an [ExerciseTypingActive] state.
  const ExerciseTypingActive({
    required this.expression,
    required this.progressIndex,
    required this.totalExpressions,
  });

  /// The current expression being quizzed.
  final Expression expression;

  /// Zero-based index of the current expression in the lesson.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;
}

/// The user has submitted a typed answer and feedback is displayed.
class ExerciseTypingFeedback extends ExerciseState {
  /// Creates an [ExerciseTypingFeedback] state.
  const ExerciseTypingFeedback({
    required this.expression,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.progressIndex,
    required this.totalExpressions,
  });

  /// The current expression.
  final Expression expression;

  /// The answer the user typed.
  final String userAnswer;

  /// The correct Romand answer (with proper accents for display).
  final String correctAnswer;

  /// Whether the user's answer was correct.
  final bool isCorrect;

  /// Zero-based index of the current expression in the lesson.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;
}

/// All expressions in the lesson have been answered.
class ExerciseComplete extends ExerciseState {
  /// Creates an [ExerciseComplete] state.
  const ExerciseComplete({
    required this.lessonId,
    required this.expressionsCount,
    required this.isTierComplete,
    required this.tierName,
    this.nextTierName,
  });

  /// The lesson that was completed.
  final String lessonId;

  /// Total number of expressions in the completed lesson.
  final int expressionsCount;

  /// Whether completing this lesson also completed the entire tier.
  final bool isTierComplete;

  /// Display name of the completed tier.
  final String tierName;

  /// Display name of the next tier, if one exists and was just unlocked.
  final String? nextTierName;
}

/// The type of exercise to present.
enum ExerciseType {
  /// Four-option multiple choice quiz.
  multipleChoice,

  /// Free-text typing with accent-forgiving validation.
  typing,
}

/// Visual state of an answer button.
enum AnswerButtonState {
  /// Default resting state.
  defaultState,

  /// The user's selection was correct.
  correct,

  /// The user's selection was incorrect.
  incorrect,

  /// An unselected button when another was chosen.
  dimmed,
}
