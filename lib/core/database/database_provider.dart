import 'package:ca_joue/core/database/database_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'database_provider.g.dart';

/// Provides the initialized SQLite database instance.
///
/// Opens the database, runs migrations if needed, and seeds
/// expression data on first launch.
@riverpod
class DatabaseNotifier extends _$DatabaseNotifier {
  @override
  Future<Database> build() async {
    final helper = DatabaseHelper.instance;
    final db = await helper.database;
    await helper.seedIfNeeded(db);
    return db;
  }
}
