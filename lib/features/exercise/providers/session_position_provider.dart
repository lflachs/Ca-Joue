import 'package:ca_joue/core/database/database_provider.dart';
import 'package:ca_joue/core/database/tables.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_position_provider.g.dart';

/// Manages the current lesson position for mid-lesson resume.
///
/// Reads and writes the `current_lesson_position` column in the
/// `sessions` singleton table. Format: `"lessonId:expressionIndex"`.
@riverpod
class SessionPositionNotifier extends _$SessionPositionNotifier {
  @override
  Future<String?> build() async {
    final db = await ref.watch(databaseProvider.future);
    final rows = await db.query(
      Tables.sessions,
      columns: [Tables.sessCurrentLessonPosition],
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (rows.isEmpty) return null;
    return rows.first[Tables.sessCurrentLessonPosition] as String?;
  }

  /// Saves the current lesson position for mid-lesson resume.
  Future<void> savePosition(String lessonId, int expressionIndex) async {
    final db = await ref.read(databaseProvider.future);
    final position = '$lessonId:$expressionIndex';

    await db.update(
      Tables.sessions,
      {Tables.sessCurrentLessonPosition: position},
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (ref.mounted) state = AsyncData(position);
  }

  /// Clears the saved lesson position (e.g., on lesson complete).
  Future<void> clearPosition() async {
    final db = await ref.read(databaseProvider.future);

    await db.update(
      Tables.sessions,
      {Tables.sessCurrentLessonPosition: null},
      where: '${Tables.sessId} = ?',
      whereArgs: [1],
    );

    if (ref.mounted) state = const AsyncData(null);
  }

  /// Parses a position string into lesson ID and expression index.
  ///
  /// Returns `null` if the format is invalid.
  static ({String lessonId, int index})? parsePosition(String? position) {
    if (position == null) return null;

    final parts = position.split(':');
    if (parts.length != 2) return null;

    final index = int.tryParse(parts[1]);
    if (index == null) return null;

    return (lessonId: parts[0], index: index);
  }
}
