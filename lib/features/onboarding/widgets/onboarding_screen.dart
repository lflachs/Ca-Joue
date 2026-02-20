import 'package:ca_joue/features/onboarding/providers/onboarding_provider.dart';
import 'package:ca_joue/features/onboarding/widgets/mountain_silhouette.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:ca_joue/widgets/dahu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The onboarding screen shown on first launch after the loader.
class OnboardingScreen extends ConsumerWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const SizedBox.expand(child: ColoredBox(color: CaJoueColors.snow)),
        const SizedBox.expand(child: MountainSilhouette()),
        SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Dahu(size: DahuSize.onboarding),
                const SizedBox(height: CaJoueSpacing.lg),
                CtaButton(
                  label: 'Commencer',
                  fullWidth: false,
                  onPressed: () async {
                    await ref
                        .read(onboardingProvider.notifier)
                        .completeOnboarding();
                    if (context.mounted) context.go('/home');
                  },
                ),
                const SizedBox(height: CaJoueSpacing.sm),
                Text(
                  'Pas de compte requis',
                  style: CaJoueTypography.uiBody.copyWith(
                    color: CaJoueColors.stone,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
