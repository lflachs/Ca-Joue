import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// The variant of a [FeedbackCard].
enum FeedbackCardVariant {
  /// Shows the user's incorrect answer with strikethrough.
  wrong,

  /// Shows the correct answer with gold styling.
  correct,
}

/// A card displaying answer feedback in the typing exercise flow.
///
/// Two variants:
/// - [FeedbackCardVariant.wrong]: cream background, user's answer with
///   strikethrough in dusk.
/// - [FeedbackCardVariant.correct]: goldSoft background with gold border,
///   correct expression in DM Serif Display.
class FeedbackCard extends StatelessWidget {
  /// Creates a [FeedbackCard].
  const FeedbackCard({
    required this.variant,
    required this.text,
    super.key,
  });

  /// The visual variant (wrong or correct).
  final FeedbackCardVariant variant;

  /// The answer text to display.
  final String text;

  @override
  Widget build(BuildContext context) {
    final isCorrect = variant == FeedbackCardVariant.correct;
    final label = isCorrect ? 'La bonne réponse' : 'Ta réponse';
    final semanticLabel = '$label: $text';

    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect ? CaJoueColors.goldSoft : CaJoueColors.cream,
          border: isCorrect
              ? Border.all(color: CaJoueColors.goldBorder, width: 2)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: CaJoueTypography.uiCaption.copyWith(
                color: isCorrect ? CaJoueColors.gold : CaJoueColors.stone,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.08 * 10,
              ),
            ),
            const SizedBox(height: CaJoueSpacing.xs),
            Text(
              text,
              style: isCorrect
                  ? CaJoueTypography.expressionTitle.copyWith(
                      color: CaJoueColors.slate,
                      fontSize: 24,
                    )
                  : CaJoueTypography.uiBody.copyWith(
                      color: CaJoueColors.dusk,
                      fontSize: 18,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: CaJoueColors.dusk,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
