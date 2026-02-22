import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/content/lesson_model.dart';
import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'content_provider.g.dart';

/// Provides all expressions from the database.
@riverpod
Future<List<Expression>> allExpressions(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  final rows = await db.query(Tables.expressions);
  return rows.map(Expression.fromRow).toList();
}

/// Provides expressions filtered by tier.
@riverpod
Future<List<Expression>> expressionsByTier(Ref ref, int tier) async {
  final db = await ref.watch(databaseProvider.future);
  final rows = await db.query(
    Tables.expressions,
    where: '${Tables.exprTier} = ?',
    whereArgs: [tier],
  );
  return rows.map(Expression.fromRow).toList();
}

/// Provides lessons grouped by expressions within a tier.
@riverpod
Future<List<Lesson>> lessonsByTier(Ref ref, int tier) async {
  final expressions = await ref.watch(expressionsByTierProvider(tier).future);
  return Lesson.groupByLesson(expressions);
}

/// Provides all tiers with their lessons and unlock state.
@riverpod
Future<List<Tier>> allTiers(Ref ref) async {
  final allExpr = await ref.watch(allExpressionsProvider.future);

  final tiers = <Tier>[];
  for (var tierNum = 1; tierNum <= 4; tierNum++) {
    final tierExpressions = allExpr.where((e) => e.tier == tierNum).toList();
    final lessons = Lesson.groupByLesson(tierExpressions);

    // Tier 1 is always unlocked; others require previous tier completion.
    bool isUnlocked;
    if (tierNum == 1) {
      isUnlocked = true;
    } else {
      final prevComplete = await ref.watch(
        isTierCompleteProvider(tierNum - 1).future,
      );
      isUnlocked = prevComplete;
    }

    tiers.add(
      Tier(
        number: tierNum,
        name: Tier.nameForTier(tierNum),
        lessons: lessons,
        isUnlocked: isUnlocked,
      ),
    );
  }

  return tiers;
}
