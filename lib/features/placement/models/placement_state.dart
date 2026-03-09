import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';

/// A single question in the placement test.
class PlacementQuestion {
  const PlacementQuestion({
    required this.expression,
    required this.exerciseType,
    required this.choices,
    this.sentence,
    this.blankAnswer,
  });

  /// The expression being tested.
  final Expression expression;

  /// The type of exercise for this question.
  final ExerciseType exerciseType;

  /// Shuffled answer choices (for MC and blankMC types only).
  final List<String> choices;

  /// Sentence with `___` placeholder (for blank types only).
  final String? sentence;

  /// The correct answer for blank types (may differ from expression.romand).
  final String? blankAnswer;

  /// The correct answer for this question.
  String get correctAnswer => blankAnswer ?? expression.romand;

  /// Whether this is a typing exercise (typing or blankTyping).
  bool get isTyping =>
      exerciseType == ExerciseType.typing ||
      exerciseType == ExerciseType.blankTyping;
}

/// The state of the placement test.
class PlacementState {
  const PlacementState({
    required this.questions,
    required this.currentIndex,
    required this.answers,
    this.selectedAnswer,
    this.hasAnswered = false,
  });

  /// All placement questions.
  final List<PlacementQuestion> questions;

  /// Current question index.
  final int currentIndex;

  /// User's answers: true = correct, false = incorrect.
  final List<bool> answers;

  /// The answer the user just selected/typed (null if not yet answered).
  final String? selectedAnswer;

  /// Whether the current question has been answered.
  final bool hasAnswered;

  /// The current question.
  PlacementQuestion get currentQuestion => questions[currentIndex];

  /// Whether the test is complete.
  bool get isComplete => currentIndex >= questions.length;

  /// Number of correct answers per tier.
  Map<int, int> get correctByTier {
    final result = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (var i = 0; i < answers.length; i++) {
      if (answers[i]) {
        final tier = questions[i].expression.tier;
        result[tier] = (result[tier] ?? 0) + 1;
      }
    }
    return result;
  }

  /// Number of questions per tier.
  Map<int, int> get totalByTier {
    final result = <int, int>{1: 0, 2: 0, 3: 0, 4: 0};
    for (final q in questions) {
      result[q.expression.tier] = (result[q.expression.tier] ?? 0) + 1;
    }
    return result;
  }

  /// The highest tier the user should start at.
  ///
  /// A tier is considered "passed" if the user made at most 1 error
  /// (i.e. got at least total - 1 correct). 2 errors stops the test.
  int get placedTier {
    final byTier = correctByTier;
    final totals = totalByTier;
    var highest = 1;
    for (var tier = 1; tier <= 4; tier++) {
      final correct = byTier[tier] ?? 0;
      final total = totals[tier] ?? 0;
      if (total > 0 && correct >= total - 1) {
        highest = tier;
      } else {
        break;
      }
    }
    return highest;
  }

  /// Total correct answers.
  int get totalCorrect => answers.where((a) => a).length;

  PlacementState copyWith({
    List<PlacementQuestion>? questions,
    int? currentIndex,
    List<bool>? answers,
    String? Function()? selectedAnswer,
    bool? hasAnswered,
  }) {
    return PlacementState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedAnswer:
          selectedAnswer != null ? selectedAnswer() : this.selectedAnswer,
      hasAnswered: hasAnswered ?? this.hasAnswered,
    );
  }
}
