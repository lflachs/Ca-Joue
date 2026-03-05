import 'package:ca_joue/core/database/seed_data.dart';
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
      case 2:
        await _v2(db);
      case 3:
        await _v3(db);
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

  /// Version 2: Add sentences column to expressions.
  static Future<void> _v2(Database db) async {
    // Check if the column already exists (fresh installs get it from v1).
    final columns = await db.rawQuery(
      'PRAGMA table_info(${Tables.expressions})',
    );
    final hasColumn = columns.any(
      (c) => c['name'] == Tables.exprSentences,
    );
    if (!hasColumn) {
      await db.execute(
        'ALTER TABLE ${Tables.expressions} '
        "ADD COLUMN ${Tables.exprSentences} TEXT NOT NULL DEFAULT '[]'",
      );
    }
    await SeedData.reseedSentences(db);
  }

  /// Version 3: Reseed sentences with ||| answer overrides.
  static Future<void> _v3(Database db) async {
    await SeedData.reseedSentences(db);
  }
}
