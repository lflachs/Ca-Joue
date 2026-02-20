import 'dart:convert';

import 'package:ca_joue/core/content/expression_model.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

/// Handles seeding the database from bundled JSON assets.
abstract final class SeedData {
  /// Seeds expressions and initial session if the database is empty.
  static Future<void> seedIfNeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${Tables.expressions}'),
    );

    if (count != null && count > 0) return;

    await _seedExpressions(db);
    await _seedInitialSession(db);
  }

  static Future<void> _seedExpressions(Database db) async {
    final jsonString =
        await rootBundle.loadString('assets/data/expressions.json');
    final jsonList = jsonDecode(jsonString) as List;

    final batch = db.batch();
    for (final json in jsonList) {
      final expression =
          Expression.fromJson(json as Map<String, dynamic>);
      batch.insert(Tables.expressions, expression.toRow());
    }
    await batch.commit(noResult: true);
  }

  static Future<void> _seedInitialSession(Database db) async {
    await db.insert(Tables.sessions, {
      Tables.sessId: 1,
      Tables.sessStreakCount: 0,
      Tables.sessStreakLastDate: null,
      Tables.sessTotalPoints: 0,
      Tables.sessCurrentLessonPosition: null,
      Tables.sessFirstLaunchCompleted: 0,
    });
  }
}
