// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discovery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns `true` if the expression has never been encountered before.
///
/// Checks the [Tables.progress] table for the given [expressionId].
/// No row means the user has never interacted with this expression.

@ProviderFor(isFirstEncounter)
const isFirstEncounterProvider = IsFirstEncounterFamily._();

/// Returns `true` if the expression has never been encountered before.
///
/// Checks the [Tables.progress] table for the given [expressionId].
/// No row means the user has never interacted with this expression.

final class IsFirstEncounterProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Returns `true` if the expression has never been encountered before.
  ///
  /// Checks the [Tables.progress] table for the given [expressionId].
  /// No row means the user has never interacted with this expression.
  const IsFirstEncounterProvider._({
    required IsFirstEncounterFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFirstEncounterProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFirstEncounterHash();

  @override
  String toString() {
    return r'isFirstEncounterProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isFirstEncounter(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFirstEncounterProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFirstEncounterHash() => r'3661cd651388ef52b07de726aafebd9acd98f8b5';

/// Returns `true` if the expression has never been encountered before.
///
/// Checks the [Tables.progress] table for the given [expressionId].
/// No row means the user has never interacted with this expression.

final class IsFirstEncounterFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  const IsFirstEncounterFamily._()
    : super(
        retry: null,
        name: r'isFirstEncounterProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns `true` if the expression has never been encountered before.
  ///
  /// Checks the [Tables.progress] table for the given [expressionId].
  /// No row means the user has never interacted with this expression.

  IsFirstEncounterProvider call(String expressionId) =>
      IsFirstEncounterProvider._(argument: expressionId, from: this);

  @override
  String toString() => r'isFirstEncounterProvider';
}
