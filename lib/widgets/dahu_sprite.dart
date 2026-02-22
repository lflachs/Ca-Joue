import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Animated Dahu mascot with a separately animated waving flag.
///
/// The character sprite sheet has 36 frames in 3 sections of 12.
/// Each cycle a random section plays back-and-forth, then pauses.
/// The flag sprite sheet (14 ping-pong frames) loops continuously.
class DahuSprite extends StatefulWidget {
  /// Creates a [DahuSprite] rendered at [width] x [height].
  const DahuSprite({
    required this.width,
    required this.height,
    super.key,
  });

  /// Display width.
  final double width;

  /// Display height.
  final double height;

  @override
  State<DahuSprite> createState() => _DahuSpriteState();
}

class _DahuSpriteState extends State<DahuSprite> with TickerProviderStateMixin {
  // -- Character sprite sheet --
  static const int _charCols = 6;
  static const int _charFrameW = 256;
  static const int _charFrameH = 399;
  static const double _charFps = 10;

  // -- Flag sprite sheet (single row) --
  static const int _flagFrames = 14;
  static const int _flagFrameW = 57;
  static const int _flagFrameH = 46;
  static const double _flagFps = 10;

  // Flag position in the 256x399 character space.
  static const double _flagX = 31.2;
  static const double _flagY = 127.0;

  // -- Sections --
  static const List<_Section> _sections = [
    _Section(0, 12),
    _Section(12, 12),
    _Section(24, 12),
  ];

  late final AnimationController _charPlayback;
  late final AnimationController _flagLoop;

  ui.Image? _charSheet;
  ui.Image? _flagSheet;
  final _rng = Random();
  bool _disposed = false;

  _Section _currentSection = _sections[0];
  _PlayPhase _phase = _PlayPhase.paused;

  @override
  void initState() {
    super.initState();
    _charPlayback = AnimationController(vsync: this);
    _flagLoop = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (_flagFrames / _flagFps * 1000).round(),
      ),
    );
    unawaited(_flagLoop.repeat());
    unawaited(_loadAssets());
  }

  Future<void> _loadAssets() async {
    final results = await Future.wait([
      _decodeAsset('assets/images/dahu_sprite.png'),
      _decodeAsset('assets/images/dahu_flag.png'),
    ]);
    if (mounted) {
      setState(() {
        _charSheet = results[0];
        _flagSheet = results[1];
      });
      unawaited(_playLoop());
    }
  }

  Future<ui.Image> _decodeAsset(String path) async {
    final data = await rootBundle.load(path);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _playLoop() async {
    await Future<void>.delayed(
      Duration(milliseconds: 1000 + _rng.nextInt(1000)),
    );
    var lastIndex = -1;
    while (!_disposed) {
      // Pick a section different from the previous one.
      var pick = _rng.nextInt(_sections.length);
      while (pick == lastIndex) {
        pick = _rng.nextInt(_sections.length);
      }
      lastIndex = pick;
      final section = _sections[pick];
      final sectionDur = Duration(
        milliseconds: (section.length / _charFps * 1000).round(),
      );

      // Forward through the section.
      setState(() {
        _currentSection = section;
        _phase = _PlayPhase.forward;
      });
      _charPlayback.duration = sectionDur;
      await _charPlayback.forward(from: 0);
      if (_disposed) return;

      // Reverse back to section start.
      setState(() => _phase = _PlayPhase.reverse);
      await _charPlayback.forward(from: 0);
      if (_disposed) return;

      // Ease back to frame 0 (if section doesn't start at 0).
      if (section.start > 0) {
        final returnDur = Duration(
          milliseconds: (section.start / _charFps * 1000).round(),
        );
        setState(() => _phase = _PlayPhase.returning);
        _charPlayback.duration = returnDur;
        await _charPlayback.forward(
          from: 0,
        );
        if (_disposed) return;
      }

      // Pause on idle.
      setState(() => _phase = _PlayPhase.paused);
      final pause = 4000 + _rng.nextInt(3000);
      await Future<void>.delayed(Duration(milliseconds: pause));
    }
  }

  int get _charFrame {
    switch (_phase) {
      case _PlayPhase.paused:
        return 0;
      case _PlayPhase.forward:
        final t = _charPlayback.value.clamp(0.0, 0.999);
        final local = (t * _currentSection.length).floor();
        return _currentSection.start + local;
      case _PlayPhase.reverse:
        final t = _charPlayback.value.clamp(0.0, 0.999);
        final local = (t * _currentSection.length).floor();
        return _currentSection.start + _currentSection.length - 1 - local;
      case _PlayPhase.returning:
        // Ease from section start back to frame 0.
        final t = Curves.easeOut.transform(
          _charPlayback.value.clamp(0.0, 0.999),
        );
        final remaining = _currentSection.start;
        return (remaining - (t * remaining).floor()).clamp(0, 35);
    }
  }

  int get _flagFrame {
    final t = _flagLoop.value.clamp(0.0, 0.999);
    return (t * _flagFrames).floor();
  }

  @override
  void dispose() {
    _disposed = true;
    _charPlayback.dispose();
    _flagLoop.dispose();
    _charSheet?.dispose();
    _flagSheet?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = widget.height;

    if (_charSheet == null || _flagSheet == null) {
      return SizedBox(width: w, height: h);
    }

    final reducedMotion = MediaQuery.disableAnimationsOf(context);

    return AnimatedBuilder(
      animation: reducedMotion
          ? _charPlayback
          : Listenable.merge([_charPlayback, _flagLoop]),
      builder: (context, _) {
        return CustomPaint(
          size: Size(w, h),
          painter: _DahuPainter(
            charSheet: _charSheet!,
            flagSheet: _flagSheet!,
            charFrame: reducedMotion ? 0 : _charFrame,
            flagFrame: reducedMotion ? 0 : _flagFrame,
          ),
        );
      },
    );
  }
}

