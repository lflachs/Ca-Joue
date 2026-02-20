import 'package:flutter/widgets.dart';

export 'ca_joue_animations.dart';
export 'ca_joue_colors.dart';
export 'ca_joue_spacing.dart';
export 'ca_joue_typography.dart';

/// Provides CaJoue design tokens to the widget tree via [InheritedWidget].
///
/// Wrap the app in [CaJoueTheme] and access tokens via the static token
/// classes (CaJoueColors, CaJoueTypography, CaJoueSpacing, CaJoueAnimations).
///
/// Use `CaJoueTheme.of(context)` to verify the theme is present in the tree.
class CaJoueTheme extends InheritedWidget {
  /// Creates a [CaJoueTheme] that provides design tokens to descendants.
  const CaJoueTheme({required super.child, super.key});

  /// Retrieves the nearest [CaJoueTheme] from the widget tree.
  ///
  /// Throws if no [CaJoueTheme] ancestor is found.
  static CaJoueTheme of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<CaJoueTheme>();
    assert(result != null, 'No CaJoueTheme found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(CaJoueTheme oldWidget) => false;
}
