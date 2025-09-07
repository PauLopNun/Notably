import '../models/note.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

class NoteService {
  final _client = Supabase.instance.client;

  Future<List<Note>> fetchNotes() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

      return response.map<Note>((note) => Note.fromMap(note)).toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      rethrow;
    }
  }

  Future<void> createNote(Note note) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.from('notes').insert({
        'title': note.title,
        'content': jsonEncode(note.content),
        'user_id': note.userId,
      }).select();

      if (response.isEmpty) {
        throw Exception('Error al crear la nota');
      }
    } catch (e) {
      debugPrint('Error creating note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client.from('notes').update({
        'title': note.title,
        'content': jsonEncode(note.content),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', note.id).eq('user_id', user.id);

      if (response == null) {
        throw Exception('Error al actualizar la nota');
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _client
        .from('notes')
        .delete()
        .eq('id', id)
        .eq('user_id', user.id);

      if (response == null) {
        throw Exception('Error al eliminar la nota');
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }
}
