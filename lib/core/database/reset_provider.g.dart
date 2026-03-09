// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides reset operations for user progress.

@ProviderFor(ResetNotifier)
const resetProvider = ResetNotifierProvider._();

/// Provides reset operations for user progress.
final class ResetNotifierProvider
    extends $NotifierProvider<ResetNotifier, void> {
  /// Provides reset operations for user progress.
  const ResetNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetNotifierHash();

  @$internal
  @override
  ResetNotifier create() => ResetNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$resetNotifierHash() => r'3d35f5f1f9bc1a75f41caaf4b2bc9dfaaeb85b84';

/// Provides reset operations for user progress.

abstract class _$ResetNotifier extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
