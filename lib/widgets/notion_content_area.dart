import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/note.dart';
import '../widgets/notion_block_editor.dart';

class NotionContentArea extends StatefulWidget {
  final Note? note;
  final Function(Note)? onNoteUpdated;
  final VoidCallback? onExportToPDF;
  final VoidCallback? onExportToMarkdown;
  final VoidCallback? onShare;
  final VoidCallback? onToggleProperties;

  const NotionContentArea({
    super.key,
    required this.note,
    this.onNoteUpdated,
    this.onExportToPDF,
    this.onExportToMarkdown,
    this.onShare,
    this.onToggleProperties,
  });

  @override
  State<NotionContentArea> createState() => _NotionContentAreaState();
}

class _NotionContentAreaState extends State<NotionContentArea> {
  late TextEditingController _titleController;
  late QuillController _contentController;
  bool _isEditing = false;
  String _selectedEmoji = '📄';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(NotionContentArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note?.id != widget.note?.id) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = QuillController.basic();
    
    // Load content if available
    if (widget.note?.content.isNotEmpty == true) {
      // Parse existing content
      try {
        final delta = Delta.fromJson(widget.note!.content as List);
        _contentController.document = Document.fromDelta(delta);
      } catch (e) {
        // If content is not valid Delta, create empty document
        _contentController.document = Document();
      }
    }

    _titleController.addListener(_onTitleChanged);
    _contentController.addListener(_onContentChanged);
  }

  void _onTitleChanged() {
    if (widget.note != null && widget.onNoteUpdated != null) {
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text,
        content: _contentController.document.toDelta().toJson(),
        createdAt: widget.note!.createdAt,
        updatedAt: DateTime.now(),
        userId: widget.note!.userId,
      );
      widget.onNoteUpdated!(updatedNote);
    }
  }

  void _onContentChanged() {
    if (widget.note != null && widget.onNoteUpdated != null) {
      final updatedNote = Note(
        id: widget.note!.id,
        title: _titleController.text,
        content: _contentController.document.toDelta().toJson(),
        createdAt: widget.note!.createdAt,
        updatedAt: DateTime.now(),
        userId: widget.note!.userId,
      );
      widget.onNoteUpdated!(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.note == null) {
      return _buildEmptyState(theme);
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: _buildContent(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Select a note to start editing',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a note from the sidebar or create a new one',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShortcutChip(theme, '⌘+N', 'New note'),
                const SizedBox(width: 12),
                _buildShortcutChip(theme, '⌘+K', 'Search'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutChip(ThemeData theme, String shortcut, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          _buildBreadcrumb(theme),
          const SizedBox(height: 12),
          
          // Title with emoji
          Row(
            children: [
              // Emoji picker
              InkWell(
                onTap: _showEmojiPicker,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    _selectedEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Title input
              Expanded(
                child: TextField(
                  controller: _titleController,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Untitled',
                    hintStyle: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                ),
              ),
              
              // Actions
              _buildHeaderActions(theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.home_outlined,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Notably Workspace',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Text(
          'Notes',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Icon(
          Icons.chevron_right,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        Text(
          widget.note!.title.isEmpty ? 'Untitled' : widget.note!.title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildHeaderActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share button
        IconButton(
          icon: const Icon(Icons.share, size: 18),
          tooltip: 'Share & Collaborate',
          onPressed: widget.onShare,
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(8),
          ),
        ),
        
        // Export menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.download, size: 18),
          tooltip: 'Export',
          onSelected: (action) {
            switch (action) {
              case 'pdf':
                widget.onExportToPDF?.call();
                break;
              case 'markdown':
                widget.onExportToMarkdown?.call();
                break;
              case 'html':
                // Handle HTML export
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'pdf',
              child: Row(
                children: [
                  Icon(Icons.picture_as_pdf, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Export as PDF'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'markdown',
              child: Row(
                children: [
                  Icon(Icons.code, size: 16),
                  SizedBox(width: 8),
                  Text('Export as Markdown'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'html',
              child: Row(
                children: [
                  Icon(Icons.web, size: 16),
                  SizedBox(width: 8),
                  Text('Export as HTML'),
                ],
              ),
            ),
          ],
        ),
        
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18),
          tooltip: 'More options',
          onSelected: (action) {
            switch (action) {
              case 'properties':
                widget.onToggleProperties?.call();
                break;
              case 'history':
                // Handle history
                break;
              case 'duplicate':
                // Handle duplicate
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'properties',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16),
                  SizedBox(width: 8),
                  Text('Page Properties'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 16),
                  SizedBox(width: 8),
                  Text('Page History'),
                ],
              ),
            ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 750),
      margin: const EdgeInsets.symmetric(horizontal: 96),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rich text editor with block-based editing
            NotionBlockEditor(
              controller: _contentController,
              onChanged: _onContentChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Icon'),
        content: SizedBox(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _emojis.length,
            itemBuilder: (context, index) {
              final emoji = _emojis[index];
              return InkWell(
                onTap: () {
                  setState(() => _selectedEmoji = emoji);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedEmoji == emoji 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static const List<String> _emojis = [
    '📄', '📝', '📋', '📊', '📈', '📉',
    '🗂️', '📁', '📑', '🗃️', '📇', '🗄️',
    '💡', '🎯', '🚀', '⭐', '🔥', '💎',
    '🎨', '🎵', '📷', '🎬', '🎮', '🏆',
    '📚', '🔬', '🧪', '🔧', '⚙️', '🛠️',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}