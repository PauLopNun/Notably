import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/block.dart';

class BlockToolbar extends ConsumerStatefulWidget {
  final PageBlock block;
  final VoidCallback? onDeleteBlock;
  final VoidCallback? onDuplicateBlock;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final Function(BlockType)? onChangeBlockType;
  final VoidCallback? onAddBlockAbove;
  final VoidCallback? onAddBlockBelow;

  const BlockToolbar({
    super.key,
    required this.block,
    this.onDeleteBlock,
    this.onDuplicateBlock,
    this.onMoveUp,
    this.onMoveDown,
    this.onChangeBlockType,
    this.onAddBlockAbove,
    this.onAddBlockBelow,
  });

  @override
  ConsumerState<BlockToolbar> createState() => _BlockToolbarState();
}

class _BlockToolbarState extends ConsumerState<BlockToolbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -20.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void show() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
    }
  }

  void hide() {
    if (_isVisible) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() => _isVisible = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withAlpha(100),
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  MouseRegion(
                    cursor: SystemMouseCursors.move,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.drag_indicator,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // Add Block Above
                  _ToolbarButton(
                    icon: Icons.add,
                    tooltip: 'Add block above',
                    onPressed: widget.onAddBlockAbove,
                  ),

                  // Block Type Selector
                  _BlockTypeSelector(
                    currentType: widget.block.type,
                    onTypeChanged: widget.onChangeBlockType,
                  ),

                  // Move Up
                  _ToolbarButton(
                    icon: Icons.keyboard_arrow_up,
                    tooltip: 'Move up',
                    onPressed: widget.onMoveUp,
                  ),

                  // Move Down
                  _ToolbarButton(
                    icon: Icons.keyboard_arrow_down,
                    tooltip: 'Move down',
                    onPressed: widget.onMoveDown,
                  ),

                  const VerticalDivider(width: 1),

                  // Duplicate Block
                  _ToolbarButton(
                    icon: Icons.content_copy,
                    tooltip: 'Duplicate block',
                    onPressed: widget.onDuplicateBlock,
                  ),

                  // More Options
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    tooltip: 'More options',
                    padding: const EdgeInsets.all(4),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'add_below',
                        child: ListTile(
                          leading: Icon(Icons.add, size: 16),
                          title: Text('Add block below'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'copy_link',
                        child: ListTile(
                          leading: Icon(Icons.link, size: 16),
                          title: Text('Copy block link'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: Icon(Icons.download, size: 16),
                          title: Text('Export block'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, size: 16, color: Colors.red),
                          title: Text('Delete block', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                    onSelected: (action) => _handleMenuAction(context, action),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'add_below':
        widget.onAddBlockBelow?.call();
        break;
      case 'copy_link':
        // TODO: Implement copy block link functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Block link copied to clipboard')),
        );
        break;
      case 'export':
        // TODO: Implement block export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Block export feature coming soon')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Block'),
        content: const Text(
          'Are you sure you want to delete this block? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteBlock?.call();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurfaceVariant.withAlpha(100),
          ),
        ),
      ),
    );
  }
}

class _BlockTypeSelector extends StatelessWidget {
  final BlockType currentType;
  final Function(BlockType)? onTypeChanged;

  const _BlockTypeSelector({
    required this.currentType,
    this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<BlockType>(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBlockTypeIcon(currentType),
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      tooltip: 'Change block type',
      itemBuilder: (context) => BlockType.values.map((type) {
        return PopupMenuItem<BlockType>(
          value: type,
          child: Row(
            children: [
              Icon(_getBlockTypeIcon(type), size: 16),
              const SizedBox(width: 8),
              Text(_getBlockTypeName(type)),
              if (type == currentType) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onSelected: onTypeChanged,
    );
  }

  IconData _getBlockTypeIcon(BlockType type) {
    switch (type) {
      case BlockType.paragraph:
        return Icons.text_fields;
      case BlockType.heading1:
        return Icons.title;
      case BlockType.heading2:
        return Icons.title;
      case BlockType.heading3:
        return Icons.title;
      case BlockType.bulletedList:
        return Icons.format_list_bulleted;
      case BlockType.numberedList:
        return Icons.format_list_numbered;
      case BlockType.todo:
        return Icons.check_box_outline_blank;
      case BlockType.quote:
        return Icons.format_quote;
      case BlockType.code:
        return Icons.code;
      case BlockType.divider:
        return Icons.horizontal_rule;
      case BlockType.callout:
        return Icons.campaign;
      case BlockType.table:
        return Icons.table_chart;
      case BlockType.image:
        return Icons.image;
    }
  }

  String _getBlockTypeName(BlockType type) {
    switch (type) {
      case BlockType.paragraph:
        return 'Text';
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.bulletedList:
        return 'Bulleted List';
      case BlockType.numberedList:
        return 'Numbered List';
      case BlockType.todo:
        return 'To-do';
      case BlockType.quote:
        return 'Quote';
      case BlockType.code:
        return 'Code';
      case BlockType.divider:
        return 'Divider';
      case BlockType.callout:
        return 'Callout';
      case BlockType.table:
        return 'Table';
      case BlockType.image:
        return 'Image';
    }
  }
}

// Enhanced Block Widget that includes the toolbar
class BlockWithToolbar extends StatefulWidget {
  final PageBlock block;
  final Widget child;
  final VoidCallback? onDeleteBlock;
  final VoidCallback? onDuplicateBlock;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final Function(BlockType)? onChangeBlockType;
  final VoidCallback? onAddBlockAbove;
  final VoidCallback? onAddBlockBelow;

  const BlockWithToolbar({
    super.key,
    required this.block,
    required this.child,
    this.onDeleteBlock,
    this.onDuplicateBlock,
    this.onMoveUp,
    this.onMoveDown,
    this.onChangeBlockType,
    this.onAddBlockAbove,
    this.onAddBlockBelow,
  });

  @override
  State<BlockWithToolbar> createState() => _BlockWithToolbarState();
}

class _BlockWithToolbarState extends State<BlockWithToolbar> {
  final GlobalKey<_BlockToolbarState> _toolbarKey = GlobalKey();
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _toolbarKey.currentState?.show();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _toolbarKey.currentState?.hide();
      },
      child: Container(
        decoration: _isHovered
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: widget.child,
            ),
            if (_isHovered)
              Positioned(
                left: 4,
                top: 4,
                child: BlockToolbar(
                  key: _toolbarKey,
                  block: widget.block,
                  onDeleteBlock: widget.onDeleteBlock,
                  onDuplicateBlock: widget.onDuplicateBlock,
                  onMoveUp: widget.onMoveUp,
                  onMoveDown: widget.onMoveDown,
                  onChangeBlockType: widget.onChangeBlockType,
                  onAddBlockAbove: widget.onAddBlockAbove,
                  onAddBlockBelow: widget.onAddBlockBelow,
                ),
              ),
          ],
        ),
      ),
    );
  }
}