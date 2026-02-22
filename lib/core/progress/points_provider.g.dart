// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'points_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the user's total accumulated points in the sessions table.
///
/// Points are stored in the [Tables.sessions] singleton row (id = 1).
/// The value only increases — correct answers award +1 via [increment],
/// incorrect answers have no effect.

@ProviderFor(TotalPointsNotifier)
const totalPointsProvider = TotalPointsNotifierProvider._();

/// Manages the user's total accumulated points in the sessions table.
///
/// Points are stored in the [Tables.sessions] singleton row (id = 1).
/// The value only increases — correct answers award +1 via [increment],
/// incorrect answers have no effect.
final class TotalPointsNotifierProvider
    extends $AsyncNotifierProvider<TotalPointsNotifier, int> {
  /// Manages the user's total accumulated points in the sessions table.
  ///
  /// Points are stored in the [Tables.sessions] singleton row (id = 1).
  /// The value only increases — correct answers award +1 via [increment],
  /// incorrect answers have no effect.
  const TotalPointsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalPointsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalPointsNotifierHash();

  @$internal
  @override
  TotalPointsNotifier create() => TotalPointsNotifier();
}

String _$totalPointsNotifierHash() =>
    r'94218ba3fcae8f78c7207d598adde6d98664d4ef';

/// Manages the user's total accumulated points in the sessions table.
///
/// Points are stored in the [Tables.sessions] singleton row (id = 1).
/// The value only increases — correct answers award +1 via [increment],
/// incorrect answers have no effect.

abstract class _$TotalPointsNotifier extends $AsyncNotifier<int> {
  FutureOr<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<int>, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int>, int>,
              AsyncValue<int>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
