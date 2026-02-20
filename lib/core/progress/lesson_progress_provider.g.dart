// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the number of completed expressions for a given lesson.
///
/// A "completed" expression is one that has a row in the [Tables.progress]
/// table, meaning the user has encountered and answered it at least once.

@ProviderFor(completedCountByLesson)
const completedCountByLessonProvider = CompletedCountByLessonFamily._();

/// Returns the number of completed expressions for a given lesson.
///
/// A "completed" expression is one that has a row in the [Tables.progress]
/// table, meaning the user has encountered and answered it at least once.

final class CompletedCountByLessonProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns the number of completed expressions for a given lesson.
  ///
  /// A "completed" expression is one that has a row in the [Tables.progress]
  /// table, meaning the user has encountered and answered it at least once.
  const CompletedCountByLessonProvider._({
    required CompletedCountByLessonFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'completedCountByLessonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$completedCountByLessonHash();

  @override
  String toString() {
    return r'completedCountByLessonProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return completedCountByLesson(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedCountByLessonProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$completedCountByLessonHash() =>
    r'64c3d8cb558b0083c6ee074ac976e4f29aedda4f';

/// Returns the number of completed expressions for a given lesson.
///
/// A "completed" expression is one that has a row in the [Tables.progress]
/// table, meaning the user has encountered and answered it at least once.

final class CompletedCountByLessonFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const CompletedCountByLessonFamily._()
    : super(
        retry: null,
        name: r'completedCountByLessonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns the number of completed expressions for a given lesson.
  ///
  /// A "completed" expression is one that has a row in the [Tables.progress]
  /// table, meaning the user has encountered and answered it at least once.

  CompletedCountByLessonProvider call(String lessonId) =>
      CompletedCountByLessonProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'completedCountByLessonProvider';
}

/// Returns the number of completed expressions for a given tier.

@ProviderFor(completedCountByTier)
const completedCountByTierProvider = CompletedCountByTierFamily._();

/// Returns the number of completed expressions for a given tier.

final class CompletedCountByTierProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Returns the number of completed expressions for a given tier.
  const CompletedCountByTierProvider._({
    required CompletedCountByTierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'completedCountByTierProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$completedCountByTierHash();

  @override
  String toString() {
    return r'completedCountByTierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as int;
    return completedCountByTier(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletedCountByTierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$completedCountByTierHash() =>
    r'307ae5be984e09c0a445e27c53f221280fb7b373';

/// Returns the number of completed expressions for a given tier.

final class CompletedCountByTierFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  const CompletedCountByTierFamily._()
    : super(
        retry: null,
        name: r'completedCountByTierProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns the number of completed expressions for a given tier.

  CompletedCountByTierProvider call(int tier) =>
      CompletedCountByTierProvider._(argument: tier, from: this);

  @override
  String toString() => r'completedCountByTierProvider';
}

/// Returns whether all expressions in a tier are complete.

@ProviderFor(isTierComplete)
const isTierCompleteProvider = IsTierCompleteFamily._();

/// Returns whether all expressions in a tier are complete.

final class IsTierCompleteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Returns whether all expressions in a tier are complete.
  const IsTierCompleteProvider._({
    required IsTierCompleteFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'isTierCompleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isTierCompleteHash();

  @override
  String toString() {
    return r'isTierCompleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return isTierComplete(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsTierCompleteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isTierCompleteHash() => r'88e2d1d888de502f50cc7963d8a6dd8b7caf990d';

/// Returns whether all expressions in a tier are complete.

final class IsTierCompleteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  const IsTierCompleteFamily._()
    : super(
        retry: null,
        name: r'isTierCompleteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns whether all expressions in a tier are complete.

  IsTierCompleteProvider call(int tier) =>
      IsTierCompleteProvider._(argument: tier, from: this);

  @override
  String toString() => r'isTierCompleteProvider';
}
