import 'dart:async';

import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// A loader animation for splash and return screen.
///
/// Shows the app title "Ça joue !" with a fade-in + scale animation,
/// holds briefly, then calls [onComplete].
class LoaderAnimation extends StatefulWidget {
  /// Creates a [LoaderAnimation] with the given launch mode and callback.
  const LoaderAnimation({
    required this.isFirstLaunch,
    required this.onComplete,
    super.key,
  });

  /// Whether this is the first time the user opens the app.
  final bool isFirstLaunch;

  /// Called when the full animation sequence finishes.
  final VoidCallback onComplete;

  @override
  State<LoaderAnimation> createState() => _LoaderAnimationState();
}

class _LoaderAnimationState extends State<LoaderAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _titleController;

  @override
  void initState() {
    super.initState();

    _titleController = AnimationController(
      vsync: this,
      duration: CaJoueAnimations.loader, // 800ms
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reduceMotion = MediaQuery.of(context).disableAnimations;

      if (reduceMotion) {
        _titleController.value = 1.0;
        widget.onComplete();
        return;
      }

      unawaited(_startSequence());
    });
  }

  Future<void> _startSequence() async {
    await _titleController.forward();
    final hold = widget.isFirstLaunch ? 1200 : 600;
    await Future<void>.delayed(Duration(milliseconds: hold));
    widget.onComplete();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CaJoueColors.snow,
      child: Semantics(
        label: '\u00c7a joue ! Chargement...',
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _titleController,
              curve: CaJoueAnimations.defaultCurve,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(
                CurvedAnimation(
                  parent: _titleController,
                  curve: CaJoueAnimations.defaultCurve,
                ),
              ),
              child: Text(
                '\u00c7a joue !',
                style: CaJoueTypography.appTitle.copyWith(
                  color: CaJoueColors.slate,
                  fontSize: 52,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
