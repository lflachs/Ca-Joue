import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/features/exercise/providers/exercise_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExerciseNotifier.exerciseTypeForIndex', () {
    test('returns MC for single expression', () {
      expect(
        ExerciseNotifier.exerciseTypeForIndex(0, 1),
        ExerciseType.multipleChoice,
      );
    });

    test('returns MC then typing for 2 expressions', () {
      // ceil(2 * 0.6) = 2, so index 0 is MC, index 1 is MC
      // Actually: ceil(2 * 0.6) = ceil(1.2) = 2
      expect(
        ExerciseNotifier.exerciseTypeForIndex(0, 2),
        ExerciseType.multipleChoice,
      );
      expect(
        ExerciseNotifier.exerciseTypeForIndex(1, 2),
        ExerciseType.multipleChoice,
      );
    });

    test('returns MC for first 60% and typing for rest with 10 expressions',
        () {
      // ceil(10 * 0.6) = 6, so indices 0-5 are MC, 6-9 are typing
      for (var i = 0; i < 6; i++) {
        expect(
          ExerciseNotifier.exerciseTypeForIndex(i, 10),
          ExerciseType.multipleChoice,
          reason: 'Index $i should be MC',
        );
      }
      for (var i = 6; i < 10; i++) {
        expect(
          ExerciseNotifier.exerciseTypeForIndex(i, 10),
          ExerciseType.typing,
          reason: 'Index $i should be typing',
        );
      }
    });

    test('handles 5 expressions correctly', () {
      // ceil(5 * 0.6) = 3, so indices 0-2 are MC, 3-4 are typing
      expect(
        ExerciseNotifier.exerciseTypeForIndex(0, 5),
        ExerciseType.multipleChoice,
      );
      expect(
        ExerciseNotifier.exerciseTypeForIndex(2, 5),
        ExerciseType.multipleChoice,
      );
      expect(
        ExerciseNotifier.exerciseTypeForIndex(3, 5),
        ExerciseType.typing,
      );
      expect(
        ExerciseNotifier.exerciseTypeForIndex(4, 5),
        ExerciseType.typing,
      );
    });
  });
}
