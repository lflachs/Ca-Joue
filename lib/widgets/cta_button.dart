import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A call-to-action button used across the app.
///
/// Uses [GestureDetector] for tap handling (no Material).
/// Disabled when [onPressed] is null.
class CtaButton extends StatefulWidget {
  /// Creates a [CtaButton] with the given [label] and [onPressed] callback.
  const CtaButton({
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    super.key,
  });

  /// The button text.
  final String label;

  /// Tap handler. When null, the button shows as disabled.
  final VoidCallback? onPressed;

  /// Whether the button stretches to full width minus 28px margins.
  final bool fullWidth;

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;

    final buttonContent = Transform.translate(
      offset: Offset(0, _isPressed ? -1 : 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDisabled ? CaJoueColors.warmGrey : CaJoueColors.slate,
          borderRadius: BorderRadius.circular(CaJoueAnimations.buttonRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.fullWidth ? 28 : 60,
            vertical: 16,
          ),
          child: Text(
            widget.label,
            style: CaJoueTypography.uiButton.copyWith(
              color: const Color(
                0xFFFFFFFF,
              ).withValues(alpha: isDisabled ? 0.5 : 1.0),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      label: widget.label,
      button: true,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
        onTapUp: isDisabled
            ? null
            : (_) {
                setState(() => _isPressed = false);
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled
            ? null
            : () => setState(() => _isPressed = false),
        child: widget.fullWidth
            ? SizedBox(width: double.infinity, child: buttonContent)
            : buttonContent,
      ),
    );
  }
}
