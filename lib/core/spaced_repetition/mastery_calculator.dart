/// Exercise type probability derived from SM-2 spaced repetition state.
///
/// Pure function implementation with no side effects or dependencies.
library;

/// Returns the probability of selecting a typing exercise for an expression.
///
/// Implements the gradual MC-to-typing transition specified by FR13:
/// - 0 reps: 0% typing (brand new — always MC)
/// - 1 rep: 15% typing (first correct — mostly MC)
/// - 2 reps: 30% typing (learning — mostly MC)
/// - 3 reps: 60% typing (developing — mostly typing)
/// - 4 reps: 80% typing (strong — predominantly typing)
/// - 5+ reps: 95% typing (mastered — almost always typing)
///
/// [repetitions] is the SM-2 consecutive-correct count.
double typingProbability(int repetitions) {
  const thresholds = [0.0, 0.15, 0.30, 0.60, 0.80, 0.95];
  final index = repetitions.clamp(0, thresholds.length - 1);
  return thresholds[index];
}
