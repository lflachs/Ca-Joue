import 'dart:async';
import 'dart:math';

import 'package:ca_joue/core/analytics/analytics.dart';
import 'package:ca_joue/core/content/accent_normalizer.dart';
import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/content/discovery_provider.dart';
import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/core/progress/points_provider.dart';
import 'package:ca_joue/core/progress/streak_provider.dart';
import 'package:ca_joue/core/spaced_repetition/mastery_calculator.dart';
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
  int _originalCount = 0;
  String _lessonId = '';

  @override
  Future<ExerciseState> build(String lessonId, int startIndex) async {
    _lessonId = lessonId;

    // Review mode: load due expressions instead of lesson expressions.
    if (lessonId == reviewLessonId) {
      _expressions = await ref.watch(dueExpressionsProvider.future);
    } else if (lessonId == practiceAllLessonId) {
      _expressions = [
        ...await ref.watch(seenExpressionsProvider.future),
      ];
      _expressions.shuffle(Random());
    } else if (isPracticeMode(lessonId)) {
      final tierNum = practiceTierNum(lessonId);
      if (tierNum != null) {
        _expressions = [
          ...await ref.watch(expressionsByTierProvider(tierNum).future),
        ];
        _expressions.shuffle(Random());
      }
    } else {
      _expressions = await ref.watch(
        expressionsByLessonProvider(lessonId).future,
      );
    }

    _originalCount = _expressions.length;
    _currentIndex = startIndex.clamp(0, _expressions.length);

    // Log session start (fire-and-forget).
    if (lessonId == reviewLessonId) {
      unawaited(Analytics.reviewStarted(dueCount: _expressions.length));
    } else if (lessonId == practiceAllLessonId) {
      unawaited(Analytics.practiceStarted());
    } else if (isPracticeMode(lessonId)) {
      unawaited(
        Analytics.practiceStarted(tier: '${practiceTierNum(lessonId)}'),
      );
    } else {
      final tier = _expressions.isNotEmpty ? _expressions.first.tier : 0;
      unawaited(Analytics.lessonStarted(lessonId: lessonId, tier: tier));
    }

    if (_expressions.isEmpty || _currentIndex >= _expressions.length) {
      return _buildCompleteState();
    }

    return _stateForExpression(_expressions[_currentIndex]);
  }

  /// Determines whether to show discovery or active state for an expression.
  Future<ExerciseState> _stateForExpression(Expression expression) async {
    final isFirst = await ref.read(
      isFirstEncounterProvider(expression.id).future,
    );

    if (isFirst) {
      return ExerciseDiscovery(
        expression: expression,
        progressIndex: _currentIndex,
        totalExpressions: _expressions.length,
      );
    }

    return _activeStateForExpression(expression);
  }

  /// Builds the active exercise state based on mastery-driven type selection.
  Future<ExerciseState> _activeStateForExpression(
    Expression expression,
  ) async {
    // Read progress to determine mastery-based exercise type.
    final db = await ref.read(databaseProvider.future);
    final progressRows = await db.query(
      Tables.progress,
      columns: [Tables.progRepetitions],
      where: '${Tables.progExpressionId} = ?',
      whereArgs: [expression.id],
      limit: 1,
    );
    final repetitions = progressRows.isEmpty
        ? 0
        : progressRows.first[Tables.progRepetitions]! as int;
    final hasSentences = expression.sentences.isNotEmpty;
    final exerciseType = exerciseTypeForRepetitions(
      repetitions,
      hasSentences: hasSentences,
    );

    switch (exerciseType) {
      case ExerciseType.typing:
        return ExerciseTypingActive(
          expression: expression,
          progressIndex: _currentIndex,
          totalExpressions: _expressions.length,
        );

      case ExerciseType.blankMultipleChoice:
        final raw = expression.sentences[
            Random().nextInt(expression.sentences.length)];
        final (sentenceText, sentenceAnswer) = _parseSentence(raw);
        final correctAnswer = sentenceAnswer ?? expression.romand;
        final distractorList = await ref.read(
          distractorsProvider(expression).future,
        );
        final options = [...distractorList, correctAnswer]
          ..shuffle(Random());
        return ExerciseBlankActive(
          expression: expression,
          sentence: sentenceText,
          correctAnswer: correctAnswer,
          options: options,
          progressIndex: _currentIndex,
          totalExpressions: _expressions.length,
        );

      case ExerciseType.blankTyping:
        final raw = expression.sentences[
            Random().nextInt(expression.sentences.length)];
        final (sentenceText, sentenceAnswer) = _parseSentence(raw);
        final correctAnswer = sentenceAnswer ?? expression.romand;
        return ExerciseBlankTypingActive(
          expression: expression,
          sentence: sentenceText,
          correctAnswer: correctAnswer,
          progressIndex: _currentIndex,
          totalExpressions: _expressions.length,
        );

      case ExerciseType.multipleChoice:
        final distractorList = await ref.read(
          distractorsProvider(expression).future,
        );
        final options = [...distractorList, expression.romand]
          ..shuffle(Random());
        return ExerciseActive(
          expression: expression,
          options: options,
          progressIndex: _currentIndex,
          totalExpressions: _expressions.length,
        );
    }
  }

  /// Transitions from discovery card to active exercise.
  Future<void> dismissDiscovery() async {
    final currentState = state.value;
    if (currentState is! ExerciseDiscovery) return;

    final nextState = await _activeStateForExpression(currentState.expression);
    if (ref.mounted) state = AsyncData(nextState);
  }

  /// Processes the user's MC answer and transitions to feedback state.
  Future<void> submitAnswer(String answer) async {
    final currentState = state.value;
    if (currentState is! ExerciseActive) return;

    final isCorrect = answer == currentState.expression.romand;

    await _writeProgress(
      currentState.expression.id,
      isCorrect: isCorrect,
    );
    if (isCorrect) {
      await ref.read(totalPointsProvider.notifier).increment();
    }

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

  /// Processes the user's blank MC answer and transitions to feedback state.
  Future<void> submitBlankAnswer(String answer) async {
    final currentState = state.value;
    if (currentState is! ExerciseBlankActive) return;

    final isCorrect = answer == currentState.correctAnswer;

    await _writeProgress(
      currentState.expression.id,
      isCorrect: isCorrect,
      exerciseType: 'blank_multiple_choice',
    );
    if (isCorrect) {
      await ref.read(totalPointsProvider.notifier).increment();
    }

    if (ref.mounted) {
      state = AsyncData(
        ExerciseBlankFeedback(
          expression: currentState.expression,
          sentence: currentState.sentence,
          selectedAnswer: answer,
          correctAnswer: currentState.correctAnswer,
          isCorrect: isCorrect,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    }
  }

  /// Processes the user's blank typing answer with accent-aware validation.
  Future<void> submitBlankTypingAnswer(String userInput) async {
    final currentState = state.value;
    if (currentState is! ExerciseBlankTypingActive) return;

    final expression = currentState.expression;
    final correctAnswer = currentState.correctAnswer;
    final normalized = normalizeAccents(userInput);
    var isCorrect = normalized == normalizeAccents(correctAnswer);

    // Also accept the base romand form and alternatives.
    if (!isCorrect) {
      if (normalized == normalizeAccents(expression.romand)) {
        isCorrect = true;
      }
      for (final alt in expression.alternatives) {
        if (normalized == normalizeAccents(alt)) {
          isCorrect = true;
          break;
        }
      }
    }

    await _writeProgress(
      expression.id,
      isCorrect: isCorrect,
      exerciseType: 'blank_typing',
    );
    if (isCorrect) {
      await ref.read(totalPointsProvider.notifier).increment();
    }

    if (ref.mounted) {
      state = AsyncData(
        ExerciseBlankTypingFeedback(
          expression: expression,
          sentence: currentState.sentence,
          userAnswer: userInput.trim(),
          correctAnswer: correctAnswer,
          isCorrect: isCorrect,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    }
  }

  /// Processes the user's typed answer with accent-aware validation.
  ///
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

    await _writeProgress(
      expression.id,
      isCorrect: isCorrect,
      exerciseType: 'typing',
    );
    if (isCorrect) {
      await ref.read(totalPointsProvider.notifier).increment();
    }

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

  /// Skips the current expression, counting it as incorrect.
  ///
  /// Transitions to the feedback state showing the correct answer,
  /// then the normal advance flow handles re-queuing and progression.
  Future<void> skip() async {
    final currentState = state.value;

    final Expression expression;
    if (currentState is ExerciseActive) {
      expression = currentState.expression;
    } else if (currentState is ExerciseTypingActive) {
      expression = currentState.expression;
    } else if (currentState is ExerciseBlankActive) {
      expression = currentState.expression;
    } else if (currentState is ExerciseBlankTypingActive) {
      expression = currentState.expression;
    } else {
      return;
    }

    await _writeProgress(expression.id, isCorrect: false);

    if (!ref.mounted) return;

    if (currentState is ExerciseActive) {
      state = AsyncData(
        ExerciseFeedback(
          expression: expression,
          options: currentState.options,
          selectedAnswer: '',
          correctAnswer: expression.romand,
          isCorrect: false,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    } else if (currentState is ExerciseTypingActive) {
      state = AsyncData(
        ExerciseTypingFeedback(
          expression: expression,
          userAnswer: '',
          correctAnswer: expression.romand,
          isCorrect: false,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    } else if (currentState is ExerciseBlankActive) {
      state = AsyncData(
        ExerciseBlankFeedback(
          expression: expression,
          sentence: currentState.sentence,
          selectedAnswer: '',
          correctAnswer: currentState.correctAnswer,
          isCorrect: false,
          progressIndex: currentState.progressIndex,
          totalExpressions: currentState.totalExpressions,
        ),
      );
    } else if (currentState is ExerciseBlankTypingActive) {
      state = AsyncData(
        ExerciseBlankTypingFeedback(
          expression: expression,
          sentence: currentState.sentence,
          userAnswer: '',
          correctAnswer: currentState.correctAnswer,
          isCorrect: false,
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
        currentState is! ExerciseTypingFeedback &&
        currentState is! ExerciseBlankFeedback &&
        currentState is! ExerciseBlankTypingFeedback) {
      return;
    }

    // Re-queue missed expressions so they come back until answered correctly.
    final isCorrect = switch (currentState) {
      ExerciseFeedback(:final isCorrect) => isCorrect,
      ExerciseTypingFeedback(:final isCorrect) => isCorrect,
      ExerciseBlankFeedback(:final isCorrect) => isCorrect,
      ExerciseBlankTypingFeedback(:final isCorrect) => isCorrect,
      _ => true,
    };
    if (!isCorrect) {
      final expression = switch (currentState) {
        ExerciseFeedback(:final expression) => expression,
        ExerciseTypingFeedback(:final expression) => expression,
        ExerciseBlankFeedback(:final expression) => expression,
        ExerciseBlankTypingFeedback(:final expression) => expression,
        _ => null,
      };
      if (expression != null) _expressions.add(expression);
    }

    _currentIndex++;

    if (_currentIndex >= _expressions.length) {
      // Review and practice sessions don't save/clear session position.
      if (_lessonId != reviewLessonId && !isPracticeMode(_lessonId)) {
        await ref.read(sessionPositionProvider.notifier).clearPosition();
      }

      // Record session completion for streak tracking.
      await ref.read(streakProvider.notifier).recordSession();

      // Log completion analytics.
      await Analytics.lessonCompleted(
        lessonId: _lessonId,
        expressionsCount: _originalCount,
      );

      // Refresh due count so home screen reflects latest state.
      ref.invalidate(dueExpressionCountProvider);

      if (!ref.mounted) return;
      state = AsyncData(await _buildCompleteState());
      return;
    }

    // Review and practice sessions don't save mid-session position.
    if (_lessonId != reviewLessonId && !isPracticeMode(_lessonId)) {
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

    // Practice-all mode: simple completion.
    if (_lessonId == practiceAllLessonId) {
      return ExerciseComplete(
        lessonId: _lessonId,
        expressionsCount: _originalCount,
        isTierComplete: false,
        tierName: 'Pratique',
      );
    }

    // Practice mode: simple completion, tiers are already done.
    if (isPracticeMode(_lessonId)) {
      final tierNum = practiceTierNum(_lessonId) ?? 1;
      return ExerciseComplete(
        lessonId: _lessonId,
        expressionsCount: _originalCount,
        isTierComplete: false,
        tierName: Tier.nameForTier(tierNum),
      );
    }

    final tier = _expressions.isNotEmpty ? _expressions.first.tier : 1;

    // Count all expressions in this tier and how many are complete.
    final allTierExprs = await ref.read(expressionsByTierProvider(tier).future);
    final totalInTier = allTierExprs.length;

    // Invalidate tier progress to get fresh data including latest writes.
    ref.invalidate(completedCountByTierProvider(tier));
    final completedInTier = await ref.read(
      completedCountByTierProvider(tier).future,
    );

    final isTierComplete = completedInTier >= totalInTier;
    final isAllComplete = isTierComplete && tier >= 4;
    final tierName = Tier.nameForTier(tier);

    return ExerciseComplete(
      lessonId: _lessonId,
      expressionsCount: _expressions.length,
      isTierComplete: isTierComplete,
      tierName: tierName,
      nextTierName: tier < 4 ? Tier.nameForTier(tier + 1) : null,
      isAllComplete: isAllComplete,
    );
  }

  /// Parses a sentence string with optional answer override.
  ///
  /// Format: `"sentence text"` or `"sentence text|||answer"`.
  /// Returns `(text, answer)` where answer is null if no override.
  static (String, String?) _parseSentence(String raw) {
    final parts = raw.split('|||');
    if (parts.length >= 2) {
      return (parts[0], parts[1]);
    }
    return (raw, null);
  }

  /// Reads existing progress, calculates SM-2, and writes the result.
  Future<void> _writeProgress(
    String expressionId, {
    required bool isCorrect,
    String exerciseType = 'multiple_choice',
  }) async {
    unawaited(Analytics.exerciseAnswered(
      lessonId: _lessonId,
      isCorrect: isCorrect,
      exerciseType: exerciseType,
    ));
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
}
