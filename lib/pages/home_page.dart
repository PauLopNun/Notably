import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      await ref.read(notesProvider.notifier).loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar las notas: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshNotes() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Tus notas', 
          style: TextStyle(
            color: Color(0xFF22223B), 
            fontWeight: FontWeight.bold
          )
        ),
        iconTheme: const IconThemeData(color: Color(0xFF22223B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A4E69)),
            tooltip: 'Actualizar',
            onPressed: _refreshNotes,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF4A4E69)),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/auth');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF4A4E69),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Cargando notas...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9A8C98),
                    ),
                  ),
                ],
              ),
            )
          : notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay notas todavía',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF9A8C98),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Toca el botón + para crear tu primera nota',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9A8C98),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshNotes,
                  child: ListView.builder(
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
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Eliminar nota'),
                              content: Text('¿Estás seguro de que quieres eliminar "${note.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirmed == true) {
                            try {
                              await ref.read(notesProvider.notifier).deleteNote(note.id);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Nota eliminada'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al eliminar: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      );
                    },
                  ),
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
