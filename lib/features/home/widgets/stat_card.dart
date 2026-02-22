import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// A card displaying a single statistic with a value and label.
///
/// Used on the home screen to show progress metrics like
/// expressions learned ("42/253 expressions").
class StatCard extends StatelessWidget {
  /// Creates a [StatCard].
  const StatCard({
    required this.value,
    required this.label,
    this.valueColor = CaJoueColors.slate,
    super.key,
  });

  /// The primary value to display (e.g., "42/253").
  final String value;

  /// The label below the value (e.g., "expressions").
  final String label;

  /// The color of the value text. Defaults to [CaJoueColors.slate].
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CaJoueSpacing.md,
          vertical: CaJoueSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: CaJoueColors.snow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CaJoueColors.warmGrey, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ).copyWith(color: valueColor),
              ),
            ),
            const SizedBox(height: CaJoueSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                style: CaJoueTypography.uiCaption.copyWith(
                  color: CaJoueColors.stone,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
