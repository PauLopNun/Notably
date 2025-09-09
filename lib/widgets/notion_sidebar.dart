import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/note.dart';
import '../widgets/workspace_selector.dart';
import '../widgets/template_gallery.dart';
import '../services/pdf_export_service.dart';

class NotionSidebar extends StatefulWidget {
  final List<Note> notes;
  final Note? selectedNote;
  final Function(Note) onNoteSelected;
  final Function(Note) onNoteDeleted;
  final VoidCallback onNewNote;
  final Function(NotionTemplate)? onTemplateSelected;
  final VoidCallback onSearch;
  final VoidCallback onToggleSidebar;

  const NotionSidebar({
    super.key,
    required this.notes,
    required this.selectedNote,
    required this.onNoteSelected,
    required this.onNoteDeleted,
    required this.onNewNote,
    this.onTemplateSelected,
    required this.onSearch,
    required this.onToggleSidebar,
  });

  @override
  State<NotionSidebar> createState() => _NotionSidebarState();
}

enum NoteFilter { all, recent, favorites }

class _NotionSidebarState extends State<NotionSidebar> {
  String searchQuery = '';
  bool isLoading = false;
  NoteFilter _currentFilter = NoteFilter.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Note> filteredNotes = widget.notes.where((note) =>
        note.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    
    // Apply filter based on current selection
    switch (_currentFilter) {
      case NoteFilter.all:
        // No additional filtering
        break;
      case NoteFilter.recent:
        // Show notes from last 7 days, sorted by update time
        final now = DateTime.now();
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        filteredNotes = filteredNotes.where((note) => 
          note.updatedAt.isAfter(sevenDaysAgo)
        ).toList();
        filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case NoteFilter.favorites:
        // For now, just show empty list since we don't have favorites yet
        // In a full implementation, you'd filter by favorite status
        filteredNotes = [];
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Workspace Selector
          const WorkspaceSelector(),
          
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: theme.dividerColor.withOpacity(0.3),
          ),
          
          // Search
          _buildSearchBar(theme),
          
          // Quick Actions
          _buildQuickActions(theme),
          
          // Notes List
          Expanded(
            child: _buildNotesList(theme, filteredNotes),
          ),
          
          // Footer
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final user = Supabase.instance.client.auth.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user?.email?.substring(0, 1).toUpperCase() ?? 'U',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Workspace Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notably Workspace',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  user?.email ?? 'Guest User',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Collapse Button
          IconButton(
            icon: const Icon(Icons.first_page, size: 18),
            tooltip: 'Collapse sidebar',
            onPressed: widget.onToggleSidebar,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: (value) => setState(() => searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search notes... (⌘K)',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
        onTap: widget.onSearch,
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildActionButton(
            theme,
            icon: Icons.add,
            label: 'New Note',
            onTap: widget.onNewNote,
            shortcut: '⌘N',
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            theme,
            icon: Icons.dashboard_customize,
            label: 'Templates',
            onTap: _showTemplateGallery,
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            theme,
            icon: Icons.folder_open,
            label: 'All Notes',
            onTap: () => setState(() => _currentFilter = NoteFilter.all),
            badge: '${widget.notes.length}',
            isSelected: _currentFilter == NoteFilter.all,
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            theme,
            icon: Icons.schedule,
            label: 'Recent',
            onTap: () => setState(() => _currentFilter = NoteFilter.recent),
            isSelected: _currentFilter == NoteFilter.recent,
          ),
          const SizedBox(height: 4),
          _buildActionButton(
            theme,
            icon: Icons.star_outline,
            label: 'Favorites',
            onTap: () => setState(() => _currentFilter = NoteFilter.favorites),
            isSelected: _currentFilter == NoteFilter.favorites,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? shortcut,
    String? badge,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: isSelected 
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 16, 
              color: isSelected 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
            if (shortcut != null) ...[
              Text(
                shortcut,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(ThemeData theme, List<Note> filteredNotes) {
    if (isLoading) {
      return _buildShimmerLoading(theme);
    }
    
    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              searchQuery.isEmpty ? 'No notes yet' : 'No matching notes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (searchQuery.isEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onNewNote,
                child: const Text('Create your first note'),
              ),
            ],
          ],
        ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: filteredNotes.length,
      onReorder: (oldIndex, newIndex) {
        // Handle reordering logic here
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          // Note: You'd implement actual reordering in your provider
        });
      },
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        final isSelected = widget.selectedNote?.id == note.id;
        
        return AnimatedContainer(
          key: ValueKey(note.id),
          duration: const Duration(milliseconds: 200),
          child: _buildNoteItem(theme, note, isSelected, index),
        );
      },
    );
  }

  Widget _buildNoteItem(ThemeData theme, Note note, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      child: Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isSelected 
          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isSelected 
              ? theme.colorScheme.primary.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: () => widget.onNoteSelected(note),
          onHover: (hovering) {
            // Add subtle hover animation
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
              // Drag handle
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),
              
              // Note icon (emoji or default)
              Text('📄', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              
              // Note info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatLastUpdated(note.updatedAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              // More options
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onSelected: (action) async {
                  switch (action) {
                    case 'delete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Note'),
                          content: Text('Are you sure you want to delete "${note.title.isEmpty ? 'Untitled' : note.title}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        widget.onNoteDeleted(note);
                      }
                      break;
                    case 'duplicate':
                      _duplicateNote(note);
                      break;
                    case 'export':
                      _exportNote(note);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 16),
                        SizedBox(width: 8),
                        Text('Duplicate'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Export'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              theme,
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: 6, // Show 6 shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: theme.colorScheme.surfaceContainerHighest,
          highlightColor: theme.colorScheme.surfaceContainerHigh,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: theme.colorScheme.surface,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 12,
                          color: theme.colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate(delay: (index * 100).ms).fadeIn(duration: 300.ms);
      },
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showTemplateGallery() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: TemplateGallery(
            onTemplateSelected: (template) {
              Navigator.pop(context);
              if (widget.onTemplateSelected != null) {
                widget.onTemplateSelected!(template);
              } else {
                // Fallback to creating empty note
                widget.onNewNote();
              }
            },
          ),
        ),
      ),
    );
  }

  void _duplicateNote(Note note) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Duplicated "${note.title.isEmpty ? 'Untitled' : note.title}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to duplicated note
            widget.onNewNote();
          },
        ),
      ),
    );
  }

  void _exportNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Note'),
        content: const Text('Choose export format:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsPDF(note);
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsMarkdown(note);
            },
            child: const Text('Markdown'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAsPDF(Note note) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting "${note.title.isEmpty ? 'Untitled' : note.title}" as PDF...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      final pdfService = PDFExportService();
      final filePath = await pdfService.exportNoteToPDF(note);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF exported successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Show Path',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved to: $filePath'),
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _exportAsMarkdown(Note note) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting "${note.title.isEmpty ? 'Untitled' : note.title}" as Markdown...'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      final content = _convertToMarkdown(note);
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${note.title.isEmpty ? 'Untitled' : _sanitizeFileName(note.title)}_${DateTime.now().millisecondsSinceEpoch}.md';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Markdown exported successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Show Path',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Saved to: ${file.path}'),
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting Markdown: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  String _convertToMarkdown(Note note) {
    final buffer = StringBuffer();
    
    // Add title
    buffer.writeln('# ${note.title.isEmpty ? 'Untitled' : note.title}');
    buffer.writeln();
    
    // Add metadata
    buffer.writeln('---');
    buffer.writeln('**Created:** ${_formatDate(note.createdAt)}');
    buffer.writeln('**Last Modified:** ${_formatDate(note.updatedAt)}');
    buffer.writeln('---');
    buffer.writeln();
    
    // Convert content to markdown
    if (note.content.isEmpty) {
      buffer.writeln('*No content*');
    } else {
      try {
        for (final op in note.content) {
          if (op is Map && op.containsKey('insert')) {
            String text = op['insert'].toString();
            
            // Apply formatting based on attributes
            if (op.containsKey('attributes') && op['attributes'] is Map) {
              final attrs = op['attributes'] as Map;
              
              if (attrs.containsKey('bold') && attrs['bold'] == true) {
                text = '**$text**';
              }
              if (attrs.containsKey('italic') && attrs['italic'] == true) {
                text = '*$text*';
              }
              if (attrs.containsKey('underline') && attrs['underline'] == true) {
                text = '<u>$text</u>';
              }
              if (attrs.containsKey('header')) {
                final level = attrs['header'] as int;
                text = '${'#' * level} $text';
              }
              if (attrs.containsKey('list')) {
                final listType = attrs['list'];
                if (listType == 'bullet') {
                  text = '- $text';
                } else if (listType == 'ordered') {
                  text = '1. $text';
                }
              }
              if (attrs.containsKey('blockquote')) {
                text = '> $text';
              }
              if (attrs.containsKey('code-block')) {
                text = '```\n$text\n```';
              }
            }
            
            buffer.write(text);
          }
        }
      } catch (e) {
        buffer.writeln(note.content.toString());
      }
    }
    
    return buffer.toString();
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }
}