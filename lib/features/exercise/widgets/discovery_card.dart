import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:flutter/widgets.dart';

/// Presents a new expression with its French equivalent and cultural
/// context before the user is quizzed.
///
/// Shown only on first encounter with an expression. The parent widget
/// decides when to display this card and handles the [onDismiss] callback.
class DiscoveryCard extends StatelessWidget {
  /// Creates a [DiscoveryCard] for the given [expression].
  const DiscoveryCard({
    required this.expression,
    required this.onDismiss,
    this.textOpacity = 1.0,
    this.contextOpacity = 0.0,
    this.contextOffset = Offset.zero,
    super.key,
  });

  /// The expression to present.
  final Expression expression;

  /// Called when the user taps "J'ai compris".
  final VoidCallback onDismiss;

  /// Opacity for the romand/french text section (Phase 1).
  final double textOpacity;

  /// Opacity for the context block and CTA button (Phase 2).
  final double contextOpacity;

  /// Slide offset for the context block (Phase 2).
  final Offset contextOffset;

  @override
  Widget build(BuildContext context) {
    final hasNotes = expression.notes.isNotEmpty;

    return Semantics(
      label:
          'Nouvelle expression: ${expression.romand}. '
          'En francais: ${expression.french}.'
          '${hasNotes ? ' Contexte: ${expression.notes}' : ''}',
      excludeSemantics: true,
      child: Center(
        child: SingleChildScrollView(
          padding: CaJoueSpacing.horizontal,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: CaJoueSpacing.xl),

              // -- Phase 1: Expression text --
              Opacity(
                opacity: textOpacity,
                child: Column(
                  children: [
                    Text(
                      expression.romand,
                      style: CaJoueTypography.expressionTitle.copyWith(
                        color: CaJoueColors.slate,
                        fontSize: 34,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CaJoueSpacing.sm),
                    Text(
                      expression.french,
                      style: CaJoueTypography.uiBody.copyWith(
                        color: CaJoueColors.stone,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // -- Phase 2: Cultural context --
              if (hasNotes) ...[
                const SizedBox(height: CaJoueSpacing.xl),
                Transform.translate(
                  offset: contextOffset,
                  child: Opacity(
                    opacity: contextOpacity,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(CaJoueSpacing.md),
                      decoration: BoxDecoration(
                        color: CaJoueColors.cream,
                        borderRadius: BorderRadius.circular(
                          CaJoueAnimations.buttonRadius,
                        ),
                      ),
                      child: Text(
                        expression.notes,
                        style: CaJoueTypography.contextBody.copyWith(
                          color: CaJoueColors.slate,
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: CaJoueSpacing.xl),

              // -- CTA button (fades with context) --
              Opacity(
                opacity: contextOpacity,
                child: CtaButton(
                  label: "J'ai compris",
                  fullWidth: false,
                  onPressed: onDismiss,
                ),
              ),

              const SizedBox(height: CaJoueSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
