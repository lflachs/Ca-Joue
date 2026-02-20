// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides all expressions from the database.

@ProviderFor(allExpressions)
const allExpressionsProvider = AllExpressionsProvider._();

/// Provides all expressions from the database.

final class AllExpressionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expression>>,
          List<Expression>,
          FutureOr<List<Expression>>
        >
    with $FutureModifier<List<Expression>>, $FutureProvider<List<Expression>> {
  /// Provides all expressions from the database.
  const AllExpressionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allExpressionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allExpressionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Expression>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Expression>> create(Ref ref) {
    return allExpressions(ref);
  }
}

String _$allExpressionsHash() => r'f0792012d65ad1713a0949c07bd717787f484afd';

/// Provides expressions filtered by tier.

@ProviderFor(expressionsByTier)
const expressionsByTierProvider = ExpressionsByTierFamily._();

/// Provides expressions filtered by tier.

final class ExpressionsByTierProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expression>>,
          List<Expression>,
          FutureOr<List<Expression>>
        >
    with $FutureModifier<List<Expression>>, $FutureProvider<List<Expression>> {
  /// Provides expressions filtered by tier.
  const ExpressionsByTierProvider._({
    required ExpressionsByTierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'expressionsByTierProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$expressionsByTierHash();

  @override
  String toString() {
    return r'expressionsByTierProvider'
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
    final argument = this.argument as int;
    return expressionsByTier(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExpressionsByTierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$expressionsByTierHash() => r'b3e5afb1296d50cb1d9f31e03db33f6b7cef172a';

/// Provides expressions filtered by tier.

final class ExpressionsByTierFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Expression>>, int> {
  const ExpressionsByTierFamily._()
    : super(
        retry: null,
        name: r'expressionsByTierProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides expressions filtered by tier.

  ExpressionsByTierProvider call(int tier) =>
      ExpressionsByTierProvider._(argument: tier, from: this);

  @override
  String toString() => r'expressionsByTierProvider';
}

/// Provides lessons grouped by expressions within a tier.

@ProviderFor(lessonsByTier)
const lessonsByTierProvider = LessonsByTierFamily._();

/// Provides lessons grouped by expressions within a tier.

final class LessonsByTierProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Lesson>>,
          List<Lesson>,
          FutureOr<List<Lesson>>
        >
    with $FutureModifier<List<Lesson>>, $FutureProvider<List<Lesson>> {
  /// Provides lessons grouped by expressions within a tier.
  const LessonsByTierProvider._({
    required LessonsByTierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'lessonsByTierProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lessonsByTierHash();

  @override
  String toString() {
    return r'lessonsByTierProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Lesson>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Lesson>> create(Ref ref) {
    final argument = this.argument as int;
    return lessonsByTier(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LessonsByTierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lessonsByTierHash() => r'9c31fcae5b39140905ec77d06464cc417fcaf21a';

/// Provides lessons grouped by expressions within a tier.

final class LessonsByTierFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Lesson>>, int> {
  const LessonsByTierFamily._()
    : super(
        retry: null,
        name: r'lessonsByTierProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provides lessons grouped by expressions within a tier.

  LessonsByTierProvider call(int tier) =>
      LessonsByTierProvider._(argument: tier, from: this);

  @override
  String toString() => r'lessonsByTierProvider';
}

/// Provides all tiers with their lessons and unlock state.

@ProviderFor(allTiers)
const allTiersProvider = AllTiersProvider._();

/// Provides all tiers with their lessons and unlock state.

final class AllTiersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tier>>,
          List<Tier>,
          FutureOr<List<Tier>>
        >
    with $FutureModifier<List<Tier>>, $FutureProvider<List<Tier>> {
  /// Provides all tiers with their lessons and unlock state.
  const AllTiersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allTiersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allTiersHash();

  @$internal
  @override
  $FutureProviderElement<List<Tier>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tier>> create(Ref ref) {
    return allTiers(ref);
  }
}

String _$allTiersHash() => r'a0bee80743b1f7e4edfae1b2d4071d2ef711be97';
