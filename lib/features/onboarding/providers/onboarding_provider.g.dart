// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the onboarding/first-launch state.
///
/// Reads and writes the `first_launch_completed` flag in the sessions table.

@ProviderFor(OnboardingNotifier)
const onboardingProvider = OnboardingNotifierProvider._();

/// Manages the onboarding/first-launch state.
///
/// Reads and writes the `first_launch_completed` flag in the sessions table.
final class OnboardingNotifierProvider
    extends $AsyncNotifierProvider<OnboardingNotifier, bool> {
  /// Manages the onboarding/first-launch state.
  ///
  /// Reads and writes the `first_launch_completed` flag in the sessions table.
  const OnboardingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNotifierHash();

  @$internal
  @override
  OnboardingNotifier create() => OnboardingNotifier();
}

String _$onboardingNotifierHash() =>
    r'3a5987ba7e0474980cab4bea329b3cae1e27d17a';

/// Manages the onboarding/first-launch state.
///
/// Reads and writes the `first_launch_completed` flag in the sessions table.

abstract class _$OnboardingNotifier extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
