import '../models/note.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

class NoteService {
  final _client = Supabase.instance.client;

  Future<List<Note>> fetchNotes() async {
    final response = await _client.from('notes').select().order('created_at', ascending: false);
    return response.map<Note>((note) => Note.fromMap(note)).toList();
  }

  Future<void> createNote(Note note) async {
    await _client.from('notes').insert({
      'title': note.title,
      'content': jsonEncode(note.content),
      'user_id': note.userId,
    });
  }

  Future<void> updateNote(Note note) async {
    await _client.from('notes').update({
      'title': note.title,
      'content': jsonEncode(note.content),
    }).eq('id', note.id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
