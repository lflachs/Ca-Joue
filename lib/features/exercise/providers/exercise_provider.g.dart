// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the exercise flow state machine for a given lesson.
///
/// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
/// start, or a saved index to resume where the user left off.

@ProviderFor(ExerciseNotifier)
const exerciseProvider = ExerciseNotifierFamily._();

/// Manages the exercise flow state machine for a given lesson.
///
/// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
/// start, or a saved index to resume where the user left off.
final class ExerciseNotifierProvider
    extends $AsyncNotifierProvider<ExerciseNotifier, ExerciseState> {
  /// Manages the exercise flow state machine for a given lesson.
  ///
  /// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
  /// start, or a saved index to resume where the user left off.
  const ExerciseNotifierProvider._({
    required ExerciseNotifierFamily super.from,
    required (String, int) super.argument,
  }) : super(
         retry: null,
         name: r'exerciseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseNotifierHash();

  @override
  String toString() {
    return r'exerciseProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ExerciseNotifier create() => ExerciseNotifier();

  @override
  bool operator ==(Object other) {
    return other is ExerciseNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseNotifierHash() => r'4cebd738626f47d51cd6342bbbb58fa8b5cd1d4a';

/// Manages the exercise flow state machine for a given lesson.
///
/// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
/// start, or a saved index to resume where the user left off.

final class ExerciseNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ExerciseNotifier,
          AsyncValue<ExerciseState>,
          ExerciseState,
          FutureOr<ExerciseState>,
          (String, int)
        > {
  const ExerciseNotifierFamily._()
    : super(
        retry: null,
        name: r'exerciseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages the exercise flow state machine for a given lesson.
  ///
  /// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
  /// start, or a saved index to resume where the user left off.

  ExerciseNotifierProvider call(String lessonId, int startIndex) =>
      ExerciseNotifierProvider._(argument: (lessonId, startIndex), from: this);

  @override
  String toString() => r'exerciseProvider';
}

/// Manages the exercise flow state machine for a given lesson.
///
/// The [startIndex] parameter supports mid-lesson resume: 0 for a fresh
/// start, or a saved index to resume where the user left off.

abstract class _$ExerciseNotifier extends $AsyncNotifier<ExerciseState> {
  late final _$args = ref.$arg as (String, int);
  String get lessonId => _$args.$1;
  int get startIndex => _$args.$2;

  FutureOr<ExerciseState> build(String lessonId, int startIndex);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref = this.ref as $Ref<AsyncValue<ExerciseState>, ExerciseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExerciseState>, ExerciseState>,
              AsyncValue<ExerciseState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
