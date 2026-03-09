import 'dart:async';

import 'package:ca_joue/core/content/content_provider.dart';
import 'package:ca_joue/core/database/reset_provider.dart';
import 'package:ca_joue/core/progress/lesson_progress_provider.dart';
import 'package:ca_joue/core/progress/overall_progress_provider.dart';
import 'package:ca_joue/core/progress/points_provider.dart';
import 'package:ca_joue/core/progress/streak_provider.dart';
import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:ca_joue/features/home/widgets/tier_row.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/sky_scenery.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

void _showResetMenu(BuildContext context, WidgetRef ref) {
  context.push('/reset');
}

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
                      Semantics(
                        label: '$streakCount jours de série, $points points',
                        excludeSemantics: true,
                        child: Padding(
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
                                  color: streakCount > 0
                                      ? CaJoueColors.red
                                      : CaJoueColors.stone,
                                  fontWeight: FontWeight.w700,
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
                              const SizedBox(width: 14),
                              GestureDetector(
                                onTap: () => _showResetMenu(context, ref),
                                child: const Icon(
                                  LucideIcons.settings,
                                  size: 18,
                                  color: CaJoueColors.stone,
                                ),
                              ),
                            ],
                          ),
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

                  // -- Post-completion message --
                  if (completed >= total && total > 0)
                    Semantics(
                      excludeSemantics: true,
                      label:
                          'Toutes les expressions apprises.'
                          ' Revise quand tu veux.',
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: CaJoueSpacing.sm,
                        ),
                        child: Text(
                          'Revise quand tu veux',
                          style: CaJoueTypography.uiCaption.copyWith(
                            color: CaJoueColors.stone,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: CaJoueSpacing.lg),

                  // -- Practice & Review buttons --
                  if (completed > 0) ...[
                    _HomeActionButton(
                      label: 'Pratique libre',
                      semanticsLabel: 'Pratique libre. Appuie pour'
                          ' pratiquer toutes les expressions.',
                      onTap: () => context.push('/practice'),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final countAsync =
                            ref.watch(dueExpressionCountProvider);
                        final dueCount = countAsync.value ?? 0;
                        if (dueCount == 0) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: CaJoueSpacing.sm,
                          ),
                          child: _HomeActionButton(
                            label: 'Revoir les erreurs',
                            badge: '$dueCount',
                            semanticsLabel:
                                '$dueCount expressions \u00e0 revoir.'
                                ' Appuie pour commencer.',
                            onTap: () => context.push('/review'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: CaJoueSpacing.md),
                  ],

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
                          ? () {
                              if (completedCount >= tier.expressionCount) {
                                unawaited(
                                  context.push('/practice/${tier.number}'),
                                );
                              } else {
                                unawaited(
                                  context.push('/tier/${tier.number}'),
                                );
                              }
                            }
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

/// A cream-colored action button for the home screen.
class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.label,
    required this.semanticsLabel,
    this.badge,
    this.onTap,
  });

  final String label;
  final String semanticsLabel;
  final String? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: isDisabled ? 0.45 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 20,
            ),
            decoration: const BoxDecoration(
              color: CaJoueColors.cream,
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.slate,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: CaJoueColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: CaJoueTypography.uiCaption.copyWith(
                        color: CaJoueColors.snow,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    '\u203A',
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
