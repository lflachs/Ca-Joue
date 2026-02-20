import 'dart:math' as math;

import 'package:ca_joue/core/content/lesson_model.dart';
import 'package:ca_joue/core/content/lesson_names.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Lucide icon for each lesson category.
final _lessonIcons = <String, IconData>{
  // Tier 1
  'everyday-greetings': LucideIcons.heartHandshake,
  'body-feelings': LucideIcons.heart,
  'daily-errands': LucideIcons.shoppingBag,
  'food-drink': LucideIcons.utensilsCrossed,
  'household-items': LucideIcons.lamp,
  'numbers-time': LucideIcons.clock3,
  'social-basics': LucideIcons.users,
  'weather-basics': LucideIcons.sun,
  // Tier 2
  'cooking-cuisine': LucideIcons.chefHat,
  'emotions-reactions': LucideIcons.smile,
  'household-cleaning': LucideIcons.sparkles,
  'informal-expressions': LucideIcons.messageCircle,
  'insults-teasing': LucideIcons.annoyed,
  'movement-actions': LucideIcons.footprints,
  'social-gatherings': LucideIcons.partyPopper,
  'weather-nature': LucideIcons.leaf,
  'workplace-school': LucideIcons.graduationCap,
  // Tier 3
  'advanced-vocabulary': LucideIcons.brain,
  'character-traits': LucideIcons.userCircle,
  'colorful-language': LucideIcons.rainbow,
  'culture-traditions': LucideIcons.flag,
  'everyday-advanced': LucideIcons.star,
  'nature-elements': LucideIcons.mountain,
  'regional-sayings': LucideIcons.scroll,
  // Tier 4
  'archaic-daily': LucideIcons.hourglass,
  'body-archaic': LucideIcons.bone,
  'forgotten-words': LucideIcons.bookOpen,
  'old-household': LucideIcons.landmark,
  'patois-heritage': LucideIcons.music,
  'rare-expressions': LucideIcons.gem,
  'rural-traditions': LucideIcons.wheat,
  'specialized-terms': LucideIcons.search,
};

/// A row representing a lesson in the lesson list screen.
class LessonRow extends StatelessWidget {
  /// Creates a [LessonRow] for the given [lesson].
  const LessonRow({
    required this.lesson,
    required this.completedCount,
    required this.onTap,
    super.key,
  });

  /// The lesson to display.
  final Lesson lesson;

  /// Number of expressions completed in this lesson.
  final int completedCount;

  /// Tap callback.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = LessonNames.of(lesson.name);
    final total = lesson.expressionCount;
    final isCompleted = completedCount >= total;
    final isStarted = completedCount > 0;
    final progress = total > 0 ? completedCount / total : 0.0;
    final status = isCompleted
        ? 'terminée'
        : isStarted
            ? 'en cours'
            : 'disponible';
    final icon = _lessonIcons[lesson.name] ?? LucideIcons.bookOpen;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: '$displayName, $total expressions, $status',
        button: onTap != null,
        excludeSemantics: true,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFFBF8F2)
                : const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(16),
            border: isCompleted
                ? Border.all(color: CaJoueColors.goldBorder)
                : null,
            boxShadow: isCompleted
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Progress ring + icon (or checkmark if completed).
              SizedBox(
                width: 52,
                height: 52,
                child: isCompleted
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CaJoueColors.gold,
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.check,
                            size: 24,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      )
                    : CustomPaint(
                        painter: _ProgressRingPainter(
                          progress: progress,
                          trackColor: CaJoueColors.cream,
                          fillColor: CaJoueColors.dusk,
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 22,
                            color: CaJoueColors.slate,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              // Name + subtitle.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: CaJoueTypography.uiBody.copyWith(
                        color: isCompleted
                            ? CaJoueColors.stone
                            : CaJoueColors.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Terminée'
                          : isStarted
                              ? '$completedCount/$total expressions'
                              : '$total expressions',
                      style: CaJoueTypography.uiCaption.copyWith(
                        color: isCompleted
                            ? CaJoueColors.gold
                            : CaJoueColors.stone,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron (only for non-completed).
              if (!isCompleted)
                Icon(
                  LucideIcons.chevronRight,
                  size: 18,
                  color: CaJoueColors.warmGrey,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a circular progress ring.
class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
  });

  final double progress;
  final Color trackColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 4) / 2;
    const strokeWidth = 3.5;

    // Track.
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Fill arc.
    if (progress > 0) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fillPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.fillColor != fillColor;
}
