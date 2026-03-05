/// Exercise type selection derived from SM-2 spaced repetition state.
///
/// Pure function implementation with no side effects or dependencies.
library;

import 'dart:math';

import 'package:ca_joue/features/exercise/models/exercise_state.dart';

/// Weighted distribution for each mastery stage.
///
/// Order: MC, BlankMC, Typing, BlankTyping.
const _stageWeights = <List<int>>[
  [100, 0, 0, 0], // 0 reps
  [60, 40, 0, 0], // 1 rep
  [15, 85, 0, 0], // 2 reps
  [0, 40, 60, 0], // 3 reps
  [0, 0, 50, 50], // 4 reps
  [0, 0, 10, 90], // 5+ reps
];

const List<ExerciseType> _exerciseTypes = [
  ExerciseType.multipleChoice,
  ExerciseType.blankMultipleChoice,
  ExerciseType.typing,
  ExerciseType.blankTyping,
];

/// Returns the exercise type for a given repetition count.
///
/// Implements 4-stage mastery progression:
/// - 0 reps: always MC (brand new)
/// - 1 rep: MC → BlankMC transition
/// - 2 reps: mostly BlankMC
/// - 3 reps: BlankMC → Typing transition
/// - 4 reps: Typing → BlankTyping transition
/// - 5+ reps: mostly BlankTyping (mastered)
///
/// If [hasSentences] is false, blank types collapse to their non-blank
/// equivalent (BlankMC → MC, BlankTyping → Typing).
///
/// An optional [random] can be injected for deterministic testing.
ExerciseType exerciseTypeForRepetitions(
  int repetitions, {
  bool hasSentences = true,
  Random? random,
}) {
  final index = repetitions.clamp(0, _stageWeights.length - 1);
  final weights = _stageWeights[index];
  final rng = random ?? Random();

  final roll = rng.nextInt(100);
  var cumulative = 0;
  var selected = ExerciseType.multipleChoice;
  for (var i = 0; i < weights.length; i++) {
    cumulative += weights[i];
    if (roll < cumulative) {
      selected = _exerciseTypes[i];
      break;
    }
  }

  // Fallback: collapse blank types when no sentences available.
  if (!hasSentences) {
    if (selected == ExerciseType.blankMultipleChoice) {
      return ExerciseType.multipleChoice;
    }
    if (selected == ExerciseType.blankTyping) {
      return ExerciseType.typing;
    }
  }

  return selected;
}
