import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';

class NoteList extends ConsumerStatefulWidget {
  final Function(Note) onNoteSelected;

  const NoteList({
    super.key,
    required this.onNoteSelected,
  });

  @override
  ConsumerState<NoteList> createState() => _NoteListState();
}

class _NoteListState extends ConsumerState<NoteList> {
  bool _isGridView = false;
  String _sortBy = 'recent';

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    
    return Column(
      children: [
        // Header con controles
        _buildHeader(),
        
        // Separador
        Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
        
        // Lista de notas
        Expanded(
          child: notes.isEmpty
            ? _buildEmptyState()
            : _isGridView
              ? _buildGridView(notes)
              : _buildListView(notes),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Mis notas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          
          // Botón de vista
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewButton(
                  icon: Icons.view_list,
                  isSelected: !_isGridView,
                  onTap: () => setState(() => _isGridView = false),
                ),
                _buildViewButton(
                  icon: Icons.grid_view,
                  isSelected: _isGridView,
                  onTap: () => setState(() => _isGridView = true),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Dropdown de ordenamiento
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                items: [
                  DropdownMenuItem(
                    value: 'recent',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Más recientes', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'title',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sort_by_alpha, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('Por título', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _sortBy = value);
                  }
                },
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                style: TextStyle(color: Colors.grey[800], fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_add,
              size: 64,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay notas todavía',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comienza creando tu primera nota para organizar tus ideas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Aquí podrías abrir el editor directamente
            },
            icon: const Icon(Icons.add),
            label: const Text('Crear primera nota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Note> notes) {
    final sortedNotes = _sortNotes(notes);
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildListNoteItem(note);
      },
    );
  }

  Widget _buildGridView(List<Note> notes) {
    final sortedNotes = _sortNotes(notes);
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildGridNoteItem(note);
      },
    );
  }

  Widget _buildListNoteItem(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => widget.onNoteSelected(note),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Nota',
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getNotePreview(note.content),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(note.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridNoteItem(Note note) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onNoteSelected(note),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note,
                    color: const Color(0xFF6366F1),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  note.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  _getNotePreview(note.content),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _formatDate(note.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Note> _sortNotes(List<Note> notes) {
    switch (_sortBy) {
      case 'recent':
        return List.from(notes)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case 'title':
        return List.from(notes)..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      default:
        return notes;
    }
  }

  String _getNotePreview(List<dynamic> content) {
    try {
      if (content.isEmpty) return 'Sin contenido';
      
      String preview = '';
      for (var op in content) {
        if (op['insert'] != null) {
          String insert = op['insert'].toString();
          if (insert.trim().isNotEmpty) {
            preview += insert;
            if (preview.length > 100) {
              preview = preview.substring(0, 100) + '...';
              break;
            }
          }
        }
      }
      return preview.trim().isEmpty ? 'Sin contenido' : preview.trim();
    } catch (_) {
      return 'Sin contenido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
