// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'placement_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the placement test state.
///
/// Picks 4 random expressions per tier (16 total), all typing-based.
/// Includes a "skip" action so the user can say "je ne sais pas".

@ProviderFor(PlacementNotifier)
const placementProvider = PlacementNotifierProvider._();

/// Manages the placement test state.
///
/// Picks 4 random expressions per tier (16 total), all typing-based.
/// Includes a "skip" action so the user can say "je ne sais pas".
final class PlacementNotifierProvider
    extends $AsyncNotifierProvider<PlacementNotifier, PlacementState> {
  /// Manages the placement test state.
  ///
  /// Picks 4 random expressions per tier (16 total), all typing-based.
  /// Includes a "skip" action so the user can say "je ne sais pas".
  const PlacementNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'placementProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$placementNotifierHash();

  @$internal
  @override
  PlacementNotifier create() => PlacementNotifier();
}

String _$placementNotifierHash() => r'5520c2fd7d0161f450229de2fe71c5d09ae2c4dd';

/// Manages the placement test state.
///
/// Picks 4 random expressions per tier (16 total), all typing-based.
/// Includes a "skip" action so the user can say "je ne sais pas".

abstract class _$PlacementNotifier extends $AsyncNotifier<PlacementState> {
  FutureOr<PlacementState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PlacementState>, PlacementState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PlacementState>, PlacementState>,
              AsyncValue<PlacementState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
