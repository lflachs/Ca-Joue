import 'package:ca_joue/core/spaced_repetition/review_provider.dart';
import 'package:ca_joue/features/exercise/widgets/exercise_screen.dart';
import 'package:ca_joue/features/home/widgets/home_screen.dart';
import 'package:ca_joue/features/home/widgets/lesson_list_screen.dart';
import 'package:ca_joue/features/home/widgets/reset_sheet.dart';
import 'package:ca_joue/features/onboarding/widgets/loader_screen.dart';
import 'package:ca_joue/features/placement/widgets/placement_screen.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

const _duration = Duration(milliseconds: 350);
const _curve = Curves.easeInOut;

/// iOS-style push: new page slides in from right, old page shifts left.
CustomTransitionPage<void> _iosPush({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: _duration,
    reverseTransitionDuration: _duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: _curve));
      return SlideTransition(
        position: animation.drive(slide),
        child: child,
      );
    },
  );
}

/// iOS-style modal: slides up from bottom.
CustomTransitionPage<void> _iosModal({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: _duration,
    reverseTransitionDuration: _duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      final slide = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).chain(CurveTween(curve: _curve));
      return SlideTransition(
        position: animation.drive(slide),
        child: child,
      );
    },
  );
}

/// The router configuration for the app.
final router = GoRouter(
  initialLocation: '/',
  restorationScopeId: null,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoaderScreen(),
    ),
    GoRoute(
      path: '/placement',
      pageBuilder: (context, state) {
        return _iosPush(
          key: state.pageKey,
          child: const PlacementScreen(),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        );
      },
    ),
    GoRoute(
      path: '/reset',
      pageBuilder: (context, state) {
        return CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          child: const ResetSheet(),
          transitionDuration: _duration,
          reverseTransitionDuration: _duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (MediaQuery.disableAnimationsOf(context)) return child;
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/tier/:tierNum',
      redirect: (context, state) {
        final tierNum = int.tryParse(state.pathParameters['tierNum'] ?? '');
        if (tierNum == null || tierNum < 1 || tierNum > 4) {
          return '/home';
        }
        return null;
      },
      pageBuilder: (context, state) {
        final tierNum = int.parse(state.pathParameters['tierNum']!);
        return _iosPush(
          key: state.pageKey,
          child: LessonListScreen(tierNum: tierNum),
        );
      },
    ),
    GoRoute(
      path: '/exercise/:lessonId',
      pageBuilder: (context, state) {
        final lessonId = state.pathParameters['lessonId'] ?? '';
        final startIndex =
            int.tryParse(
              state.uri.queryParameters['startIndex'] ?? '',
            ) ??
            0;
        return _iosModal(
          key: state.pageKey,
          child: ExerciseScreen(
            lessonId: lessonId,
            startIndex: startIndex,
          ),
        );
      },
    ),
    GoRoute(
      path: '/review',
      pageBuilder: (context, state) {
        return _iosModal(
          key: state.pageKey,
          child: const ExerciseScreen(
            lessonId: reviewLessonId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/practice',
      pageBuilder: (context, state) {
        return _iosModal(
          key: state.pageKey,
          child: const ExerciseScreen(
            lessonId: practiceAllLessonId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/practice/:tierNum',
      redirect: (context, state) {
        final tierNum = int.tryParse(state.pathParameters['tierNum'] ?? '');
        if (tierNum == null || tierNum < 1 || tierNum > 4) {
          return '/home';
        }
        return null;
      },
      pageBuilder: (context, state) {
        final tierNum = int.parse(state.pathParameters['tierNum']!);
        return _iosModal(
          key: state.pageKey,
          child: ExerciseScreen(
            lessonId: '$practiceLessonIdPrefix${tierNum}__',
          ),
        );
      },
    ),
  ],
);

/// The root application widget.
class App extends StatelessWidget {
  /// Creates the root application widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return CaJoueTheme(
      child: WidgetsApp.router(
        routerConfig: router,
        color: CaJoueColors.snow,
      ),
    );
  }
}
