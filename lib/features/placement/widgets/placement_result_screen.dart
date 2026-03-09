import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/features/onboarding/providers/onboarding_provider.dart';
import 'package:ca_joue/features/onboarding/widgets/mountain_silhouette.dart';
import 'package:ca_joue/features/placement/models/placement_state.dart';
import 'package:ca_joue/features/placement/providers/placement_provider.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/dahu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shows placement test results and lets the user continue to home.
class PlacementResultScreen extends ConsumerWidget {
  const PlacementResultScreen({required this.state, super.key});

  final PlacementState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placedTier = state.placedTier;
    final tierName = Tier.nameForTier(placedTier);

    final message = placedTier > 1
        ? 'Tu commences à $tierName !'
        : 'Tu commences à La Vallée !';

    final subtitle = placedTier > 1
        ? '${state.totalCorrect}/${state.questions.length} bonnes réponses — '
            'les ${placedTier - 1} premiers niveaux sont débloqués.'
        : '${state.totalCorrect}/${state.questions.length} bonnes réponses — '
            "pas de souci, c'est parti pour apprendre !";

    return Stack(
      children: [
        const SizedBox.expand(child: ColoredBox(color: CaJoueColors.snow)),
        const SizedBox.expand(child: MountainSilhouette()),
        SafeArea(
          child: Center(
            child: Padding(
              padding: CaJoueSpacing.horizontal,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Dahu(size: DahuSize.completion),
                  const SizedBox(height: CaJoueSpacing.lg),
                  Text(
                    message,
                    style: CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  Text(
                    subtitle,
                    style: CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.stone,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: CaJoueSpacing.md),
                  // Tier result badges.
                  _TierResults(state: state),
                  const SizedBox(height: CaJoueSpacing.xl),
                  CtaButton(
                    label: "C'est parti",
                    fullWidth: false,
                    onPressed: () async {
                      await ref
                          .read(placementProvider.notifier)
                          .applyResults();
                      await ref
                          .read(onboardingProvider.notifier)
                          .completeOnboarding();
                      if (context.mounted) context.go('/home');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows a compact summary of results per tier.
class _TierResults extends StatelessWidget {
  const _TierResults({required this.state});

  final PlacementState state;

  @override
  Widget build(BuildContext context) {
    final byTier = state.correctByTier;
    final placedTier = state.placedTier;

    return Column(
      children: [
        for (var tier = 1; tier <= 4; tier++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    Tier.nameForTier(tier),
                    style: CaJoueTypography.uiBody.copyWith(
                      color: tier <= placedTier
                          ? CaJoueColors.slate
                          : CaJoueColors.stone,
                      fontWeight: tier == placedTier
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: CaJoueSpacing.md),
                _DotRow(
                  correct: byTier[tier] ?? 0,
                  total: state.totalByTier[tier] ?? 4,
                  isUnlocked: tier <= placedTier,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Dots showing how many questions were answered correctly in a tier.
class _DotRow extends StatelessWidget {
  const _DotRow({
    required this.correct,
    required this.total,
    required this.isUnlocked,
  });

  final int correct;
  final int total;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isCorrect = i < correct;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect
                  ? CaJoueColors.gold
                  : isUnlocked
                      ? CaJoueColors.warmGrey
                      : CaJoueColors.cream,
            ),
          ),
        );
      }),
    );
  }
}
