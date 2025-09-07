import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../theme/app_theme.dart';

class Sidebar extends ConsumerStatefulWidget {
  final bool isCollapsed;
  final Function(Note) onNoteSelected;
  final VoidCallback onCreateNote;

  const Sidebar({
    super.key,
    required this.isCollapsed,
    required this.onNoteSelected,
    required this.onCreateNote,
  });

  @override
  ConsumerState<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends ConsumerState<Sidebar> {
  String _searchQuery = '';
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    '📝 Notas',
    '📚 Apuntes',
    '💼 Trabajo',
    '🎯 Proyectos',
    '📋 Tareas',
    '💡 Ideas',
    '📖 Lecturas',
  ];

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          right: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header del sidebar
          _buildHeader(),
          
          // Barra de búsqueda
          if (!widget.isCollapsed) _buildSearchBar(),
          
          // Categorías
          if (!widget.isCollapsed) _buildCategories(),
          
                  // Separador
        if (!widget.isCollapsed)
          Container(
            height: 1,
            color: AppTheme.dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          
          // Lista de notas recientes
          Expanded(
            child: _buildNotesList(notes),
          ),
          
          // Footer con botón de nueva nota
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: widget.isCollapsed 
            ? const BorderRadius.only(bottomRight: Radius.circular(12))
            : null,
        ),
      child: Row(
        children: [
          if (!widget.isCollapsed) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.note_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Notably',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar notas...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textTertiary),
          filled: true,
          fillColor: AppTheme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
                             label: Text(
                 category,
                 style: TextStyle(
                   color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                   fontSize: 12,
                 ),
               ),
               backgroundColor: AppTheme.cardColor,
               selectedColor: AppTheme.primaryColor,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
                         Icon(
               Icons.note_add,
               size: 48,
               color: AppTheme.textTertiary,
             ),
             const SizedBox(height: 16),
             Text(
               'No hay notas',
               style: TextStyle(
                 color: AppTheme.textSecondary,
                 fontSize: 16,
               ),
             ),
             const SizedBox(height: 8),
             Text(
               'Crea tu primera nota',
               style: TextStyle(
                 color: AppTheme.textTertiary,
                 fontSize: 14,
               ),
             ),
          ],
        ),
      );
    }

    // Filtrar notas por búsqueda y categoría (por prefijo emoji en título)
    final filteredNotes = notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty || 
        note.title.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesCategory = true;
      if (_selectedCategory != 'Todas') {
        matchesCategory = note.title.startsWith(_selectedCategory.split(' ').first);
      }
      
      return matchesSearch && matchesCategory;
    }).toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return _buildNoteItem(note);
      },
    );
  }

  Widget _buildNoteItem(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onNoteSelected(note),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                         decoration: BoxDecoration(
               color: AppTheme.cardColor,
               borderRadius: BorderRadius.circular(8),
               border: Border.all(
                 color: AppTheme.borderColor,
                 width: 1,
               ),
             ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 Text(
                   note.title,
                   style: const TextStyle(
                     fontWeight: FontWeight.w600,
                     fontSize: 14,
                     color: AppTheme.textPrimary,
                   ),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
                 const SizedBox(height: 4),
                 Text(
                   _getNotePreview(note.content),
                   style: TextStyle(
                     fontSize: 12,
                     color: AppTheme.textSecondary,
                   ),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                 ),
                 const SizedBox(height: 8),
                 Row(
                   children: [
                     Icon(
                       Icons.access_time,
                       size: 12,
                       color: AppTheme.textTertiary,
                     ),
                     const SizedBox(width: 4),
                     Text(
                       _formatDate(note.createdAt),
                       style: TextStyle(
                         fontSize: 11,
                         color: AppTheme.textTertiary,
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(
            top: BorderSide(
              color: AppTheme.dividerColor,
              width: 1,
            ),
          ),
        ),
      child: widget.isCollapsed
        ? IconButton(
            onPressed: widget.onCreateNote,
            icon: const Icon(
              Icons.add,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          )
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onCreateNote,
              icon: const Icon(Icons.add),
              label: const Text('Nueva nota'),
              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
    );
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
            if (preview.length > 50) {
              preview = preview.substring(0, 50) + '...';
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
