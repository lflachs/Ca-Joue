// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distractor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns 3 random Romand distractor strings, prioritising expressions
/// from the same lesson (same theme) so choices feel plausible, then
/// filling from the same tier if needed.

@ProviderFor(distractors)
const distractorsProvider = DistractorsFamily._();

/// Returns 3 random Romand distractor strings, prioritising expressions
/// from the same lesson (same theme) so choices feel plausible, then
/// filling from the same tier if needed.

final class DistractorsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Returns 3 random Romand distractor strings, prioritising expressions
  /// from the same lesson (same theme) so choices feel plausible, then
  /// filling from the same tier if needed.
  const DistractorsProvider._({
    required DistractorsFamily super.from,
    required Expression super.argument,
  }) : super(
         retry: null,
         name: r'distractorsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$distractorsHash();

  @override
  String toString() {
    return r'distractorsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as Expression;
    return distractors(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DistractorsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$distractorsHash() => r'15cfd234b53363b2277633287c662daa55993b97';

/// Returns 3 random Romand distractor strings, prioritising expressions
/// from the same lesson (same theme) so choices feel plausible, then
/// filling from the same tier if needed.

final class DistractorsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, Expression> {
  const DistractorsFamily._()
    : super(
        retry: null,
        name: r'distractorsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Returns 3 random Romand distractor strings, prioritising expressions
  /// from the same lesson (same theme) so choices feel plausible, then
  /// filling from the same tier if needed.

  DistractorsProvider call(Expression current) =>
      DistractorsProvider._(argument: current, from: this);

  @override
  String toString() => r'distractorsProvider';
}
