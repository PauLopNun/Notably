import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref.read(noteServiceProvider));
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NoteService _noteService;
  NotesNotifier(this._noteService) : super([]);

  Future<void> loadNotes() async {
    state = await _noteService.fetchNotes();
  }

  Future<void> addNote(Note note) async {
    await _noteService.createNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _noteService.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
    await loadNotes();
  }
}
