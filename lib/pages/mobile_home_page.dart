import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../widgets/mobile/mobile_app_bar.dart';
import '../widgets/mobile/mobile_bottom_navigation.dart';
import '../pages/note_editor_page.dart';
import '../widgets/advanced_search_dialog.dart';

class MobileHomePage extends ConsumerStatefulWidget {
  const MobileHomePage({super.key});

  @override
  ConsumerState<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends ConsumerState<MobileHomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  bool _showSearch = false;

  final List<Tab> _tabs = const [
    Tab(text: 'Todas', icon: Icon(Icons.note_outlined)),
    Tab(text: 'Recientes', icon: Icon(Icons.access_time)),
    Tab(text: 'Favoritos', icon: Icon(Icons.favorite_outline)),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      await ref.read(notesProvider.notifier).loadNotes();
    } catch (e) {
      _showSnackBar('Error cargando notas: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _createNewNote() async {
    try {
      final createdNote = await ref.read(notesProvider.notifier).createNote(
        'Nueva nota',
        [{'insert': 'Empieza a escribir aquí...\\n'}],
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorPage(note: createdNote),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Error creando nota: $e', isError: true);
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Estás seguro de que quieres eliminar "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(notesProvider.notifier).deleteNote(note.id);
        _showSnackBar('Nota eliminada');
      } catch (e) {
        _showSnackBar('Error eliminando nota: $e', isError: true);
      }
    }
  }

  void _showSearchOverlay() {
    setState(() {
      _showSearch = true;
    });
  }

  List<Note> _getFilteredNotes(List<Note> notes) {
    switch (_tabController.index) {
      case 0: // Todas
        return notes;
      case 1: // Recientes
        final sortedNotes = List<Note>.from(notes);
        sortedNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sortedNotes.take(10).toList();
      case 2: // Favoritos
        // Aquí podrías filtrar por favoritos si implementas esa funcionalidad
        return notes.where((note) => note.title.contains('⭐')).toList();
      default:
        return notes;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final filteredNotes = _getFilteredNotes(notes);

    return Scaffold(
      appBar: MobileAppBar(
        title: 'Notably',
        onMenuPressed: () {
          // Drawer functionality
        },
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchOverlay,
            tooltip: 'Buscar',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Tab bar
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: _tabs,
                  onTap: (index) {
                    setState(() {
                      // Refresh filtered notes when tab changes
                    });
                  },
                ),
              ),

              // Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotesGrid(filteredNotes),
                    _buildNotesGrid(filteredNotes),
                    _buildNotesGrid(filteredNotes),
                  ],
                ),
              ),
            ],
          ),

          // Search overlay
          if (_showSearch)
            Container(
              color: Colors.black54,
              child: AdvancedSearchDialog(
                notes: notes,
                onNoteSelected: (note) {
                  setState(() {
                    _showSearch = false;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteEditorPage(note: note),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: MobileBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewNote,
        child: const Icon(Icons.add),
        tooltip: 'Nueva nota',
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    if (notes.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return _buildNoteCard(note);
          },
        ),
      ),
    );
  }

  Widget _buildNoteCard(Note note) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorPage(note: note),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Sin título' : note.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteNote(note);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Eliminar'),
                          dense: true,
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 18),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content preview
              Expanded(
                child: Text(
                  _getContentPreview(note),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 12),

              // Date
              Text(
                _formatDate(note.updatedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No hay notas aún',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Crea tu primera nota tocando el botón +',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createNewNote,
              icon: const Icon(Icons.add),
              label: const Text('Crear nota'),
            ),
          ],
        ),
      ),
    );
  }

  String _getContentPreview(Note note) {
    try {
      if (note.content.isNotEmpty) {
        for (final op in note.content) {
          if (op is Map && op.containsKey('insert')) {
            final text = op['insert'].toString().trim();
            if (text.isNotEmpty && text != '\\n') {
              return text;
            }
          }
        }
      }
      return 'Sin contenido';
    } catch (e) {
      return 'Error al cargar contenido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}