enum _PlayPhase { forward, reverse, returning, paused }

class _Section {
  const _Section(this.start, this.length);
  final int start;
  final int length;
}

class _DahuPainter extends CustomPainter {
  _DahuPainter({
    required this.charSheet,
    required this.flagSheet,
    required this.charFrame,
    required this.flagFrame,
  });

  final ui.Image charSheet;
  final ui.Image flagSheet;
  final int charFrame;
  final int flagFrame;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final scaleX = size.width / _DahuSpriteState._charFrameW;
    final scaleY = size.height / _DahuSpriteState._charFrameH;

    // -- Draw character frame --
    final cCol = charFrame % _DahuSpriteState._charCols;
    final cRow = charFrame ~/ _DahuSpriteState._charCols;
    final charSrc = Rect.fromLTWH(
      (cCol * _DahuSpriteState._charFrameW).toDouble(),
      (cRow * _DahuSpriteState._charFrameH).toDouble(),
      _DahuSpriteState._charFrameW.toDouble(),
      _DahuSpriteState._charFrameH.toDouble(),
    );
    canvas.drawImageRect(charSheet, charSrc, Offset.zero & size, paint);

    // -- Draw flag frame --
    final flagSrc = Rect.fromLTWH(
      (flagFrame * _DahuSpriteState._flagFrameW).toDouble(),
      0,
      _DahuSpriteState._flagFrameW.toDouble(),
      _DahuSpriteState._flagFrameH.toDouble(),
    );
    final flagDst = Rect.fromLTWH(
      _DahuSpriteState._flagX * scaleX,
      _DahuSpriteState._flagY * scaleY,
      _DahuSpriteState._flagFrameW * scaleX,
      _DahuSpriteState._flagFrameH * scaleY,
    );
    canvas.drawImageRect(flagSheet, flagSrc, flagDst, paint);
  }

  @override
  bool shouldRepaint(_DahuPainter old) =>
      charFrame != old.charFrame || flagFrame != old.flagFrame;
}
