import 'package:ca_joue/core/database/reset_provider.dart';
import 'package:ca_joue/theme/ca_joue_theme.dart';
import 'package:ca_joue/widgets/cta_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A bottom sheet with reset options.
class ResetSheet extends ConsumerStatefulWidget {
  /// Creates a [ResetSheet].
  const ResetSheet({super.key});

  @override
  ConsumerState<ResetSheet> createState() => _ResetSheetState();
}

class _ResetSheetState extends ConsumerState<ResetSheet> {
  bool _confirmingReset = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tapping the overlay background closes.
      onTap: () => context.pop(),
      child: ColoredBox(
        color: const Color(0x66000000),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            // Prevent taps on the sheet from closing.
            onTap: () {},
            child: SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(CaJoueSpacing.md),
                padding: const EdgeInsets.all(CaJoueSpacing.lg),
                decoration: BoxDecoration(
                  color: CaJoueColors.snow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar.
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: CaJoueColors.warmGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: CaJoueSpacing.lg),
                    _SheetButton(
                      label: 'Refaire le test de placement',
                      onTap: () async {
                        await ref
                            .read(resetProvider.notifier)
                            .resetPlacement();
                        if (context.mounted) context.go('/');
                      },
                    ),
                    const SizedBox(height: CaJoueSpacing.sm),
                    if (!_confirmingReset)
                      _SheetButton(
                        label: 'Tout recommencer',
                        isDestructive: true,
                        onTap: () => setState(() => _confirmingReset = true),
                      )
                    else
                      _SheetButton(
                        label: 'Confirmer la remise à zéro',
                        isDestructive: true,
                        onTap: () async {
                          await ref.read(resetProvider.notifier).resetAll();
                          if (context.mounted) context.go('/');
                        },
                      ),
                    const SizedBox(height: CaJoueSpacing.md),
                    CtaButton(
                      label: 'Annuler',
                      fullWidth: true,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: CaJoueColors.cream,
          borderRadius: BorderRadius.circular(CaJoueAnimations.buttonRadius),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: CaJoueTypography.uiButton.copyWith(
            color: isDestructive ? CaJoueColors.red : CaJoueColors.slate,
          ),
        ),
      ),
    );
  }
}
