import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/core/progress/overall_progress_provider.dart';
import 'package:ca_joue/core/progress/points_provider.dart';
import 'package:ca_joue/core/progress/streak_provider.dart';
import 'package:ca_joue/features/home/widgets/review_cta.dart';
import 'package:ca_joue/features/home/widgets/tier_row.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/sky_scenery.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// The home screen showing greeting and tier navigation.
class HomeScreen extends ConsumerWidget {
  /// Creates the [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tiersAsync = ref.watch(allTiersProvider);

    return SkyScenery(
      child: SafeArea(
        child: tiersAsync.when(
          loading: SizedBox.shrink,
          error: (err, stack) => Center(
            child: Padding(
              padding: CaJoueSpacing.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    err.toString(),
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  CtaButton(
                    label: 'Reessayer',
                    fullWidth: false,
                    onPressed: () => ref.invalidate(allTiersProvider),
                  ),
                ],
              ),
            ),
          ),
          data: (tiers) {
            final overallAsync = ref.watch(
              totalCompletedExpressionsProvider,
            );
            final completed = overallAsync.value ?? 0;
            final total = tiers.fold<int>(
              0,
              (sum, t) => sum + t.expressionCount,
            );
            final pointsAsync = ref.watch(totalPointsProvider);
            final points = pointsAsync.value ?? 0;
            final streakAsync = ref.watch(streakProvider);
            final streakCount = streakAsync.value?.count ?? 0;

            final fraction = total > 0 ? completed / total : 0.0;

            return Padding(
              padding: CaJoueSpacing.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: CaJoueSpacing.md),

                  // -- Greeting row with inline stats --
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Salut',
                        style: CaJoueTypography.appTitle.copyWith(
                          color: CaJoueColors.slate,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.flame,
                              size: 18,
                              color: streakCount > 0
                                  ? CaJoueColors.red
                                  : CaJoueColors.stone,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$streakCount',
                              style: CaJoueTypography.uiBody.copyWith(
                                color: CaJoueColors.stone,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Icon(
                              LucideIcons.star,
                              size: 18,
                              color: points > 0
                                  ? CaJoueColors.gold
                                  : CaJoueColors.stone,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$points',
                              style: CaJoueTypography.uiBody.copyWith(
                                color: CaJoueColors.stone,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: CaJoueSpacing.xs),

                  // -- Progress line --
                  Row(
                    children: [
                      Text(
                        '$completed/$total expressions',
                        style: CaJoueTypography.uiBody.copyWith(
                          color: CaJoueColors.stone,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: CaJoueSpacing.sm),

                  // -- Progress bar --
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Stack(
                        children: [
                          Container(color: CaJoueColors.cream),
                          FractionallySizedBox(
                            widthFactor: fraction,
                            child: Container(color: CaJoueColors.gold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: CaJoueSpacing.lg),

                  // -- Review CTA (conditional, self-spacing) --
                  const ReviewCta(),

                  // -- Tier list --
                  ...tiers.map((tier) {
                    final completedAsync = ref.watch(
                      completedCountByTierProvider(tier.number),
                    );
                    final completedCount = completedAsync.value ?? 0;
                    return TierRow(
                      tier: tier,
                      completedCount: completedCount,
                      onTap: tier.isUnlocked
                          ? () => context.push(
                              '/tier/${tier.number}',
                            )
                          : null,
                    );
                  }),

                  // Space for the mountain scenery at the bottom.
                  const SizedBox(height: 220),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
