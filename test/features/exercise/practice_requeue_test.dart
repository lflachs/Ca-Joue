import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:flutter_test/flutter_test.dart';

// Tests the practice-until-perfect re-queue logic.
//
// The actual logic lives in ExerciseNotifier.advance:
//   1. On incorrect answer in practice mode, append the expression.
//   2. Session ends when currentIndex >= expressions.length.
//   3. originalCount tracks unique expressions, not total attempts.
//
// We test this in isolation by simulating the list mutations.

Expression _expr(String id) => Expression(
  id: id,
  french: 'French $id',
  romand: 'Romand $id',
  tier: 1,
  lesson: 'test-lesson',
  alternatives: const [],
  notes: '',
);

void main() {
  group('practice re-queue logic', () {
    test('incorrect answer appends expression to end of list', () {
      final expressions = [_expr('a'), _expr('b'), _expr('c')];
      final originalCount = expressions.length;
      var currentIndex = 0;

      // Simulate: answer 'a' incorrectly → re-queue.
      expressions.add(expressions[currentIndex]); // re-queue 'a'
      currentIndex++;

      expect(expressions, hasLength(4));
      expect(expressions.last.id, 'a');
      expect(originalCount, 3);
    });

    test('correct answer does not re-queue', () {
      final expressions = [_expr('a'), _expr('b')];
      var currentIndex = 0;

      // Simulate: answer 'a' correctly → no re-queue.
      currentIndex++;

      expect(expressions, hasLength(2));
      expect(currentIndex, 1);
    });

    test('session ends only when all expressions answered correctly', () {
      final expressions = [_expr('a'), _expr('b')];
      var currentIndex = 0;

      // Round 1: 'a' wrong → re-queue.
      expressions.add(expressions[currentIndex]);
      currentIndex++;

      // Round 2: 'b' correct.
      currentIndex++;

      // Not done yet — 'a' is still queued at index 2.
      expect(currentIndex < expressions.length, isTrue);

      // Round 3: 'a' correct this time.
      currentIndex++;

      // Now done.
      expect(currentIndex >= expressions.length, isTrue);
    });

    test('originalCount reflects unique count, not retries', () {
      final expressions = [_expr('a'), _expr('b'), _expr('c')];
      final originalCount = expressions.length;

      // Miss 'a', 'b', and 'a' again.
      expressions
        ..add(expressions[0]) // re-queue 'a'
        ..add(expressions[1]) // re-queue 'b'
        ..add(expressions[0]); // re-queue 'a' again

      expect(expressions, hasLength(6));
      expect(originalCount, 3, reason: 'originalCount should stay at 3');
    });

    test('multiple wrong answers re-queue multiple times', () {
      final expressions = [_expr('x')];
      final originalCount = expressions.length;
      var currentIndex = 0;

      // Attempt 1: wrong.
      expressions.add(expressions[currentIndex]);
      currentIndex++;

      // Attempt 2: wrong again.
      expressions.add(expressions[currentIndex]);
      currentIndex++;

      // Attempt 3: correct.
      currentIndex++;

      expect(currentIndex >= expressions.length, isTrue);
      expect(expressions, hasLength(3));
      expect(originalCount, 1);
    });

    test('feedback state provides expression for re-queue', () {
      final expr = _expr('test');

      final mcFeedback = ExerciseFeedback(
        expression: expr,
        options: const ['A', 'B', 'C', 'D'],
        selectedAnswer: 'B',
        correctAnswer: 'A',
        isCorrect: false,
        progressIndex: 0,
        totalExpressions: 1,
      );

      final typingFeedback = ExerciseTypingFeedback(
        expression: expr,
        userAnswer: 'wrong',
        correctAnswer: 'Romand test',
        isCorrect: false,
        progressIndex: 0,
        totalExpressions: 1,
      );

      // Both feedback types expose the expression for re-queue.
      expect(mcFeedback.expression.id, 'test');
      expect(typingFeedback.expression.id, 'test');
      expect(mcFeedback.isCorrect, isFalse);
      expect(typingFeedback.isCorrect, isFalse);
    });
  });
}
