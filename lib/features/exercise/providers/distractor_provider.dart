import 'dart:math';

import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/content/expression_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distractor_provider.g.dart';

/// Returns 3 random Romand distractor strings, prioritising expressions
/// from the same lesson (same theme) so choices feel plausible, then
/// filling from the same tier if needed.
@riverpod
Future<List<String>> distractors(
  Ref ref,
  Expression current,
) async {
  final tierExpressions = await ref.watch(
    expressionsByTierProvider(current.tier).future,
  );

  final rng = Random();

  // Same-lesson candidates first (closest theme).
  final sameLessonCandidates =
      tierExpressions
          .where((e) => e.id != current.id && e.lesson == current.lesson)
          .map((e) => e.romand)
          .toList()
        ..shuffle(rng);

  if (sameLessonCandidates.length >= 3) {
    return sameLessonCandidates.sublist(0, 3);
  }

  // Fill remaining slots from the rest of the tier.
  final picked = [...sameLessonCandidates];
  final remaining = 3 - picked.length;

  final tierCandidates =
      tierExpressions
          .where((e) => e.id != current.id && e.lesson != current.lesson)
          .map((e) => e.romand)
          .toList()
        ..shuffle(rng);

  picked.addAll(tierCandidates.take(remaining));

  return picked;
}
