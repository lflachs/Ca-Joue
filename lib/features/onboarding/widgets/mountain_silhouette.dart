import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';

/// Decorative mountain silhouette for the onboarding screen background.
///
/// Two-layer composition: cream foreground (180px) and warm-grey
/// background (140px at 0.15 opacity), positioned at the bottom.
class MountainSilhouette extends StatelessWidget {
  /// Creates a [MountainSilhouette] decorative background.
  const MountainSilhouette({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      excludeSemantics: true,
      child: const Stack(
        children: [
          // Background layer — warm-grey, shorter, behind
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140,
            child: Opacity(
              opacity: 0.15,
              child: ClipPath(
                clipper: _MountainClipper(variant: _MountainVariant.back),
                child: ColoredBox(color: CaJoueColors.warmGrey),
              ),
            ),
          ),
          // Foreground layer — cream, taller, in front
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 180,
            child: ClipPath(
              clipper: _MountainClipper(variant: _MountainVariant.front),
              child: ColoredBox(color: CaJoueColors.cream),
            ),
          ),
        ],
      ),
    );
  }
}

/// Which mountain layer to draw.
enum _MountainVariant { front, back }

/// Clips a widget to an alpine mountain silhouette shape.
class _MountainClipper extends CustomClipper<Path> {
  const _MountainClipper({required this.variant});

  final _MountainVariant variant;

  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at bottom-left.
    path.moveTo(0, h);

    if (variant == _MountainVariant.front) {
      // Foreground: gentle rolling peaks.
      path
        ..lineTo(0, h * 0.65)
        ..quadraticBezierTo(w * 0.12, h * 0.30, w * 0.25, h * 0.35)
        ..quadraticBezierTo(w * 0.38, h * 0.40, w * 0.45, h * 0.20)
        ..quadraticBezierTo(w * 0.52, h * 0.0, w * 0.62, h * 0.25)
        ..quadraticBezierTo(w * 0.72, h * 0.50, w * 0.80, h * 0.30)
        ..quadraticBezierTo(w * 0.90, h * 0.10, w, h * 0.45);
    } else {
      // Background: offset peaks for depth.
      path
        ..lineTo(0, h * 0.50)
        ..quadraticBezierTo(w * 0.15, h * 0.15, w * 0.30, h * 0.30)
        ..quadraticBezierTo(w * 0.42, h * 0.42, w * 0.55, h * 0.10)
        ..quadraticBezierTo(w * 0.68, h * 0.0, w * 0.78, h * 0.35)
        ..quadraticBezierTo(w * 0.88, h * 0.55, w, h * 0.30);
    }

    // Close along the bottom.
    path
      ..lineTo(w, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant _MountainClipper oldClipper) =>
      variant != oldClipper.variant;
}
