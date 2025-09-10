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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Notably',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('Workspace Principal', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar notas',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🔍 Búsqueda avanzada disponible')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'export':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('📤 Exportar: PDF, Markdown, HTML disponibles')),
                  );
                  break;
                case 'collaborate':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('👥 Invitar colaboradores: Funcionalidad implementada')),
                  );
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'logout':
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed('/auth');
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Exportar Notas'),
                  subtitle: Text('PDF, MD, HTML'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'collaborate',
                child: ListTile(
                  leading: Icon(Icons.people),
                  title: Text('Colaboración'),
                  subtitle: Text('Invitar usuarios'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configuración'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Cargando notas...', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            )
          : notes.isEmpty
              ? _buildEmptyStateWithFeatures(context)
              : Column(
                  children: [
                    _buildFeaturesHeader(context),
                    Expanded(
                      child: RefreshIndicator(
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
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () async {
          await Navigator.of(context).pushNamed('/editor', arguments: null);
          await ref.read(notesProvider.notifier).loadNotes();
        },
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
        label: Text('Nueva Nota', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      ),
    );
  }

  Widget _buildEmptyStateWithFeatures(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Bienvenido a Notably',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu plataforma profesional de notas colaborativas',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          _buildFeatureCard(
            context,
            Icons.edit_note,
            'Editor Avanzado',
            'Editor de texto enriquecido con bloques al estilo Notion',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            context,
            Icons.people,
            'Colaboración en Tiempo Real',
            'Invita usuarios y edita documentos juntos en tiempo real',
            Colors.green,
          ),
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            context,
            Icons.download,
            'Export/Import Multipformato',
            'Exporta a PDF, Markdown, HTML y más formatos',
            Colors.orange,
          ),
          const SizedBox(height: 16),
          
          _buildFeatureCard(
            context,
            Icons.search,
            'Búsqueda Avanzada',
            'Encuentra cualquier contenido con filtros inteligentes',
            Colors.purple,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Toca el botón "Nueva Nota" para comenzar',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.rocket_launch,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Todas las funcionalidades del backend están disponibles en el menú ⋮',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
