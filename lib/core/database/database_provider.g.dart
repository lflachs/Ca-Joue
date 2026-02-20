// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the initialized SQLite database instance.
///
/// Opens the database, runs migrations if needed, and seeds
/// expression data on first launch.

@ProviderFor(DatabaseNotifier)
const databaseProvider = DatabaseNotifierProvider._();

/// Provides the initialized SQLite database instance.
///
/// Opens the database, runs migrations if needed, and seeds
/// expression data on first launch.
final class DatabaseNotifierProvider
    extends $AsyncNotifierProvider<DatabaseNotifier, Database> {
  /// Provides the initialized SQLite database instance.
  ///
  /// Opens the database, runs migrations if needed, and seeds
  /// expression data on first launch.
  const DatabaseNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseNotifierHash();

  @$internal
  @override
  DatabaseNotifier create() => DatabaseNotifier();
}

String _$databaseNotifierHash() => r'dbf94ced4d79c37a531126fdb373390a8d1652f7';

/// Provides the initialized SQLite database instance.
///
/// Opens the database, runs migrations if needed, and seeds
/// expression data on first launch.

abstract class _$DatabaseNotifier extends $AsyncNotifier<Database> {
  FutureOr<Database> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<Database>, Database>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Database>, Database>,
              AsyncValue<Database>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
