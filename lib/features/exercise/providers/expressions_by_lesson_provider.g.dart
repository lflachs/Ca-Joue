// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expressions_by_lesson_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides all expressions for a given lesson ID.

@ProviderFor(expressionsByLesson)
const expressionsByLessonProvider = ExpressionsByLessonFamily._();

/// Provides all expressions for a given lesson ID.

final class ExpressionsByLessonProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expression>>,
          List<Expression>,
          FutureOr<List<Expression>>
        >
    with $FutureModifier<List<Expression>>, $FutureProvider<List<Expression>> {
  /// Provides all expressions for a given lesson ID.
  const ExpressionsByLessonProvider._({
    required ExpressionsByLessonFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'expressionsByLessonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expressionsByLessonHash();

  @override
  String toString() {
    return r'expressionsByLessonProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Expression>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Expression>> create(Ref ref) {
    final argument = this.argument as String;
    return expressionsByLesson(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpressionsByLessonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expressionsByLessonHash() =>
    r'53de0f1800eb002c645c56b053f244bf709ceb0f';

/// Provides all expressions for a given lesson ID.

final class ExpressionsByLessonFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Expression>>, String> {
  const ExpressionsByLessonFamily._()
    : super(
        retry: null,
        name: r'expressionsByLessonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides all expressions for a given lesson ID.

  ExpressionsByLessonProvider call(String lessonId) =>
      ExpressionsByLessonProvider._(argument: lessonId, from: this);

  @override
  String toString() => r'expressionsByLessonProvider';
}
