import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/core/progress/overall_progress_provider.dart';
import 'package:ca_joue/core/progress/points_provider.dart';
import 'package:ca_joue/features/home/widgets/review_cta.dart';
import 'package:ca_joue/features/home/widgets/stat_card.dart';
import 'package:ca_joue/features/home/widgets/tier_row.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/sky_scenery.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

            return Padding(
              padding: CaJoueSpacing.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: CaJoueSpacing.xl),

                  // -- Greeting --
                  Text(
                    'Salut',
                    style: CaJoueTypography.appTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                  ),

                  const SizedBox(height: CaJoueSpacing.xs),

                  // -- Subtitle --
                  Text(
                    'Continue ton chemin',
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                  ),

                  const SizedBox(height: CaJoueSpacing.xl),

                  // -- Stats row --
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: '$completed/$total',
                          label: 'expressions',
                        ),
                      ),
                      const SizedBox(width: CaJoueSpacing.sm),
                      Expanded(
                        child: StatCard(
                          value: '$points',
                          label: 'points',
                          valueColor: CaJoueColors.gold,
                        ),
                      ),
                    ],
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
