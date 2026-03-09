import 'dart:math';

import 'package:ca_joue/core/analytics/analytics.dart';
import 'package:ca_joue/core/content/accent_normalizer.dart';
import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/features/placement/models/placement_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'placement_provider.g.dart';

/// Exercise types to assign per tier (typing only — no MC).
///
/// 6 questions per tier, increasingly reliant on blank typing:
/// - Tier 1: 6 typing (translate the expression)
/// - Tier 2: 4 typing + 2 blank typing
/// - Tier 3: 2 typing + 4 blank typing
/// - Tier 4: 6 blank typing (hardest — context only)
const _tierExerciseTypes = <int, List<ExerciseType>>{
  1: [
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
  ],
  2: [
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
  ],
  3: [
    ExerciseType.typing,
    ExerciseType.typing,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
  ],
  4: [
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
    ExerciseType.blankTyping,
  ],
};

/// Manages the placement test state.
///
/// Picks 4 random expressions per tier (16 total), all typing-based.
/// Includes a "skip" action so the user can say "je ne sais pas".
@riverpod
class PlacementNotifier extends _$PlacementNotifier {
  @override
  Future<PlacementState> build() async {
    final allExpressions = await ref.read(allExpressionsProvider.future);
    final rng = Random();

    final questions = <PlacementQuestion>[];

    for (var tier = 1; tier <= 4; tier++) {
      final tierExprs =
          allExpressions.where((e) => e.tier == tier).toList()..shuffle(rng);

      final types = _tierExerciseTypes[tier]!;
      final picked = tierExprs.take(types.length).toList();

      for (var i = 0; i < picked.length; i++) {
        final expr = picked[i];
        var type = types[i];

        // If blank typing but no sentences, fall back to plain typing.
        if (type == ExerciseType.blankTyping && expr.sentences.isEmpty) {
          type = ExerciseType.typing;
        }

        final question = _buildQuestion(expr, type, rng);
        questions.add(question);
      }
    }

    return PlacementState(
      questions: questions,
      currentIndex: 0,
      answers: const [],
    );
  }

  /// Builds a typing or blank typing question.
  PlacementQuestion _buildQuestion(
    Expression expr,
    ExerciseType type,
    Random rng,
  ) {
    if (type == ExerciseType.blankTyping) {
      final raw = expr.sentences[rng.nextInt(expr.sentences.length)];
      final (sentenceText, sentenceAnswer) = _parseSentence(raw);
      final correctAnswer = sentenceAnswer ?? expr.romand;
      return PlacementQuestion(
        expression: expr,
        exerciseType: type,
        choices: const [],
        sentence: sentenceText,
        blankAnswer: correctAnswer,
      );
    }

    // Plain typing.
    return PlacementQuestion(
      expression: expr,
      exerciseType: type,
      choices: const [],
    );
  }

  /// Parses a sentence with optional answer override: "text|||answer".
  static (String, String?) _parseSentence(String raw) {
    final parts = raw.split('|||');
    if (parts.length >= 2) return (parts[0], parts[1]);
    return (raw, null);
  }

  /// Submits a typed answer with accent-aware validation.
  Future<void> answerTyping(String userInput) async {
    final current = state.value;
    if (current == null || current.hasAnswered || current.isComplete) return;

    final question = current.currentQuestion;
    final normalized = normalizeAccents(userInput);
    var isCorrect = normalized == normalizeAccents(question.correctAnswer);

    // Also accept the base romand form and alternatives.
    if (!isCorrect) {
      final expr = question.expression;
      if (normalized == normalizeAccents(expr.romand)) {
        isCorrect = true;
      }
      for (final alt in expr.alternatives) {
        if (normalized == normalizeAccents(alt)) {
          isCorrect = true;
          break;
        }
      }
    }

    state = AsyncData(
      current.copyWith(
        answers: [...current.answers, isCorrect],
        selectedAnswer: () => userInput.trim(),
        hasAnswered: true,
      ),
    );
  }

  /// Skips the current question (counts as wrong).
  void skip() {
    final current = state.value;
    if (current == null || current.hasAnswered || current.isComplete) return;

    state = AsyncData(
      current.copyWith(
        answers: [...current.answers, false],
        selectedAnswer: () => null,
        hasAnswered: true,
      ),
    );
  }

  /// Advances to the next question, or ends early on 2 wrong answers
  /// within the same tier.
  void next() {
    final current = state.value;
    if (current == null || !current.hasAnswered) return;

    final nextIndex = current.currentIndex + 1;

    // Count wrong answers in the current tier.
    final answeredTier = current.currentQuestion.expression.tier;
    var wrongInTier = 0;
    for (var i = 0; i < current.answers.length; i++) {
      if (current.questions[i].expression.tier == answeredTier &&
          !current.answers[i]) {
        wrongInTier++;
      }
    }

    // 2 errors in a tier = stop the test.
    if (wrongInTier >= 2) {
      state = AsyncData(
        current.copyWith(
          currentIndex: current.questions.length,
          selectedAnswer: () => null,
          hasAnswered: false,
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(
        currentIndex: nextIndex,
        selectedAnswer: () => null,
        hasAnswered: false,
      ),
    );
  }

  /// Applies placement results: unlocks tiers by inserting progress rows.
  Future<void> applyResults() async {
    final current = state.value;
    if (current == null) return;

    final placedTier = current.placedTier;
    if (placedTier <= 1) return;

    final db = await ref.read(databaseProvider.future);
    final allExpressions = await ref.read(allExpressionsProvider.future);

    final batch = db.batch();
    for (var tier = 1; tier < placedTier; tier++) {
      final tierExprs = allExpressions.where((e) => e.tier == tier);
      for (final expr in tierExprs) {
        batch.insert(
          Tables.progress,
          {
            Tables.progExpressionId: expr.id,
            Tables.progEasinessFactor: 2.5,
            Tables.progInterval: 1.0,
            Tables.progRepetitions: 1,
            Tables.progNextReview: DateTime.now()
                .add(const Duration(days: 1))
                .toIso8601String(),
            Tables.progLastReviewed: DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    await batch.commit(noResult: true);

    await Analytics.placementCompleted(
      placedTier: placedTier,
      totalCorrect: current.totalCorrect,
      totalQuestions: current.questions.length,
    );
  }
}
