import 'package:flutter/widgets.dart';

/// Size variants for the [Dahu] mascot widget.
enum DahuSize {
  /// The size of the Dahu widget for the onboarding screen.
  onboarding(width: 140, height: 168),

  /// The size of the Dahu widget for the home screen.
  home(width: 44, height: 53),

  /// The size of the Dahu widget for the exercise screen.
  exercise(width: 90, height: 108),

  /// The size of the Dahu widget for the correct feedback screen.
  correctFeedback(width: 120, height: 144),

  /// The size of the Dahu widget for the wrong feedback screen.
  wrongFeedback(width: 60, height: 72),

  /// The size of the Dahu widget for the completion screen.
  completion(width: 160, height: 192);

  const DahuSize({required this.width, required this.height});

  /// The width of the Dahu widget.
  final double width;

  /// The height of the Dahu widget.
  final double height;
}

/// Displays the Dahu mascot.
///
/// Renders the Dahu illustration at the given [size].
/// Hidden from screen readers via [Semantics.excludeSemantics].
class Dahu extends StatelessWidget {
  /// Creates a [Dahu] with the given [size] and optional [animate] flag.
  const Dahu({required this.size, this.animate = false, super.key});

  /// Which size variant to render.
  final DahuSize size;

  /// Whether to play the appear animation (fade-in + scale from 0.8).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: Image.asset(
        'assets/images/dahu.png',
        width: size.width,
        height: size.height,
        fit: BoxFit.contain,
      ),
    );
  }
}
