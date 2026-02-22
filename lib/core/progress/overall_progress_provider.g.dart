// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overall_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the total number of expressions the user has completed.
///
/// A "completed" expression is one with a row in the [Tables.progress]
/// table. Since [Tables.progExpressionId] is the primary key, no
/// duplicates are possible.

@ProviderFor(totalCompletedExpressions)
const totalCompletedExpressionsProvider = TotalCompletedExpressionsProvider._();

/// Returns the total number of expressions the user has completed.
///
/// A "completed" expression is one with a row in the [Tables.progress]
/// table. Since [Tables.progExpressionId] is the primary key, no
/// duplicates are possible.

final class TotalCompletedExpressionsProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns the total number of expressions the user has completed.
  ///
  /// A "completed" expression is one with a row in the [Tables.progress]
  /// table. Since [Tables.progExpressionId] is the primary key, no
  /// duplicates are possible.
  const TotalCompletedExpressionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalCompletedExpressionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalCompletedExpressionsHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalCompletedExpressions(ref);
  }
}

String _$totalCompletedExpressionsHash() =>
    r'582a0b4d5cd9c40d5052f265fe0d628833e0f980';
