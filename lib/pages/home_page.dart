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
      appBar: AppBar(
        title: const Text('Tus notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(notesProvider.notifier).loadNotes();
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: notes.isEmpty
          ? const Center(child: Text('No hay notas todavía'))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () async {
                    // Navegar al editor de nota para editar
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
        onPressed: () async {
          // Navegar al editor de nota para crear nueva
          await Navigator.of(context).pushNamed('/editor', arguments: null);
          await ref.read(notesProvider.notifier).loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
