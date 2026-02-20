import 'package:ca_joue/core/database/tables.dart';
import 'package:sqflite/sqflite.dart';

/// Version-based database migrations.
///
/// Each version adds incremental schema changes. Migrations run
/// sequentially from `oldVersion` to `newVersion`.
abstract final class Migrations {
  /// Runs all migrations from [oldVersion] to [newVersion].
  static Future<void> runAll(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (var version = oldVersion + 1; version <= newVersion; version++) {
      await _migrate(db, version);
    }
  }

  static Future<void> _migrate(Database db, int version) async {
    switch (version) {
      case 1:
        await _v1(db);
      default:
        throw ArgumentError('Unknown migration version: $version');
    }
  }

  /// Version 1: Create initial schema.
  static Future<void> _v1(Database db) async {
    await db.execute(Tables.createExpressions);
    await db.execute(Tables.createProgress);
    await db.execute(Tables.createSessions);
  }
}
