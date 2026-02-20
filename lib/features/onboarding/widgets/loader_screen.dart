import 'package:ca_joue/features/onboarding/providers/onboarding_provider.dart';
import 'package:ca_joue/features/onboarding/widgets/loader_animation.dart';
import 'package:ca_joue/features/onboarding/widgets/onboarding_screen.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Orchestrates the loader → onboarding → home flow.
///
/// Watches [onboardingProvider] to decide which screen to show.
class LoaderScreen extends ConsumerStatefulWidget {
  /// Creates a [LoaderScreen].
  const LoaderScreen({super.key});

  @override
  ConsumerState<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends ConsumerState<LoaderScreen> {
  bool _showOnboarding = false;

  void _onFirstLaunchComplete() {
    setState(() => _showOnboarding = true);
  }

  void _goHome() {
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(onboardingProvider);

    return asyncValue.when(
      loading: () => const ColoredBox(color: CaJoueColors.snow),
      error: (error, stack) => ColoredBox(
        color: CaJoueColors.snow,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Une erreur est survenue',
                style: CaJoueTypography.uiBody.copyWith(
                  color: CaJoueColors.slate,
                ),
              ),
              const SizedBox(height: CaJoueSpacing.md),
              CtaButton(
                label: 'Reessayer',
                fullWidth: false,
                onPressed: () => ref.invalidate(onboardingProvider),
              ),
            ],
          ),
        ),
      ),
      data: (isFirstLaunch) {
        if (isFirstLaunch) {
          // First launch: loader → onboarding → home
          if (_showOnboarding) {
            return const OnboardingScreen();
          }
          return LoaderAnimation(
            isFirstLaunch: true,
            onComplete: _onFirstLaunchComplete,
          );
        }

        // Return launch: short loader → home
        return LoaderAnimation(
          isFirstLaunch: false,
          onComplete: _goHome,
        );
      },
    );
  }
}
