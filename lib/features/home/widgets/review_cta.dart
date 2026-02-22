import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Prominent call-to-action when expressions are due for review.
///
/// Displays on the home screen with a slate background, red count, and
/// white text. Hidden when no expressions are due (returns [SizedBox.shrink]).
class ReviewCta extends ConsumerWidget {
  /// Creates a [ReviewCta] widget.
  const ReviewCta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(dueExpressionCountProvider);
    final count = countAsync.value ?? 0;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedSwitcher(
      duration: reducedMotion ? Duration.zero : CaJoueAnimations.feedback,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            child: child,
          ),
        );
      },
      child: count == 0
          ? const SizedBox.shrink(key: ValueKey('review-empty'))
          : Padding(
              key: const ValueKey('review-cta'),
              padding: const EdgeInsets.only(bottom: CaJoueSpacing.md),
              child: Semantics(
                label:
                    '$count expressions \u00e0 revoir.'
                    ' Appuie pour commencer.',
                button: true,
                child: GestureDetector(
                  onTap: () => context.push('/review'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: CaJoueColors.slate,
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '$count',
                                  style: CaJoueTypography.uiBody.copyWith(
                                    color: CaJoueColors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: ' expressions \u00e0 revoir',
                                  style: CaJoueTypography.uiBody.copyWith(
                                    color: CaJoueColors.snow,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            '\u203A',
                            style: CaJoueTypography.expressionTitle.copyWith(
                              color: CaJoueColors.snow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
