// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the user's daily learning streak in the sessions table.
///
/// Streak data is stored in the [Tables.sessions] singleton row (id = 1).
/// Call [recordSession] when a lesson or review session completes.

@ProviderFor(StreakNotifier)
const streakProvider = StreakNotifierProvider._();

/// Manages the user's daily learning streak in the sessions table.
///
/// Streak data is stored in the [Tables.sessions] singleton row (id = 1).
/// Call [recordSession] when a lesson or review session completes.
final class StreakNotifierProvider
    extends
        $AsyncNotifierProvider<
          StreakNotifier,
          ({int count, String? lastDate})
        > {
  /// Manages the user's daily learning streak in the sessions table.
  ///
  /// Streak data is stored in the [Tables.sessions] singleton row (id = 1).
  /// Call [recordSession] when a lesson or review session completes.
  const StreakNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakNotifierHash();

  @$internal
  @override
  StreakNotifier create() => StreakNotifier();
}

String _$streakNotifierHash() => r'89a1fb97209b7e3f26c1586fa2fc1e18c8e3ca26';

/// Manages the user's daily learning streak in the sessions table.
///
/// Streak data is stored in the [Tables.sessions] singleton row (id = 1).
/// Call [recordSession] when a lesson or review session completes.

abstract class _$StreakNotifier
    extends $AsyncNotifier<({int count, String? lastDate})> {
  FutureOr<({int count, String? lastDate})> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<({int count, String? lastDate})>,
              ({int count, String? lastDate})
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<({int count, String? lastDate})>,
                ({int count, String? lastDate})
              >,
              AsyncValue<({int count, String? lastDate})>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
