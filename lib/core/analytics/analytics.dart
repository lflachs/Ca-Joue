import 'package:firebase_analytics/firebase_analytics.dart';

/// Lightweight wrapper around Firebase Analytics for app-specific events.
abstract final class Analytics {
  static final FirebaseAnalytics _instance = FirebaseAnalytics.instance;

  /// User started a lesson.
  static Future<void> lessonStarted({
    required String lessonId,
    required int tier,
  }) =>
      _instance.logEvent(
        name: 'lesson_started',
        parameters: {'lesson_id': lessonId, 'tier': tier},
      );

  /// User completed a lesson.
  static Future<void> lessonCompleted({
    required String lessonId,
    required int expressionsCount,
  }) =>
      _instance.logEvent(
        name: 'lesson_completed',
        parameters: {
          'lesson_id': lessonId,
          'expressions_count': expressionsCount,
        },
      );

  /// User started a review session.
  static Future<void> reviewStarted({required int dueCount}) =>
      _instance.logEvent(
        name: 'review_started',
        parameters: {'due_count': dueCount},
      );

  /// User started a practice session.
  static Future<void> practiceStarted({String? tier}) => _instance.logEvent(
        name: 'practice_started',
        parameters: {'tier': tier ?? 'all'},
      );

  /// User answered an exercise.
  static Future<void> exerciseAnswered({
    required String lessonId,
    required bool isCorrect,
    required String exerciseType,
  }) =>
      _instance.logEvent(
        name: 'exercise_answered',
        parameters: {
          'lesson_id': lessonId,
          'is_correct': isCorrect ? 1 : 0,
          'exercise_type': exerciseType,
        },
      );

  /// User completed onboarding.
  static Future<void> onboardingCompleted() =>
      _instance.logEvent(name: 'onboarding_completed');

  /// User reached a streak milestone.
  static Future<void> streakMilestone({required int days}) =>
      _instance.logEvent(
        name: 'streak_milestone',
        parameters: {'days': days},
      );

  /// User completed the placement test.
  static Future<void> placementCompleted({
    required int placedTier,
    required int totalCorrect,
    required int totalQuestions,
  }) =>
      _instance.logEvent(
        name: 'placement_completed',
        parameters: {
          'placed_tier': placedTier,
          'total_correct': totalCorrect,
          'total_questions': totalQuestions,
        },
      );
}
