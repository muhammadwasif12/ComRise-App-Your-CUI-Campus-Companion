import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../data/models/note_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    // Re-run this build whenever authProvider changes
    final authState = ref.watch(authProvider);

    // Only fetch if we have a valid user
    if (authState.hasValue && authState.value != null) {
      return _fetchNotes(authState.value!.id);
    }
    return [];
  }

  Future<List<Note>> _fetchNotes(String userId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final maps = await db.query(
        'notes',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'createdAt DESC',
      );

      return maps.map((e) => Note.fromMap(e)).toList();
    } catch (e) {
      // In case of error during fetch, return empty or rethrow
      return [];
    }
  }

  Future<void> addNote(
    String content, {
    String type = 'text',
    String? filePath,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null) {
      return;
    }

    final note = Note(
      userId: user.id,
      content: content,
      type: type,
      filePath: filePath,
      createdAt: DateTime.now(),
    );

    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert('notes', note.toMap());

      // Update state by refetching
      final updatedNotes = await _fetchNotes(user.id);
      state = AsyncData(updatedNotes);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> deleteNote(int id) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);

      final updatedNotes = await _fetchNotes(user.id);
      state = AsyncData(updatedNotes);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

final selfChatNotesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  () {
    return NotesNotifier();
  },
);
