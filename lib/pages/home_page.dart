import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Tus notas', style: TextStyle(color: Color(0xFF22223B), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF22223B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4A4E69)),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(notesProvider.notifier).loadNotes();
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'No hay notas todavía',
                style: TextStyle(fontSize: 18, color: Color(0xFF9A8C98)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () async {
                    await Navigator.of(context).pushNamed('/editor', arguments: note);
                    await ref.read(notesProvider.notifier).loadNotes();
                  },
                  onDelete: () async {
                    await ref.read(notesProvider.notifier).deleteNote(note.id);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4A4E69),
        onPressed: () async {
          await Navigator.of(context).pushNamed('/editor', arguments: null);
          await ref.read(notesProvider.notifier).loadNotes();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
