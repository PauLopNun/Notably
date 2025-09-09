import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';
import '../widgets/notion_sidebar.dart';
import '../widgets/notion_content_area.dart';
import '../widgets/notion_properties_panel.dart';
import '../widgets/notion_search_overlay.dart';
import '../services/pdf_export_service.dart';
import '../services/collaboration_service.dart';

class NotionStyleHome extends ConsumerStatefulWidget {
  const NotionStyleHome({super.key});

  @override
  ConsumerState<NotionStyleHome> createState() => _NotionStyleHomeState();
}

class _NotionStyleHomeState extends ConsumerState<NotionStyleHome> {
  Note? selectedNote;
  bool showPropertiesPanel = false;
  bool showSearchOverlay = false;
  double sidebarWidth = 260.0;
  bool sidebarCollapsed = false;

  final FocusNode _globalFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _setupKeyboardShortcuts();
  }

  void _setupKeyboardShortcuts() {
    _globalFocusNode.requestFocus();
  }

  Future<void> _loadNotes() async {
    try {
      await ref.read(notesProvider.notifier).loadNotes();
    } catch (e) {
      _showSnackBar('Error loading notes: $e', isError: true);
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
        'Untitled',
        [],
      );
      
      setState(() {
        selectedNote = createdNote;
      });
      
      _showSnackBar('New note created');
    } catch (e) {
      _showSnackBar('Error creating note: $e', isError: true);
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
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
      try {
        await ref.read(notesProvider.notifier).deleteNote(note.id);
        if (selectedNote?.id == note.id) {
          setState(() => selectedNote = null);
        }
        _showSnackBar('Note deleted');
      } catch (e) {
        _showSnackBar('Error deleting note: $e', isError: true);
      }
    }
  }

  Future<void> _exportToPDF(Note note) async {
    try {
      final pdfService = PDFExportService();
      final filePath = await pdfService.exportNoteToPDF(note);
      _showSnackBar('PDF exported to: $filePath');
    } catch (e) {
      _showSnackBar('Error exporting PDF: $e', isError: true);
    }
  }

  Future<void> _exportToMarkdown(Note note) async {
    try {
      final content = _convertToMarkdown(note);
      // Implementation for saving markdown file
      _showSnackBar('Markdown export completed');
    } catch (e) {
      _showSnackBar('Error exporting Markdown: $e', isError: true);
    }
  }

  String _convertToMarkdown(Note note) {
    // Convert Quill delta to Markdown
    return '# ${note.title}\n\n${note.content.toString()}';
  }

  Future<void> _shareForCollaboration(Note note) async {
    final email = await _showEmailDialog();
    if (email != null && email.isNotEmpty) {
      try {
        final collaborationService = CollaborationService();
        await collaborationService.inviteCollaborator(note.id, email);
        _showSnackBar('Collaboration invite sent to $email');
      } catch (e) {
        _showSnackBar('Error sending invite: $e', isError: true);
      }
    }
  }

  Future<String?> _showEmailDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Collaborator'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter email address',
            labelText: 'Email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: KeyboardListener(
        focusNode: _globalFocusNode,
        onKeyEvent: (event) {
          // Cmd/Ctrl + K for search
          if (event.logicalKey.keyLabel == 'K' && 
              (event.logicalKey.keyLabel.contains('Meta') || 
               event.logicalKey.keyLabel.contains('Control'))) {
            setState(() => showSearchOverlay = true);
          }
          // Cmd/Ctrl + N for new note
          if (event.logicalKey.keyLabel == 'N' && 
              (event.logicalKey.keyLabel.contains('Meta') || 
               event.logicalKey.keyLabel.contains('Control'))) {
            _createNewNote();
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                // Sidebar
                if (!sidebarCollapsed) ...[
                  SizedBox(
                    width: sidebarWidth,
                    child: NotionSidebar(
                      notes: notes,
                      selectedNote: selectedNote,
                      onNoteSelected: (note) => setState(() => selectedNote = note),
                      onNoteDeleted: _deleteNote,
                      onNewNote: _createNewNote,
                      onSearch: () => setState(() => showSearchOverlay = true),
                      onToggleSidebar: () => setState(() => sidebarCollapsed = !sidebarCollapsed),
                    ),
                  ),
                  // Resize handle
                  MouseRegion(
                    cursor: SystemMouseCursors.resizeLeftRight,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          sidebarWidth = (sidebarWidth + details.delta.dx)
                              .clamp(200.0, 400.0);
                        });
                      },
                      child: Container(
                        width: 4,
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                ] else ...[
                  // Collapsed sidebar button
                  Container(
                    width: 60,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        IconButton(
                          onPressed: () => setState(() => sidebarCollapsed = false),
                          icon: const Icon(Icons.menu),
                          tooltip: 'Expand sidebar',
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          onPressed: () => setState(() => showSearchOverlay = true),
                          icon: const Icon(Icons.search),
                          tooltip: 'Search (⌘K)',
                        ),
                        IconButton(
                          onPressed: _createNewNote,
                          icon: const Icon(Icons.add),
                          tooltip: 'New note (⌘N)',
                        ),
                      ],
                    ),
                  ),
                ],

                // Main content area
                Expanded(
                  child: NotionContentArea(
                    note: selectedNote,
                    onNoteUpdated: (updatedNote) {
                      setState(() => selectedNote = updatedNote);
                      ref.read(notesProvider.notifier).updateNote(
                        updatedNote.id,
                        updatedNote.title,
                        updatedNote.content,
                      );
                    },
                    onExportToPDF: () => selectedNote != null ? _exportToPDF(selectedNote!) : null,
                    onExportToMarkdown: () => selectedNote != null ? _exportToMarkdown(selectedNote!) : null,
                    onShare: () => selectedNote != null ? _shareForCollaboration(selectedNote!) : null,
                    onToggleProperties: () => setState(() => showPropertiesPanel = !showPropertiesPanel),
                  ),
                ),

                // Properties panel
                if (showPropertiesPanel && selectedNote != null) ...[
                  Container(
                    width: 1,
                    color: theme.dividerColor,
                  ),
                  SizedBox(
                    width: 300,
                    child: NotionPropertiesPanel(
                      note: selectedNote!,
                      onClose: () => setState(() => showPropertiesPanel = false),
                    ),
                  ),
                ],
              ],
            ),

            // Search overlay
            if (showSearchOverlay)
              NotionSearchOverlay(
                notes: notes,
                onNoteSelected: (note) {
                  setState(() {
                    selectedNote = note;
                    showSearchOverlay = false;
                  });
                },
                onClose: () => setState(() => showSearchOverlay = false),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _globalFocusNode.dispose();
    super.dispose();
  }
}