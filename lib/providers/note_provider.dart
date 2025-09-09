import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/note_service.dart';

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref.read(noteServiceProvider));
});

class NotesNotifier extends StateNotifier<List<Note>> {
  final NoteService _noteService;
  NotesNotifier(this._noteService) : super([]);

  Future<void> loadNotes() async {
    try {
      state = await _noteService.fetchNotes();
    } catch (e) {
      print('Error loading notes: $e');
      state = [];
    }
  }

  Future<Note> createNote(String title, List<dynamic> content) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final newNote = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: user.id,
    );

    await _noteService.createNote(newNote);
    await loadNotes();
    
    return newNote;
  }

  Future<void> updateNote(String id, String title, List<dynamic> content) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final existingNote = state.firstWhere((note) => note.id == id);
    final updatedNote = Note(
      id: id,
      title: title,
      content: content,
      createdAt: existingNote.createdAt,
      updatedAt: DateTime.now(),
      userId: user.id,
    );

    await _noteService.updateNote(updatedNote);
    
    // Update state locally for immediate UI response
    state = state.map((note) {
      if (note.id == id) {
        return updatedNote;
      }
      return note;
    }).toList();
  }

  Future<void> addNote(Note note) async {
    await _noteService.createNote(note);
    await loadNotes();
  }

  Future<void> updateNoteObject(Note note) async {
    await _noteService.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _noteService.deleteNote(id);
    await loadNotes();
  }
}
