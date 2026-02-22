import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// Visual state of the [TypingInput] widget.
enum TypingInputState {
  /// Idle — 2px cream border, cursor hidden.
  unfocused,

  /// Active — 2px slate border, cursor blinking.
  focused,

  /// Correct answer — 2px gold border, goldSoft background.
  correct,

  /// Incorrect answer — 2px dusk border, cream background.
  wrong,
}

/// A custom text input field for typing exercises.
///
/// Built on [EditableText] from `package:flutter/widgets.dart` to avoid
/// Material dependency. The visual state is controlled by the parent via
/// [inputState].
class TypingInput extends StatelessWidget {
  /// Creates a [TypingInput].
  const TypingInput({
    required this.controller,
    required this.focusNode,
    required this.inputState,
    required this.reducedMotion,
    this.onSubmitted,
    super.key,
  });

  /// Controller for the editable text field.
  final TextEditingController controller;

  /// Focus node for the editable text field.
  final FocusNode focusNode;

  /// Current visual state.
  final TypingInputState inputState;

  /// Whether reduced motion is enabled.
  final bool reducedMotion;

  /// Called when the user submits via keyboard "done" action.
  final ValueChanged<String>? onSubmitted;

  Color get _borderColor => switch (inputState) {
    TypingInputState.unfocused => CaJoueColors.cream,
    TypingInputState.focused => CaJoueColors.slate,
    TypingInputState.correct => CaJoueColors.gold,
    TypingInputState.wrong => CaJoueColors.dusk,
  };

  Color get _backgroundColor => switch (inputState) {
    TypingInputState.correct => CaJoueColors.goldSoft,
    TypingInputState.wrong => CaJoueColors.cream,
    _ => const Color(0xFFFFFFFF),
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Tape l\'expression romande',
      textField: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.all(color: _borderColor, width: 2),
          borderRadius: BorderRadius.circular(
            CaJoueAnimations.buttonRadius,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignment: Alignment.center,
        child: EditableText(
          controller: controller,
          focusNode: focusNode,
          cursorColor: CaJoueColors.slate,
          backgroundCursorColor: CaJoueColors.cream,
          style: CaJoueTypography.uiBody.copyWith(
            color: CaJoueColors.slate,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          cursorOpacityAnimates: !reducedMotion,
          readOnly:
              inputState == TypingInputState.correct ||
              inputState == TypingInputState.wrong,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
