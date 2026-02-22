import 'package:ca_joue/features/exercise/models/exercise_state.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A multiple-choice answer button with four visual states.
///
/// Renders full-width with 56px minimum height and 14px border-radius.
/// Uses [AnswerButtonState] to determine styling.
class AnswerButton extends StatelessWidget {
  /// Creates an [AnswerButton].
  const AnswerButton({
    required this.text,
    required this.buttonState,
    required this.onTap,
    required this.index,
    super.key,
  });

  /// The answer text to display.
  final String text;

  /// The visual state of this button.
  final AnswerButtonState buttonState;

  /// Tap handler. Null when the button is non-interactive.
  final VoidCallback? onTap;

  /// Zero-based index for accessibility labeling.
  final int index;

  @override
  Widget build(BuildContext context) {
    final (
      bgColor,
      borderColor,
      textColor,
      fontWeight,
      decoration,
    ) = switch (buttonState) {
      AnswerButtonState.defaultState => (
        const Color(0xFFFFFFFF),
        CaJoueColors.cream,
        CaJoueColors.slate,
        FontWeight.w400,
        TextDecoration.none,
      ),
      AnswerButtonState.correct => (
        CaJoueColors.gold,
        CaJoueColors.gold,
        const Color(0xFFFFFFFF),
        FontWeight.w500,
        TextDecoration.none,
      ),
      AnswerButtonState.incorrect => (
        CaJoueColors.dusk,
        CaJoueColors.dusk,
        const Color(0xFFFFFFFF),
        FontWeight.w400,
        TextDecoration.lineThrough,
      ),
      AnswerButtonState.dimmed => (
        const Color(0xFFFFFFFF),
        CaJoueColors.cream,
        CaJoueColors.stone,
        FontWeight.w400,
        TextDecoration.none,
      ),
    };

    final String semanticLabel;
    if (buttonState == AnswerButtonState.correct) {
      semanticLabel = 'Option ${index + 1}: $text, correct';
    } else if (buttonState == AnswerButtonState.incorrect) {
      semanticLabel = 'Option ${index + 1}: $text, incorrect';
    } else {
      semanticLabel = 'Option ${index + 1}: $text';
    }

    return Semantics(
      label: semanticLabel,
      button: buttonState == AnswerButtonState.defaultState,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(CaJoueAnimations.buttonRadius),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: CaJoueSpacing.md,
            vertical: 14,
          ),
          child: Text(
            text,
            style: CaJoueTypography.uiBody.copyWith(
              color: textColor,
              fontWeight: fontWeight,
              decoration: decoration,
              decorationColor: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
