import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A thin progress bar showing lesson advancement.
///
/// 3px height, cream track with red fill proportional to progress.
/// Animates fill width changes with 400ms ease-out unless reduced motion.
class ProgressBar extends StatelessWidget {
  /// Creates a [ProgressBar].
  const ProgressBar({
    required this.progressIndex,
    required this.totalExpressions,
    super.key,
  });

  /// Zero-based index of the current expression.
  final int progressIndex;

  /// Total number of expressions in the lesson.
  final int totalExpressions;

  @override
  Widget build(BuildContext context) {
    final fraction =
        totalExpressions > 0 ? (progressIndex + 1) / totalExpressions : 0.0;

    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: 'Expression ${progressIndex + 1} sur $totalExpressions',
      child: Padding(
        padding: CaJoueSpacing.horizontal,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: SizedBox(
            height: 3,
            child: DecoratedBox(
              decoration: const BoxDecoration(color: CaJoueColors.cream),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: reducedMotion
                      ? Duration.zero
                      : CaJoueAnimations.structural,
                  curve: CaJoueAnimations.defaultCurve,
                  widthFactor: fraction,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(color: CaJoueColors.red),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated version of [FractionallySizedBox] that interpolates [widthFactor].
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  /// Creates an [AnimatedFractionallySizedBox].
  const AnimatedFractionallySizedBox({
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
    super.key,
  });

  /// The fraction of the parent's width to fill.
  final double widthFactor;

  /// The child widget to render inside.
  final Widget child;

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}
