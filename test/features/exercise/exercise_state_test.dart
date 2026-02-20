import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testExpression = Expression.fromRow(const {
    'id': 'expr_test',
    'french': 'Bonjour',
    'romand': 'Adieu',
    'tier': 1,
    'lesson': 'everyday-greetings',
    'alternatives': '[]',
    'notes': 'Common greeting',
  });

  group('ExerciseState sealed class', () {
    test('ExerciseLoading is an ExerciseState', () {
      const state = ExerciseLoading();
      expect(state, isA<ExerciseState>());
    });

    test('ExerciseDiscovery holds expression and progress', () {
      final state = ExerciseDiscovery(
        expression: testExpression,
        progressIndex: 0,
        totalExpressions: 5,
      );
      expect(state.expression.id, 'expr_test');
      expect(state.progressIndex, 0);
      expect(state.totalExpressions, 5);
    });

    test('ExerciseActive holds options', () {
      final state = ExerciseActive(
        expression: testExpression,
        options: const ['Adieu', 'Salut', 'Bonjour', 'Ciao'],
        progressIndex: 1,
        totalExpressions: 8,
      );
      expect(state.options, hasLength(4));
      expect(state.options, contains('Adieu'));
    });

    test('ExerciseFeedback tracks correctness', () {
      final correct = ExerciseFeedback(
        expression: testExpression,
        options: const ['Adieu', 'Salut', 'Bonjour', 'Ciao'],
        selectedAnswer: 'Adieu',
        correctAnswer: 'Adieu',
        isCorrect: true,
        progressIndex: 0,
        totalExpressions: 5,
      );
      expect(correct.isCorrect, isTrue);
      expect(correct.selectedAnswer, correct.correctAnswer);

      final wrong = ExerciseFeedback(
        expression: testExpression,
        options: const ['Adieu', 'Salut', 'Bonjour', 'Ciao'],
        selectedAnswer: 'Salut',
        correctAnswer: 'Adieu',
        isCorrect: false,
        progressIndex: 0,
        totalExpressions: 5,
      );
      expect(wrong.isCorrect, isFalse);
      expect(wrong.selectedAnswer, isNot(wrong.correctAnswer));
    });

    test('ExerciseComplete holds lessonId and fields', () {
      const state = ExerciseComplete(
        lessonId: 'everyday-greetings',
        expressionsCount: 8,
        isTierComplete: false,
        tierName: 'Les Bases',
      );
      expect(state.lessonId, 'everyday-greetings');
      expect(state.expressionsCount, 8);
      expect(state.isTierComplete, isFalse);
      expect(state.tierName, 'Les Bases');
      expect(state.nextTierName, isNull);
    });

    test('ExerciseComplete tier complete variant', () {
      const state = ExerciseComplete(
        lessonId: 'everyday-greetings',
        expressionsCount: 8,
        isTierComplete: true,
        tierName: 'Les Bases',
        nextTierName: 'Au Quotidien',
      );
      expect(state.isTierComplete, isTrue);
      expect(state.nextTierName, 'Au Quotidien');
    });

    test('sealed switch covers all states', () {
      final states = <ExerciseState>[
        const ExerciseLoading(),
        ExerciseDiscovery(
          expression: testExpression,
          progressIndex: 0,
          totalExpressions: 1,
        ),
        ExerciseActive(
          expression: testExpression,
          options: const ['A', 'B', 'C', 'D'],
          progressIndex: 0,
          totalExpressions: 1,
        ),
        ExerciseFeedback(
          expression: testExpression,
          options: const ['A', 'B', 'C', 'D'],
          selectedAnswer: 'A',
          correctAnswer: 'A',
          isCorrect: true,
          progressIndex: 0,
          totalExpressions: 1,
        ),
        ExerciseTypingActive(
          expression: testExpression,
          progressIndex: 0,
          totalExpressions: 1,
        ),
        ExerciseTypingFeedback(
          expression: testExpression,
          userAnswer: 'adieu',
          correctAnswer: 'Adieu',
          isCorrect: true,
          progressIndex: 0,
          totalExpressions: 1,
        ),
        const ExerciseComplete(
          lessonId: 'test',
          expressionsCount: 5,
          isTierComplete: false,
          tierName: 'Les Bases',
        ),
      ];

      for (final state in states) {
        final label = switch (state) {
          ExerciseLoading() => 'loading',
          ExerciseDiscovery() => 'discovery',
          ExerciseActive() => 'active',
          ExerciseFeedback() => 'feedback',
          ExerciseTypingActive() => 'typing-active',
          ExerciseTypingFeedback() => 'typing-feedback',
          ExerciseComplete() => 'complete',
        };
        expect(label, isNotEmpty);
      }
    });
  });

  group('ExerciseTypingActive', () {
    test('holds expression and progress without options', () {
      final state = ExerciseTypingActive(
        expression: testExpression,
        progressIndex: 2,
        totalExpressions: 10,
      );
      expect(state.expression.id, 'expr_test');
      expect(state.progressIndex, 2);
      expect(state.totalExpressions, 10);
      expect(state, isA<ExerciseState>());
    });
  });

  group('ExerciseTypingFeedback', () {
    test('tracks correct typing answer', () {
      final state = ExerciseTypingFeedback(
        expression: testExpression,
        userAnswer: 'Adieu',
        correctAnswer: 'Adieu',
        isCorrect: true,
        progressIndex: 0,
        totalExpressions: 5,
      );
      expect(state.isCorrect, isTrue);
      expect(state.userAnswer, 'Adieu');
      expect(state.correctAnswer, 'Adieu');
    });

    test('tracks incorrect typing answer', () {
      final state = ExerciseTypingFeedback(
        expression: testExpression,
        userAnswer: 'Bonjour',
        correctAnswer: 'Adieu',
        isCorrect: false,
        progressIndex: 0,
        totalExpressions: 5,
      );
      expect(state.isCorrect, isFalse);
      expect(state.userAnswer, isNot(state.correctAnswer));
    });

    test('preserves user answer with original casing', () {
      final state = ExerciseTypingFeedback(
        expression: testExpression,
        userAnswer: 'aDiEu',
        correctAnswer: 'Adieu',
        isCorrect: true,
        progressIndex: 0,
        totalExpressions: 1,
      );
      expect(state.userAnswer, 'aDiEu');
    });
  });

  group('ExerciseType', () {
    test('has exactly 2 values', () {
      expect(ExerciseType.values, hasLength(2));
    });

    test('contains multipleChoice and typing', () {
      expect(
        ExerciseType.values,
        containsAll([
          ExerciseType.multipleChoice,
          ExerciseType.typing,
        ]),
      );
    });
  });

  group('AnswerButtonState', () {
    test('has exactly 4 values', () {
      expect(AnswerButtonState.values, hasLength(4));
    });

    test('contains all expected states', () {
      expect(
        AnswerButtonState.values,
        containsAll([
          AnswerButtonState.defaultState,
          AnswerButtonState.correct,
          AnswerButtonState.incorrect,
          AnswerButtonState.dimmed,
        ]),
      );
    });
  });
}
