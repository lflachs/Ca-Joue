import 'dart:math';

import 'package:ca_joue/core/content/accent_normalizer.dart';
import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/content/discovery_provider.dart';
import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:ca_joue/core/spaced_repetition/sm2_engine.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/features/exercise/providers/distractor_provider.dart';
import 'package:ca_joue/features/exercise/providers/expressions_by_lesson_provider.dart';
import 'package:ca_joue/features/exercise/providers/session_position_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'exercise_provider.g.dart';

/// Manages the exercise flow state machine for a given lesson.
///
/// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
/// start, or a saved index to resume where the user left off.
@riverpod
class ExerciseNotifier extends _$ExerciseNotifier {
  List<Expression> _expressions = [];
  int _currentIndex = 0;
  String _lessonId = '';

  @override
  Future<ExerciseState> build(String lessonId, int startIndex) async {
    _lessonId = lessonId;

    // Review mode: load due expressions instead of lesson expressions.
    if (lessonId == reviewLessonId) {
      _expressions = await ref.watch(dueExpressionsProvider.future);
    } else {
      _expressions =
          await ref.watch(expressionsByLessonProvider(lessonId).future);
    }

    _currentIndex = startIndex.clamp(0, _expressions.length);

    if (_expressions.isEmpty || _currentIndex >= _expressions.length) {
      return _buildCompleteState();
    }

    return _stateForExpression(_expressions[_currentIndex]);
  }

  /// Determines whether to show discovery or active state for an expression.
  Future<ExerciseState> _stateForExpression(Expression expression) async {
    final isFirst =
        await ref.read(isFirstEncounterProvider(expression.id).future);

    if (isFirst) {
      return ExerciseDiscovery(
        expression: expression,
        progressIndex: _currentIndex,
        totalExpressions: _expressions.length,
      );
    }

    return _activeStateForExpression(expression);
  }

  /// Builds the active exercise state based on the per-expression type.
  Future<ExerciseState> _activeStateForExpression(
    Expression expression,
  ) async {
    final exerciseType = exerciseTypeForIndex(
      _currentIndex,
      _expressions.length,
    );

    if (exerciseType == ExerciseType.typing) {
      return ExerciseTypingActive(
        expression: expression,
        progressIndex: _currentIndex,
        totalExpressions: _expressions.length,
      );
    }

    final distractorList =
        await ref.read(distractorsProvider(expression).future);
    final options = [...distractorList, expression.romand]..shuffle(Random());

    return ExerciseActive(
      expression: expression,
      options: options,
      progressIndex: _currentIndex,
      totalExpressions: _expressions.length,
    );
  }

  /// Transitions from discovery card to active exercise.
  Future<void> dismissDiscovery() async {
    final currentState = state.value;
    if (currentState is! ExerciseDiscovery) return;

    final nextState =
        await _activeStateForExpression(currentState.expression);
    if (ref.mounted) state = AsyncData(nextState);
  }

