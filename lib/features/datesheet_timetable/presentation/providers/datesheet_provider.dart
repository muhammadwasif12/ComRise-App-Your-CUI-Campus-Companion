import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/exam_model.dart';

class DatesheetNotifier extends AsyncNotifier<List<ExamEntry>> {
  @override
  Future<List<ExamEntry>> build() async {
    return _fetchDatesheets();
  }

  Future<List<ExamEntry>> _fetchDatesheets() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('datesheets');
    return maps.map((e) => ExamEntry.fromMap(e)).toList();
  }

  Future<void> saveDatesheet(List<ExamEntry> exams) async {
    state = const AsyncLoading();
    try {
      final db = await DatabaseHelper.instance.database;
      await db.transaction((txn) async {
        // Clear old datesheet
        await txn.delete('datesheets');
        for (var exam in exams) {
          await txn.insert('datesheets', exam.toMap());
        }
      });
      state = AsyncData(await _fetchDatesheets());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> clearDatesheet() async {
    state = const AsyncLoading();
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('datesheets');
      state = const AsyncData([]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final datesheetProvider =
    AsyncNotifierProvider<DatesheetNotifier, List<ExamEntry>>(
      () => DatesheetNotifier(),
    );
