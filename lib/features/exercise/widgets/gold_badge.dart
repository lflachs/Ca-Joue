import 'dart:async';

import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A golden pill badge displaying "Ça joue!" on correct answers.
///
/// Animates with a scale-in (0.8 to 1.0, 300ms ease-out) unless
/// reduced motion is enabled, in which case it appears instantly.
class GoldBadge extends StatefulWidget {
  /// Creates a [GoldBadge].
  const GoldBadge({required this.reducedMotion, super.key});

  /// Whether to skip the scale-in animation.
  final bool reducedMotion;

  @override
  State<GoldBadge> createState() => _GoldBadgeState();
}

class _GoldBadgeState extends State<GoldBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CaJoueAnimations.feedback,
      value: widget.reducedMotion ? 1.0 : 0.0,
    );
    _scale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: CaJoueAnimations.defaultCurve,
      ),
    );
    if (!widget.reducedMotion) {
      unawaited(_controller.forward());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Correct!',
      excludeSemantics: true,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: CaJoueColors.gold,
            borderRadius: BorderRadius.circular(
              CaJoueAnimations.badgeRadius,
            ),
          ),
          child: Text(
            'Ça joue !',
            style: CaJoueTypography.uiBody.copyWith(
              color: const Color(0xFFFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
