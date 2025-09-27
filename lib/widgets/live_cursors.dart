import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace_member.dart';

class LiveCursorsOverlay extends ConsumerStatefulWidget {
  final TextEditingController textController;
  final List<WorkspaceMember> activeUsers;

  const LiveCursorsOverlay({
    super.key,
    required this.textController,
    required this.activeUsers,
  });

  @override
  ConsumerState<LiveCursorsOverlay> createState() => _LiveCursorsOverlayState();
}

class _LiveCursorsOverlayState extends ConsumerState<LiveCursorsOverlay>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _cursorAnimations = {};
  final Map<String, CursorPosition> _cursorPositions = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    for (final user in widget.activeUsers) {
      _cursorAnimations[user.userId] = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveCursorsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!mounted) return;

    try {
      // Add animations for new users
      for (final user in widget.activeUsers) {
        if (!_cursorAnimations.containsKey(user.userId)) {
          _cursorAnimations[user.userId] = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          )..repeat(reverse: true);
        }
      }

      // Remove animations for users who left
      final currentUserIds = widget.activeUsers.map((u) => u.userId).toSet();
      final controllersToRemove = <String>[];

      _cursorAnimations.forEach((userId, controller) {
        if (!currentUserIds.contains(userId)) {
          controllersToRemove.add(userId);
        }
      });

      // Dispose controllers safely
      for (final userId in controllersToRemove) {
        final controller = _cursorAnimations.remove(userId);
        controller?.dispose();
      }

      _cursorPositions.removeWhere((userId, _) => !currentUserIds.contains(userId));
    } catch (e) {
      print('Error updating cursor animations: $e');
    }
  }

  void updateCursorPosition(String userId, int textPosition) {
    if (!mounted || widget.textController.text.isEmpty) return;

    try {
      final textSpan = TextSpan(
        text: widget.textController.text,
        style: const TextStyle(fontSize: 16),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: MediaQuery.of(context).size.width - 32);

      final clampedPosition = textPosition.clamp(0, widget.textController.text.length);
      final textPos = TextPosition(offset: clampedPosition);
      final offset = textPainter.getOffsetForCaret(textPos, Rect.zero);

      if (mounted) {
        setState(() {
          _cursorPositions[userId] = CursorPosition(
            offset: offset,
            position: clampedPosition,
          );
        });
      }

      textPainter.dispose();
    } catch (e) {
      print('Error updating cursor position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Live cursors
        ...widget.activeUsers.map((user) => _buildUserCursor(user)),

        // Active users indicator
        Positioned(
          top: 8,
          right: 8,
          child: _buildActiveUsersIndicator(),
        ),
      ],
    );
  }

  Widget _buildUserCursor(WorkspaceMember user) {
    final cursorPosition = _cursorPositions[user.userId];
    final animation = _cursorAnimations[user.userId];

    if (cursorPosition == null || animation == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: cursorPosition.offset.dx + 16, // Account for padding
      top: cursorPosition.offset.dy + 16,  // Account for padding
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User name tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getUserColor(user.userId),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  user.name.split(' ').first, // First name only
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              // Cursor line
              Container(
                width: 2,
                height: 20,
                decoration: BoxDecoration(
                  color: _getUserColor(user.userId).withOpacity(
                    0.3 + (animation.value * 0.7),
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveUsersIndicator() {
    if (widget.activeUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // User avatars
          ...widget.activeUsers.take(3).map((user) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 8,
              backgroundColor: _getUserColor(user.userId),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),

          // More indicator
          if (widget.activeUsers.length > 3) ...[
            const SizedBox(width: 4),
            Text(
              '+${widget.activeUsers.length - 3}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],

          const SizedBox(width: 8),

          // Online indicator
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserColor(String userId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = userId.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  void dispose() {
    // Safely dispose all animation controllers
    try {
      final controllers = List<AnimationController>.from(_cursorAnimations.values);
      _cursorAnimations.clear();

      for (final controller in controllers) {
        if (!controller.isCompleted && !controller.isDismissed) {
          controller.stop();
        }
        controller.dispose();
      }
    } catch (e) {
      print('Error disposing cursor animations: $e');
    }

    _cursorPositions.clear();
    super.dispose();
  }
}

class CursorPosition {
  final Offset offset;
  final int position;

  CursorPosition({
    required this.offset,
    required this.position,
  });
}