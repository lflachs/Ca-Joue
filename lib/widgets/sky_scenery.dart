import 'package:ca_joue/widgets/dahu_sprite.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Sky gradient stops — deeper blue at the top, lighter near mountains.
const _skyTop = Color(0xFF8ECAE6);
const _skyMid = Color(0xFFB8E2F0);
const _skyBottom = Color(0xFFD1F8F7);

/// A decorative background with drifting SVG clouds, parallax SVG mountains,
/// and Dahu mascot.
///
/// The [child] is placed inside a scrollable area. Scrolling drives a subtle
/// parallax on the mountain and cloud layers.
class SkyScenery extends StatefulWidget {
  /// Creates a [SkyScenery] that wraps [child] with the animated scene.
  const SkyScenery({required this.child, super.key});

  /// The foreground content layered on top of the scenery.
  final Widget child;

  @override
  State<SkyScenery> createState() => _SkySceneryState();
}

class _SkySceneryState extends State<SkyScenery> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  late final AnimationController _cloud1Controller;
  late final AnimationController _cloud2Controller;
  late final AnimationController _cloud3Controller;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    _cloud1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 55),
    )..repeat();

    _cloud2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _cloud3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 70),
    )..repeat();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _cloud1Controller.dispose();
    _cloud2Controller.dispose();
    _cloud3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mountainHeight = screenHeight * 0.35;
    final foregroundHeight = screenHeight * 0.38;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyMid, _skyBottom],
          stops: [0.0, 0.45, 0.85],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // -- Drifting clouds --
          if (!reducedMotion) ...[
            _DriftingCloud(
              controller: _cloud1Controller,
              screenWidth: screenWidth,
              top: screenHeight * 0.52 - _scrollOffset * 0.05,
              scale: 0.38,
              opacity: 0.95,
              startOffset: 0.0,
            ),
            _DriftingCloud(
              controller: _cloud2Controller,
              screenWidth: screenWidth,
              top: screenHeight * 0.72 - _scrollOffset * 0.03,
              scale: 0.22,
              opacity: 0.7,
              startOffset: 0.6,
            ),
            _DriftingCloud(
              controller: _cloud3Controller,
              screenWidth: screenWidth,
              top: screenHeight * 0.62 - _scrollOffset * 0.04,
              scale: 0.30,
              opacity: 0.8,
              startOffset: 0.33,
            ),
          ],

          // -- Mountains SVG (back layer, slower parallax) --
          Positioned(
            left: -screenWidth * 0.15,
            right: -screenWidth * 0.15,
            bottom: 10 - _scrollOffset * 0.12,
            height: mountainHeight,
            child: SvgPicture.asset(
              'assets/images/mountains.svg',
              fit: BoxFit.cover,
            ),
          ),

          // -- Foreground SVG (village/trees, faster parallax) --
          Positioned(
            left: -screenWidth * 0.05,
            right: -screenWidth * 0.1,
            bottom: 0,
            height: foregroundHeight,
            child: SvgPicture.asset(
              'assets/images/foreground.svg',
              fit: BoxFit.cover,
            ),
          ),

          // -- Animated Dahu on the landscape --
          Positioned(
            bottom: foregroundHeight * 0.02 - _scrollOffset * 0.18,
            right: screenWidth * 0.03,
            child: Transform.flip(
              flipX: true,
              child: const DahuSprite(width: 140, height: 218),
            ),
          ),

          // -- Foreground content (scrollable) --
          Positioned.fill(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single cloud that drifts horizontally across the screen in a loop.
class _DriftingCloud extends AnimatedWidget {
  const _DriftingCloud({
    required AnimationController controller,
    required this.screenWidth,
    required this.top,
    required this.scale,
    required this.opacity,
    this.startOffset = 0.0,
  }) : super(listenable: controller);

  final double screenWidth;
  final double top;
  final double scale;
  final double opacity;

  /// Horizontal start offset (0.0–1.0) so clouds don't all begin at the edge.
  final double startOffset;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as AnimationController;
    final cloudWidth = screenWidth * scale;
    final totalTravel = screenWidth + cloudWidth;
    final adjusted = (animation.value + startOffset) % 1.0;
    final xPos = -cloudWidth + adjusted * totalTravel;

    return Positioned(
      left: xPos,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: SvgPicture.asset(
          'assets/images/cloud.svg',
          width: cloudWidth,
        ),
      ),
    );
  }
}
