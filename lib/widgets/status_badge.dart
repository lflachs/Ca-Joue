import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// Different Badge variant with color and Labels
enum BadgeVariant {
  /// Completed variant
  completed(color: CaJoueColors.gold, label: 'Complété'),
  inProgress(color: CaJoueColors.dusk, label: 'En cours'),
  nouveau(color: CaJoueColors.stone, label: 'Nouveau')
  ;

  const BadgeVariant({required this.color, required this.label});

  /// The Badge color
  final Color color;

  /// the Badget Label
  final String label;
}

/// Display a status Badge with a variant
class StatusBadge extends StatelessWidget {
  /// Creates a [StatusBadge] with te given [variant]
  const StatusBadge({required this.variant, super.key});

  /// The badge variant
  final BadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(CaJoueAnimations.badgeRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          child: Text(
            variant.label,
            style: CaJoueTypography.uiCaption.copyWith(
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ),
      ),
    );
  }
}
