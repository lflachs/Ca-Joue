import 'dart:async';

import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/features/exercise/widgets/discovery_card.dart';
import 'package:flutter/widgets.dart';

/// An animated version of the discovery card with staggered entry.
///
/// Phase 1: Expression text fades in (0–400ms).
/// Phase 2: Context slides up + fades in, CTA appears (400–800ms).
///
/// Delegates all layout to [DiscoveryCard], passing animated values
/// for each phase. Respects reduced motion.
class DiscoveryCardAnimated extends StatefulWidget {
  /// Creates an animated [DiscoveryCardAnimated] for the given [expression].
  const DiscoveryCardAnimated({
    required this.expression,
    required this.onDismiss,
    super.key,
  });

  /// The expression to present.
  final Expression expression;

  /// Called when the user taps "J'ai compris".
  final VoidCallback onDismiss;

  @override
  State<DiscoveryCardAnimated> createState() =>
      _DiscoveryCardAnimatedState();
}

class _DiscoveryCardAnimatedState extends State<DiscoveryCardAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _textOpacity;
  late final Animation<double> _contextOpacity;
  late final Animation<Offset> _contextSlide;

  static const _totalDuration = Duration(milliseconds: 800);

  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _totalDuration,
    );

    // Phase 1: 0.0–0.5 — text fade in
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Phase 2: 0.5–1.0 — context fade + slide
    _contextOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    _contextSlide = Tween<Offset>(
      begin: const Offset(0, 8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) return;
    _hasStarted = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => DiscoveryCard(
        expression: widget.expression,
        onDismiss: widget.onDismiss,
        textOpacity: _textOpacity.value,
        contextOpacity: _contextOpacity.value,
        contextOffset: _contextSlide.value,
      ),
    );
  }
}
