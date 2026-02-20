import 'package:flutter/widgets.dart';

/// Defines animation durations, curves, and border radius tokens for CaJoue.
class CaJoueAnimations {
  const CaJoueAnimations._();

  /// Quick UI response (250ms).
  static const Duration fast = Duration(milliseconds: 250);

  /// Tactile feedback duration (300ms).
  static const Duration feedback = Duration(milliseconds: 300);

  /// Layout/structural change duration (400ms).
  static const Duration structural = Duration(milliseconds: 400);

  /// Loading indicator cycle (800ms).
  static const Duration loader = Duration(milliseconds: 800);

  /// Ambient/background animation (2500ms).
  static const Duration ambient = Duration(milliseconds: 2500);

  /// Default easing curve for most animations.
  static const Curve defaultCurve = Curves.easeOut;

  /// Easing curve for ambient/looping animations.
  static const Curve ambientCurve = Curves.easeInOut;

  /// Border radius for buttons.
  static const double buttonRadius = 14;

  /// Border radius for badges.
  static const double badgeRadius = 24;
}
