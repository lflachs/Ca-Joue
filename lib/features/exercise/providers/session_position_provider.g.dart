// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_position_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the current lesson position for mid-lesson resume.
///
/// Reads and writes the `current_lesson_position` column in the
/// `sessions` singleton table. Format: `"lessonId:expressionIndex"`.

@ProviderFor(SessionPositionNotifier)
const sessionPositionProvider = SessionPositionNotifierProvider._();

/// Manages the current lesson position for mid-lesson resume.
///
/// Reads and writes the `current_lesson_position` column in the
/// `sessions` singleton table. Format: `"lessonId:expressionIndex"`.
final class SessionPositionNotifierProvider
    extends $AsyncNotifierProvider<SessionPositionNotifier, String?> {
  /// Manages the current lesson position for mid-lesson resume.
  ///
  /// Reads and writes the `current_lesson_position` column in the
  /// `sessions` singleton table. Format: `"lessonId:expressionIndex"`.
  const SessionPositionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionPositionNotifierHash();

  @$internal
  @override
  SessionPositionNotifier create() => SessionPositionNotifier();
}

String _$sessionPositionNotifierHash() =>
    r'a2cb4134c86a04b0207d63246fe12f5fa5caa583';

/// Manages the current lesson position for mid-lesson resume.
///
/// Reads and writes the `current_lesson_position` column in the
/// `sessions` singleton table. Format: `"lessonId:expressionIndex"`.

abstract class _$SessionPositionNotifier extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
