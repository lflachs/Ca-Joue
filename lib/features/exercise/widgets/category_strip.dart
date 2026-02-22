import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// Red strip showing the lesson name and progress count.
///
/// Displays the lesson display name on the left and "N/M" on the right,
/// both in uppercase white Inter 11px 600 weight.
class CategoryStrip extends StatelessWidget {
  /// Creates a [CategoryStrip].
  const CategoryStrip({
    required this.lessonName,
    required this.progressIndex,
    required this.totalExpressions,
    this.onBack,
    super.key,
  });

  /// The French display name of the lesson.
  final String lessonName;

  /// Zero-based index of the current expression.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;

  /// Optional callback to navigate back. When provided, a back arrow
  /// is shown on the left side of the strip.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final labelStyle = CaJoueTypography.uiLabel.copyWith(
      color: CaJoueColors.slate,
      letterSpacing: 0.06 * 11,
    );

    return Semantics(
      label:
          'Lecon: $lessonName, expression '
          '${progressIndex + 1} sur $totalExpressions',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Row(
          children: [
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                behavior: HitTestBehavior.opaque,
                child: Semantics(
                  label: 'Retour',
                  button: true,
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      '\u2190',
                      style: labelStyle.copyWith(
                        fontSize: 16,
                        color: CaJoueColors.stone,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: Text(
                lessonName.toUpperCase(),
                style: labelStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${progressIndex + 1}/$totalExpressions',
              style: labelStyle.copyWith(color: CaJoueColors.stone),
            ),
          ],
        ),
      ),
    );
  }
}
