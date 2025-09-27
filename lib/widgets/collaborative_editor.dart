import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/collaborative_operation.dart';
import '../models/note.dart';
import '../models/workspace_member.dart';
import '../providers/collaboration_provider.dart';
import '../services/realtime_collab_service.dart';
import '../services/webrtc_service.dart';
import 'live_cursors.dart';
import 'collaboration_toolbar.dart';

class CollaborativeEditor extends ConsumerStatefulWidget {
  final Note note;
  final String userId;
  final String userName;
  final Function(List<dynamic> content) onContentChanged;

  const CollaborativeEditor({
    super.key,
    required this.note,
    required this.userId,
    required this.userName,
    required this.onContentChanged,
  });

  @override
  ConsumerState<CollaborativeEditor> createState() => _CollaborativeEditorState();
}

class _CollaborativeEditorState extends ConsumerState<CollaborativeEditor> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final RealtimeCollabService _realtimeService = RealtimeCollabService();

  List<dynamic> _currentContent = [];
  final List<CollaborativeOperation> _pendingOperations = [];
  Timer? _debounceTimer;
  Timer? _cursorTimer;

  StreamSubscription? _incomingContentSubscription;
  StreamSubscription? _webRtcOperationsSubscription;
  StreamSubscription? _webRtcPresenceSubscription;

  int _lastCursorPosition = 0;

  @override
  void initState() {
    super.initState();
    _initializeEditor();
    _setupCollaboration();
  }

  void _initializeEditor() {
    _currentContent = List.from(widget.note.content);
    _textController.text = _contentToText(_currentContent);

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _setupCollaboration() async {
    // Initialize WebRTC service
    final webRtcService = ref.read(webRtcServiceProvider);
    await webRtcService.initialize();

    // Connect to document
    try {
      await webRtcService.connectToDocument(
        documentId: widget.note.id,
        userId: widget.userId,
        userName: widget.userName,
      );

      // Join realtime collaboration
      await _realtimeService.joinDocument(widget.note.id);

      // Mark as collaborating
      ref.read(collaborationProvider.notifier).startCollaboration();
      ref.read(collaborationProvider.notifier).connect();

    } catch (e) {
      print('Failed to setup collaboration: $e');
    }

    // Listen to incoming content changes
    _incomingContentSubscription = _realtimeService.incomingContentStream.listen(
      _handleIncomingContent,
    );

    // Listen to WebRTC operations
    _webRtcOperationsSubscription = webRtcService.operations.listen(
      _handleIncomingOperation,
    );

    // Listen to presence updates
    _webRtcPresenceSubscription = webRtcService.presenceUpdates.listen(
      _handlePresenceUpdate,
    );
  }

  void _onTextChanged() {
    final newText = _textController.text;
    final newContent = _textToContent(newText);

    if (!_contentEquals(newContent, _currentContent)) {
      // Generate operation
      final operation = _generateOperation(_currentContent, newContent);
      if (operation != null) {
        _pendingOperations.add(operation);

        // Send operation via WebRTC
        final webRtcService = ref.read(webRtcServiceProvider);
        webRtcService.sendOperation(operation);

        // Debounce sending full content
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 300), () {
          _realtimeService.sendFullContent(newContent);
          widget.onContentChanged(newContent);
        });
      }

      _currentContent = newContent;
    }

    // Send cursor position
    _sendCursorPosition();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _sendCursorPosition();
      });
    } else {
      _cursorTimer?.cancel();
    }
  }

  void _sendCursorPosition() {
    final position = _textController.selection.start;
    if (position != _lastCursorPosition) {
      _lastCursorPosition = position;

      final webRtcService = ref.read(webRtcServiceProvider);
      webRtcService.sendCursorPosition(
        position: position,
        selectionLength: _textController.selection.end - _textController.selection.start,
      );
    }
  }

  void _handleIncomingContent(List<dynamic> content) {
    if (!_contentEquals(content, _currentContent)) {
      setState(() {
        _currentContent = List.from(content);
        final newText = _contentToText(content);
        if (_textController.text != newText) {
          final cursorPosition = _textController.selection.start;
          _textController.text = newText;
          // Try to maintain cursor position
          _textController.selection = TextSelection.collapsed(
            offset: cursorPosition.clamp(0, newText.length),
          );
        }
      });
    }
  }

  void _handleIncomingOperation(CollaborativeOperation operation) {
    if (operation.authorId != widget.userId) {
      // Apply operation transformation
      final transformedOp = _transformOperation(operation);
      if (transformedOp != null) {
        _applyOperation(transformedOp);
      }
    }
  }

  void _handlePresenceUpdate(Map<String, dynamic> presence) {
    // Update active collaborators list
    final collaborators = ref.read(collaborationProvider).activeUsers;
    // Find or create workspace member from presence data
    final member = WorkspaceMember(
      id: presence['userId'],
      userId: presence['userId'],
      workspaceId: '',
      name: presence['userName'] ?? 'Unknown User',
      email: '',
      role: MemberRole.member,
      joinedAt: DateTime.now(),
      isActive: true,
    );

    if (!collaborators.any((c) => c.userId == member.userId)) {
      ref.read(collaborationProvider.notifier).setActiveUsers([...collaborators, member]);
    }
  }

  CollaborativeOperation? _generateOperation(List<dynamic> oldContent, List<dynamic> newContent) {
    final oldText = _contentToText(oldContent);
    final newText = _contentToText(newContent);

    if (oldText == newText) return null;

    // Simple diff algorithm - find first difference
    int commonStart = 0;
    while (commonStart < oldText.length &&
           commonStart < newText.length &&
           oldText[commonStart] == newText[commonStart]) {
      commonStart++;
    }

    int commonEnd = 0;
    while (commonEnd < oldText.length - commonStart &&
           commonEnd < newText.length - commonStart &&
           oldText[oldText.length - 1 - commonEnd] == newText[newText.length - 1 - commonEnd]) {
      commonEnd++;
    }

    final deletedLength = oldText.length - commonStart - commonEnd;
    final insertedText = newText.substring(commonStart, newText.length - commonEnd);

    if (deletedLength > 0 && insertedText.isNotEmpty) {
      // Replace operation - delete then insert
      return CollaborativeOperationFactory.insert(
        text: insertedText,
        position: commonStart,
        authorId: widget.userId,
        authorName: widget.userName,
        documentId: widget.note.id,
      );
    } else if (deletedLength > 0) {
      // Delete operation
      return CollaborativeOperationFactory.delete(
        position: commonStart,
        length: deletedLength,
        authorId: widget.userId,
        authorName: widget.userName,
        documentId: widget.note.id,
      );
    } else if (insertedText.isNotEmpty) {
      // Insert operation
      return CollaborativeOperationFactory.insert(
        text: insertedText,
        position: commonStart,
        authorId: widget.userId,
        authorName: widget.userName,
        documentId: widget.note.id,
      );
    }

    return null;
  }

  CollaborativeOperation? _transformOperation(CollaborativeOperation operation) {
    CollaborativeOperation? transformed = operation;

    // Transform against all pending operations
    for (final pendingOp in _pendingOperations) {
      transformed = transformed?.transform(pendingOp);
      if (transformed == null) break;
    }

    return transformed;
  }

  void _applyOperation(CollaborativeOperation operation) {
    final currentText = _textController.text;
    String newText = currentText;

    switch (operation.type) {
      case OperationType.insert:
        if (operation.text != null && operation.position <= newText.length) {
          newText = newText.substring(0, operation.position) +
                   operation.text! +
                   newText.substring(operation.position);
        }
        break;
      case OperationType.delete:
        if (operation.length != null &&
            operation.position + operation.length! <= newText.length) {
          newText = newText.substring(0, operation.position) +
                   newText.substring(operation.position + operation.length!);
        }
        break;
      case OperationType.format:
        // Handle formatting operations if needed
        break;
      case OperationType.retain:
        // No change needed for retain operations
        break;
    }

    if (newText != currentText) {
      final cursorPosition = _textController.selection.start;
      _textController.text = newText;
      _textController.selection = TextSelection.collapsed(
        offset: cursorPosition.clamp(0, newText.length),
      );

      _currentContent = _textToContent(newText);
    }
  }

  String _contentToText(List<dynamic> content) {
    if (content.isEmpty) return '';
    return content.map((item) => item.toString()).join('\n');
  }

  List<dynamic> _textToContent(String text) {
    if (text.isEmpty) return [];
    return text.split('\n');
  }

  bool _contentEquals(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final collaborationState = ref.watch(collaborationProvider);
    final webRtcState = ref.watch(webRtcConnectionStateProvider);

    return Column(
      children: [
        // Collaboration Toolbar
        if (collaborationState.isConnected)
          CollaborationToolbar(
            activeUsers: collaborationState.activeUsers,
            connectionState: webRtcState.when(
              data: (state) => state,
              loading: () => WebRtcConnectionState.connecting,
              error: (_, __) => WebRtcConnectionState.failed,
            ),
            onInviteUser: _showInviteDialog,
          ),

        // Editor with Live Cursors Overlay
        Expanded(
          child: Stack(
            children: [
              // Main Editor
              TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Comienza a escribir...',
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              // Live Cursors Overlay
              if (collaborationState.isConnected)
                LiveCursorsOverlay(
                  textController: _textController,
                  activeUsers: collaborationState.activeUsers,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => InviteUserDialog(
        noteId: widget.note.id,
        onUserInvited: (email) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invitación enviada a $email')),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Cancel timers first
    _debounceTimer?.cancel();
    _cursorTimer?.cancel();

    // Cancel subscriptions safely
    _incomingContentSubscription?.cancel();
    _webRtcOperationsSubscription?.cancel();
    _webRtcPresenceSubscription?.cancel();

    // Clean up services
    try {
      _realtimeService.leave();
      _realtimeService.dispose();
    } catch (e) {
      print('Error disposing realtime service: $e');
    }

    try {
      final webRtcService = ref.read(webRtcServiceProvider);
      webRtcService.disconnect();
    } catch (e) {
      print('Error disconnecting WebRTC: $e');
    }

    try {
      ref.read(collaborationProvider.notifier).stopCollaboration();
      ref.read(collaborationProvider.notifier).disconnect();
    } catch (e) {
      print('Error updating collaboration state: $e');
    }

    // Remove listeners before disposing controllers
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);

    // Dispose controllers
    _textController.dispose();
    _focusNode.dispose();

    super.dispose();
  }
}

class InviteUserDialog extends StatefulWidget {
  final String noteId;
  final Function(String email) onUserInvited;

  const InviteUserDialog({
    super.key,
    required this.noteId,
    required this.onUserInvited,
  });

  @override
  State<InviteUserDialog> createState() => _InviteUserDialogState();
}

class _InviteUserDialogState extends State<InviteUserDialog> {
  final TextEditingController _emailController = TextEditingController();
  MemberRole _selectedRole = MemberRole.member;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invitar colaborador'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email del usuario',
              hintText: 'usuario@ejemplo.com',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<MemberRole>(
            value: _selectedRole,
            decoration: const InputDecoration(
              labelText: 'Rol',
              prefixIcon: Icon(Icons.security),
            ),
            items: MemberRole.values.map((role) {
              return DropdownMenuItem(
                value: role,
                child: Text(role.displayName),
              );
            }).toList(),
            onChanged: (role) {
              if (role != null) {
                setState(() {
                  _selectedRole = role;
                });
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
        ElevatedButton(
          onPressed: _isLoading ? null : _sendInvitation,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Invitar'),
        ),
      ],
    );
  }

  Future<void> _sendInvitation() async {
    if (_emailController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual invitation logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      widget.onUserInvited(_emailController.text.trim());
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar invitación: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}