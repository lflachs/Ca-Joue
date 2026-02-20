import 'package:flutter/widgets.dart';

/// Defines standard spacing values used throughout the CaJoue app.
class CaJoueSpacing {
  const CaJoueSpacing._();

  /// Extra small spacing (4px).
  static const double xs = 4;

  /// Small spacing (8px).
  static const double sm = 8;

  /// Medium spacing (16px).
  static const double md = 16;

  /// Large spacing (24px).
  static const double lg = 24;

  /// Extra large spacing (32px).
  static const double xl = 32;

  /// Extra extra large spacing (48px).
  static const double xxl = 48;

  /// Standard horizontal screen margins (28px each side).
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 28);

  /// Full screen padding (28px horizontal, 28px vertical).
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: 28,
  );
}
