import 'package:ca_joue/core/database/migrations.dart';
import 'package:ca_joue/core/database/seed_data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper for database initialization and access.
class DatabaseHelper {
  DatabaseHelper._();

  /// The shared [DatabaseHelper] instance.
  static final DatabaseHelper instance = DatabaseHelper._();

  /// Current database schema version.
  static const int _version = 1;

  Database? _database;

  /// Returns the initialized database, creating it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ca_joue.db');

    return openDatabase(
      path,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await Migrations.runAll(db, 0, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await Migrations.runAll(db, oldVersion, newVersion);
  }

  /// Seeds the database if the expressions table is empty.
  Future<void> seedIfNeeded(Database db) async {
    await SeedData.seedIfNeeded(db);
  }
}
