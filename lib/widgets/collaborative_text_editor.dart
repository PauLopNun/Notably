import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/collaborative_operation.dart';
import '../models/note.dart';
import '../providers/collaboration_provider.dart';
import '../services/collaborative_editor_service.dart';
import 'dart:convert';

class CollaborativeTextEditor extends ConsumerStatefulWidget {
  final Note? note;
  final Function(String content) onContentChanged;

  const CollaborativeTextEditor({
    super.key,
    this.note,
    required this.onContentChanged,
  });

  @override
  ConsumerState<CollaborativeTextEditor> createState() => _CollaborativeTextEditorState();
}

class _CollaborativeTextEditorState extends ConsumerState<CollaborativeTextEditor> {
  late QuillController _controller;
  late CollaborativeEditorService _collaborativeService;
  final FocusNode _focusNode = FocusNode();
  int _lastKnownSelection = 0;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
  }

  void _initializeEditor() {
    // Initialize Quill controller with existing content
    final hasContent = widget.note?.content.isNotEmpty ?? false;
    final doc = hasContent
      ? Document.fromJson(widget.note!.content)
      : Document()..insert(0, '');
    
    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    // Listen to document changes
    _controller.addListener(_onDocumentChanged);
    
    // Listen to selection changes for cursor broadcasting
    _controller.addListener(_onSelectionChanged);
    
    // Initialize collaborative service
    _collaborativeService = ref.read(collaborativeEditorProvider);
    
    // Join document collaboration if note exists
    if (widget.note != null) {
      _joinCollaboration();
    }
  }

  Future<void> _joinCollaboration() async {
    if (widget.note == null) return;
    
    try {
      await _collaborativeService.joinDocument(widget.note!.id);
      
      // Listen to remote operations
      _collaborativeService.operationsStream.listen(_handleRemoteOperation);
      
    } catch (e) {
      debugPrint('Error joining collaboration: $e');
    }
  }

  void _onDocumentChanged() {
    if (_controller.document.isEmpty) return;
    
    final content = jsonEncode(_controller.document.toDelta().toJson());
    widget.onContentChanged(content);
    
    // Don't broadcast every keystroke immediately - debounce would be better
    // For now, we'll send operations on significant changes
  }

  void _onSelectionChanged() {
    final selection = _controller.selection;
    if (selection.baseOffset != _lastKnownSelection) {
      _lastKnownSelection = selection.baseOffset;
      
      // Broadcast cursor position
      _collaborativeService.sendCursorUpdate(
        selection.baseOffset,
        selection.extentOffset,
      );
    }
  }

  void _handleRemoteOperation(CollaborativeOperation operation) {
    if (operation.type == OperationType.insert && operation.content != null) {
      // Apply remote insertion
      final position = operation.position ?? 0;
      _controller.document.insert(position, operation.content!);
      
    } else if (operation.type == OperationType.delete && operation.content != null) {
      // Apply remote deletion
      final position = operation.position ?? 0;
      final length = operation.content!.length;
      _controller.document.delete(position, length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cursorsAsync = ref.watch(realTimeCursorsStreamProvider);
    final collaboratorsAsync = ref.watch(collaboratorsStreamProvider);

    return Column(
      children: [
        // Collaboration status bar
        _buildCollaborationStatusBar(collaboratorsAsync),
        
        // Main editor
        Expanded(
          child: Stack(
            children: [
              // Quill editor
              QuillEditor(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: ScrollController(),
                autoFocus: false,
                expands: true,
                readOnly: false,
                padding: const EdgeInsets.all(16.0),
                placeholder: 'Escribe tu nota aquí...',
              ),
              
              // Overlay for cursors
              cursorsAsync.when(
                data: (cursors) => _buildCursorsOverlay(cursors),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        
        // Toolbar
        QuillToolbar.basic(
          controller: _controller,
          multiRowsDisplay: false,
          showAlignmentButtons: true,
          showBackgroundColorButton: true,
          showBoldButton: true,
          showClearFormat: true,
          showCodeBlock: true,
          showColorButton: true,
          showDirection: true,
          showFontFamily: false,
          showFontSize: true,
          showHeaderStyle: true,
          showIndent: true,
          showInlineCode: true,
          showItalicButton: true,
          showJustifyAlignment: true,
          showLeftAlignment: true,
          showLink: true,
          showListBullets: true,
          showListCheck: true,
          showListNumbers: true,
          showQuote: true,
          showRedo: true,
          showRightAlignment: true,
          showSmallButton: false,
          showStrikeThrough: true,
          showSubscript: true,
          showSuperscript: true,
          showUnderLineButton: true,
          showUndo: true,
        ),
      ],
    );
  }

  Widget _buildCollaborationStatusBar(AsyncValue<List<String>> collaboratorsAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(80),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.people_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: collaboratorsAsync.when(
              data: (collaborators) {
                if (collaborators.isEmpty) {
                  return Text(
                    'Solo tú',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Text(
                  '${collaborators.length + 1} colaboradores activos',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
              loading: () => Text(
                'Conectando...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              error: (_, __) => Text(
                'Sin conexión',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ),
          // Share button
          IconButton(
            onPressed: _showShareDialog,
            icon: const Icon(Icons.share),
            tooltip: 'Compartir documento',
          ),
        ],
      ),
    );
  }

  Widget _buildCursorsOverlay(List<CursorPosition> cursors) {
    return Stack(
      children: cursors.map((cursor) => _buildCursorIndicator(cursor)).toList(),
    );
  }

  Widget _buildCursorIndicator(CursorPosition cursor) {
    // This is a simplified cursor indicator
    // In a real implementation, you'd need to calculate exact positions
    return Positioned(
      left: 16,
      top: 50 + (cursor.position * 0.5), // Simplified positioning
      child: Container(
        width: 2,
        height: 20,
        decoration: BoxDecoration(
          color: Color(int.parse(cursor.color.substring(1), radix: 16) + 0xFF000000),
          borderRadius: BorderRadius.circular(1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showCursorInfo(cursor),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Color(int.parse(cursor.color.substring(1), radix: 16) + 0xFF000000),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cursor.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCursorInfo(CursorPosition cursor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${cursor.userName} está editando'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email del colaborador',
                hintText: 'usuario@email.com',
              ),
              onSubmitted: (email) {
                if (email.isNotEmpty && widget.note != null) {
                  _inviteCollaborator(email);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _inviteCollaborator(String email) async {
    if (widget.note == null) return;
    
    try {
      await _collaborativeService.inviteCollaborator(widget.note!.id, email);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitación enviada a $email'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar invitación: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.removeListener(_onSelectionChanged);
    _controller.dispose();
    _focusNode.dispose();
    _collaborativeService.leaveDocument();
    super.dispose();
  }
}