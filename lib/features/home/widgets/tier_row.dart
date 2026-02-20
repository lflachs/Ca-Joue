import 'package:ca_joue/core/content/tier_model.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A row representing a tier in the home screen.
///
/// Displays a colored dot, tier name, and expression count.
/// Three visual states: active (red), completed (gold), locked (grey).
class TierRow extends StatelessWidget {
  /// Creates a [TierRow] for the given [tier].
  const TierRow({
    required this.tier,
    required this.completedCount,
    required this.onTap,
    super.key,
  });

  /// The tier to display.
  final Tier tier;

  /// Number of expressions completed in this tier.
  final int completedCount;

  /// Tap callback. Null for locked tiers.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isCompleted = completedCount >= tier.expressionCount;
    final isActive = tier.isUnlocked && !isCompleted;
    final isLocked = !tier.isUnlocked;

    final status = isLocked
        ? 'locked'
        : isCompleted
            ? 'completed'
            : 'active';

    return GestureDetector(
      onTap: tier.isUnlocked ? onTap : null,
      child: Semantics(
        label: '${tier.name}, $completedCount of '
            '${tier.expressionCount} expressions, $status',
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: CaJoueColors.cream),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? CaJoueColors.gold
                        : isActive
                            ? CaJoueColors.red
                            : CaJoueColors.warmGrey,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                tier.name,
                style: CaJoueTypography.uiBody.copyWith(
                  color: isLocked
                      ? CaJoueColors.stone
                      : CaJoueColors.slate,
                ),
              ),
              const Spacer(),
              Text(
                '$completedCount/${tier.expressionCount}',
                style: CaJoueTypography.uiBody.copyWith(
                  color: isLocked
                      ? CaJoueColors.stone
                      : CaJoueColors.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