  /// Processes the user's MC answer and transitions to feedback state.
  Future<void> submitAnswer(String answer) async {
    final currentState = state.value;
    if (currentState is! ExerciseActive) return;

    final isCorrect = answer == currentState.expression.romand;

    await _writeProgress(currentState.expression.id, isCorrect: isCorrect);

    if (ref.mounted) {
      state = AsyncData(
        ExerciseFeedback(
          expression: currentState.expression,
          options: currentState.options,
          selectedAnswer: answer,
          correctAnswer: currentState.expression.romand,
          isCorrect: isCorrect,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    }
  }

  /// Processes the user's typed answer with accent-aware validation.
  Future<void> submitTypingAnswer(String userInput) async {
    final currentState = state.value;
    if (currentState is! ExerciseTypingActive) return;

    final expression = currentState.expression;
    final normalized = normalizeAccents(userInput);
    var isCorrect = normalized == normalizeAccents(expression.romand);

    if (!isCorrect) {
      for (final alt in expression.alternatives) {
        if (normalized == normalizeAccents(alt)) {
          isCorrect = true;
          break;
        }
      }
    }

    await _writeProgress(expression.id, isCorrect: isCorrect);

    if (ref.mounted) {
      state = AsyncData(
        ExerciseTypingFeedback(
          expression: expression,
          userAnswer: userInput.trim(),
          correctAnswer: expression.romand,
          isCorrect: isCorrect,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    }
  }

  /// Advances to the next expression or completes the lesson.
  Future<void> advance() async {
    final currentState = state.value;
    if (currentState is! ExerciseFeedback &&
        currentState is! ExerciseTypingFeedback) {
      return;
    }

    _currentIndex++;

    if (_currentIndex >= _expressions.length) {
      // Review sessions don't save/clear session position.
      if (_lessonId != reviewLessonId) {
        await ref.read(sessionPositionProvider.notifier).clearPosition();
      }

      if (!ref.mounted) return;
      state = AsyncData(await _buildCompleteState());
      return;
    }

    // Review sessions don't save mid-session position.
    if (_lessonId != reviewLessonId) {
      await ref
          .read(sessionPositionProvider.notifier)
          .savePosition(_lessonId, _currentIndex);
    }

    if (!ref.mounted) return;
    state = AsyncData(
      await _stateForExpression(_expressions[_currentIndex]),
    );
  }

  /// Builds the lesson complete state with tier completion detection.
  Future<ExerciseComplete> _buildCompleteState() async {
    // Review mode: simple completion, no tier logic.
    if (_lessonId == reviewLessonId) {
      return ExerciseComplete(
        lessonId: reviewLessonId,
        expressionsCount: _expressions.length,
        isTierComplete: false,
        tierName: 'Revision',
      );
    }

    final tier = _expressions.isNotEmpty ? _expressions.first.tier : 1;

    // Count all expressions in this tier and how many are complete.
    final allTierExprs = await ref.read(expressionsByTierProvider(tier).future);
    final totalInTier = allTierExprs.length;

    // Invalidate tier progress to get fresh data including latest writes.
    ref.invalidate(completedCountByTierProvider(tier));
    final completedInTier =
        await ref.read(completedCountByTierProvider(tier).future);

    final isTierComplete = completedInTier >= totalInTier;
    final tierName = Tier.nameForTier(tier);

    return ExerciseComplete(
      lessonId: _lessonId,
      expressionsCount: _expressions.length,
      isTierComplete: isTierComplete,
      tierName: tierName,
      nextTierName: tier < 4 ? Tier.nameForTier(tier + 1) : null,
    );
  }

  /// Reads existing progress, calculates SM-2, and writes the result.
  Future<void> _writeProgress(
    String expressionId, {
    required bool isCorrect,
  }) async {
    final db = await ref.read(databaseProvider.future);

    // Read existing progress (or use defaults for first encounter).
    final rows = await db.query(
      Tables.progress,
      where: '${Tables.progExpressionId} = ?',
      whereArgs: [expressionId],
      limit: 1,
    );
    final double ef;
    final double interval;
    final int reps;
    if (rows.isEmpty) {
      ef = 2.5;
      interval = 0;
      reps = 0;
    } else {
      ef = (rows.first[Tables.progEasinessFactor]! as num).toDouble();
      interval = (rows.first[Tables.progInterval]! as num).toDouble();
      reps = rows.first[Tables.progRepetitions]! as int;
    }

    // Calculate SM-2 result.
    final now = DateTime.now();
    final result = calculateSm2(
      easinessFactor: ef,
      interval: interval,
      repetitions: reps,
      quality: isCorrect ? sm2QualityCorrect : sm2QualityIncorrect,
      now: now,
    );

    // Write calculated values.
    await db.insert(
      Tables.progress,
      {
        Tables.progExpressionId: expressionId,
        Tables.progEasinessFactor: result.easinessFactor,
        Tables.progInterval: result.interval,
        Tables.progRepetitions: result.repetitions,
        Tables.progNextReview: result.nextReview.toIso8601String(),
        Tables.progLastReviewed: now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Invalidate first-encounter cache so discovery cards update.
    ref.invalidate(isFirstEncounterProvider(expressionId));
  }

  /// Returns the exercise type for a given expression index.
  ///
  /// First ~60% of expressions use multiple choice, the rest use typing.
  /// Story 3.3 will refine this with mastery-based selection.
  static ExerciseType exerciseTypeForIndex(int index, int total) {
    if (total <= 1) return ExerciseType.multipleChoice;
    final mcCutoff = (total * 0.6).ceil();
    return index < mcCutoff
        ? ExerciseType.multipleChoice
        : ExerciseType.typing;
  }
}
