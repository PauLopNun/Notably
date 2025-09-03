import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/block.dart' as models;
import '../models/page.dart' as models;
import '../providers/page_provider.dart';
import '../providers/collaboration_provider.dart';
import 'blocks/text_block_widget.dart';
import 'blocks/heading_block_widget.dart';
import 'blocks/list_block_widget.dart';
import 'blocks/todo_block_widget.dart';
import 'blocks/quote_block_widget.dart';
import 'blocks/code_block_widget.dart';
import 'blocks/divider_block_widget.dart';
import 'blocks/callout_block_widget.dart';

class BlockEditor extends ConsumerStatefulWidget {
  final models.NotionPage page;
  final bool isReadOnly;

  const BlockEditor({
    super.key,
    required this.page,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends ConsumerState<BlockEditor> {
  String? _selectedBlockId;
  String? _hoveredBlockId;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    
    // Join collaboration for this page
    if (!widget.isReadOnly) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(collaborationProvider.notifier).joinPage(
          pageId: widget.page.id,
          workspaceId: widget.page.workspaceId,
        );
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    
    // Leave collaboration
    if (!widget.isReadOnly) {
      ref.read(collaborationProvider.notifier).leavePage();
    }
    
    super.dispose();
  }

  TextEditingController _getController(String blockId) {
    return _controllers.putIfAbsent(blockId, () => TextEditingController());
  }

  FocusNode _getFocusNode(String blockId) {
    return _focusNodes.putIfAbsent(blockId, () => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    final blocksAsync = ref.watch(pageBlocksProvider(widget.page.id));
    
    return blocksAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading blocks: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(pageBlocksProvider(widget.page.id)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (blocks) => _buildEditor(blocks),
    );
  }

  Widget _buildEditor(List<models.PageBlock> blocks) {
    if (blocks.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: ReorderableColumn(
          onReorder: widget.isReadOnly ? null : (oldIndex, newIndex) => _onReorder(oldIndex, newIndex),
          children: blocks.asMap().entries.map((entry) {
            final index = entry.key;
            final block = entry.value;
            
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildBlockWidget(block, index),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Start writing...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Click to add your first block',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (!widget.isReadOnly)
            ElevatedButton.icon(
              onPressed: () => _addBlock(models.BlockType.paragraph, 0),
              icon: const Icon(Icons.add),
              label: const Text('Add Block'),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockWidget(models.PageBlock block, int index) {
    final isSelected = _selectedBlockId == block.id;
    final isHovered = _hoveredBlockId == block.id;
    
    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredBlockId = block.id),
        onExit: (_) => setState(() => _hoveredBlockId = null),
        child: GestureDetector(
          onTap: () => setState(() => _selectedBlockId = block.id),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : isHovered
                      ? Border.all(color: Colors.grey.withOpacity(0.3))
                      : null,
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.05)
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Block handle (drag indicator)
                if (!widget.isReadOnly && (isHovered || isSelected))
                  Container(
                    width: 24,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Icon(
                      Icons.drag_indicator,
                      size: 16,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                
                // Block content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: _buildBlockContent(block),
                  ),
                ),
                
                // Block actions
                if (!widget.isReadOnly && (isHovered || isSelected))
                  _buildBlockActions(block, index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlockContent(models.PageBlock block) {
    switch (block.type) {
      case models.BlockType.paragraph:
        return TextBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onEnterPressed: () => _handleEnterPressed(block),
          onBackspacePressed: () => _handleBackspacePressed(block),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.heading1:
      case models.BlockType.heading2:
      case models.BlockType.heading3:
        return HeadingBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onEnterPressed: () => _handleEnterPressed(block),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.bulletedList:
      case models.BlockType.numberedList:
        return ListBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onEnterPressed: () => _handleEnterPressed(block),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.todo:
        return TodoBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onCheckedChanged: (checked) => _updateBlockContent(block, {'checked': checked}),
          onEnterPressed: () => _handleEnterPressed(block),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.quote:
        return QuoteBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onEnterPressed: () => _handleEnterPressed(block),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.code:
        return CodeBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'code': text}),
          onLanguageChanged: (language) => _updateBlockContent(block, {'language': language}),
          readOnly: widget.isReadOnly,
        );
      
      case models.BlockType.divider:
        return const DividerBlockWidget();
      
      case models.BlockType.callout:
        return CalloutBlockWidget(
          block: block,
          controller: _getController(block.id),
          focusNode: _getFocusNode(block.id),
          onChanged: (text) => _updateBlockContent(block, {'text': text}),
          onIconChanged: (icon) => _updateBlockContent(block, {'icon': icon}),
          readOnly: widget.isReadOnly,
        );
      
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Unsupported block type: ${block.type.displayName}',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        );
    }
  }

  Widget _buildBlockActions(models.PageBlock block, int index) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add block above
          IconButton(
            iconSize: 16,
            onPressed: () => _showBlockTypeSelector(context, block, index),
            icon: const Icon(Icons.add),
            tooltip: 'Add block above',
          ),
          
          // More options
          PopupMenuButton<String>(
            iconSize: 16,
            onSelected: (value) => _handleBlockAction(value, block, index),
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
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'move_up',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 16),
                    SizedBox(width: 8),
                    Text('Move up'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'move_down',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, size: 16),
                    SizedBox(width: 8),
                    Text('Move down'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBlockTypeSelector(BuildContext context, models.PageBlock block, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a block',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: models.BlockType.values.map((type) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    _addBlock(type, index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(type.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBlockAction(String action, models.PageBlock block, int index) async {
    switch (action) {
      case 'duplicate':
        await _duplicateBlock(block, index + 1);
        break;
      case 'delete':
        await _deleteBlock(block);
        break;
      case 'move_up':
        if (index > 0) {
          await _moveBlock(block, index - 1);
        }
        break;
      case 'move_down':
        await _moveBlock(block, index + 1);
        break;
    }
  }

  Future<void> _addBlock(models.BlockType type, int position) async {
    try {
      final content = _getDefaultContentForType(type);
      await ref.read(pageBlocksProvider(widget.page.id).notifier).createBlock(
        type: type,
        content: content,
        position: position,
      );
    } catch (e) {
      _showError('Failed to add block: $e');
    }
  }

  Future<void> _duplicateBlock(models.PageBlock block, int position) async {
    try {
      await ref.read(pageBlocksProvider(widget.page.id).notifier).createBlock(
        type: block.type,
        content: Map.from(block.content),
        position: position,
        properties: Map.from(block.properties),
      );
    } catch (e) {
      _showError('Failed to duplicate block: $e');
    }
  }

  Future<void> _deleteBlock(models.PageBlock block) async {
    try {
      await ref.read(pageBlocksProvider(widget.page.id).notifier).deleteBlock(block.id);
      
      // Clean up controllers and focus nodes
      _controllers.remove(block.id)?.dispose();
      _focusNodes.remove(block.id)?.dispose();
      
      setState(() {
        if (_selectedBlockId == block.id) {
          _selectedBlockId = null;
        }
        if (_hoveredBlockId == block.id) {
          _hoveredBlockId = null;
        }
      });
    } catch (e) {
      _showError('Failed to delete block: $e');
    }
  }

  Future<void> _moveBlock(models.PageBlock block, int newPosition) async {
    try {
      await ref.read(pageBlocksProvider(widget.page.id).notifier).moveBlock(
        blockId: block.id,
        newParentId: block.parentBlockId,
        newPosition: newPosition,
      );
    } catch (e) {
      _showError('Failed to move block: $e');
    }
  }

  Future<void> _updateBlockContent(models.PageBlock block, Map<String, dynamic> newContent) async {
    try {
      final updatedBlock = block.copyWith(
        content: {...block.content, ...newContent},
      );
      
      await ref.read(pageBlocksProvider(widget.page.id).notifier).updateBlock(updatedBlock);
      
      // Broadcast to other collaborators
      if (!widget.isReadOnly) {
        ref.read(collaborationProvider.notifier).broadcastBlockUpdate(updatedBlock);
      }
    } catch (e) {
      _showError('Failed to update block: $e');
    }
  }

  void _handleEnterPressed(models.PageBlock block) {
    if (widget.isReadOnly) return;
    
    // Add a new paragraph block after the current one
    _addBlock(models.BlockType.paragraph, block.position + 1);
  }

  void _handleBackspacePressed(models.PageBlock block) {
    if (widget.isReadOnly) return;
    
    final text = block.content['text'] as String? ?? '';
    if (text.isEmpty && block.type == models.BlockType.paragraph) {
      // Delete empty paragraph blocks
      _deleteBlock(block);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    // This will be handled by the ReorderableColumn widget
    // The actual reordering logic should update the backend
  }

  Map<String, dynamic> _getDefaultContentForType(models.BlockType type) {
    switch (type) {
      case models.BlockType.todo:
        return {'text': '', 'checked': false};
      case models.BlockType.code:
        return {'code': '', 'language': 'text'};
      case models.BlockType.callout:
        return {'text': '', 'icon': '💡'};
      case models.BlockType.divider:
        return {};
      default:
        return {'text': ''};
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}