// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the count of expressions currently due for review.
///
/// An expression is due when its next review date is in the past
/// or today. Returns 0 when no expressions need review.

@ProviderFor(dueExpressionCount)
const dueExpressionCountProvider = DueExpressionCountProvider._();

/// Returns the count of expressions currently due for review.
///
/// An expression is due when its next review date is in the past
/// or today. Returns 0 when no expressions need review.

final class DueExpressionCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns the count of expressions currently due for review.
  ///
  /// An expression is due when its next review date is in the past
  /// or today. Returns 0 when no expressions need review.
  const DueExpressionCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueExpressionCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueExpressionCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return dueExpressionCount(ref);
  }
}

String _$dueExpressionCountHash() =>
    r'ef14d20122c29400e6afafbccdd286f4d989cd28';

/// Returns expressions due for review, ordered by most overdue first.
///
/// Joins the expressions table with the progress table to get full
/// [Expression] objects for expressions whose review date has passed.
/// Results are ordered by next review date ascending so the most
/// overdue expressions appear first in the review session.

@ProviderFor(dueExpressions)
const dueExpressionsProvider = DueExpressionsProvider._();

/// Returns expressions due for review, ordered by most overdue first.
///
/// Joins the expressions table with the progress table to get full
/// [Expression] objects for expressions whose review date has passed.
/// Results are ordered by next review date ascending so the most
/// overdue expressions appear first in the review session.

final class DueExpressionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expression>>,
          List<Expression>,
          FutureOr<List<Expression>>
        >
    with $FutureModifier<List<Expression>>, $FutureProvider<List<Expression>> {
  /// Returns expressions due for review, ordered by most overdue first.
  ///
  /// Joins the expressions table with the progress table to get full
  /// [Expression] objects for expressions whose review date has passed.
  /// Results are ordered by next review date ascending so the most
  /// overdue expressions appear first in the review session.
  const DueExpressionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dueExpressionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dueExpressionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Expression>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Expression>> create(Ref ref) {
    return dueExpressions(ref);
  }
}

String _$dueExpressionsHash() => r'5cc3c1cf8fa96e7e0509043dafdda0b03edbe2eb';
