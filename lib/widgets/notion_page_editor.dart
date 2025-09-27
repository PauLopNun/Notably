import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';
import '../models/block.dart';
import '../models/page.dart';
import '../providers/page_provider.dart';
import '../providers/collaboration_provider.dart';
import '../providers/favorites_provider.dart';
import 'blocks/block_widget_factory.dart';
import 'notion_slash_menu.dart';

class NotionPageEditor extends ConsumerStatefulWidget {
  final NotionPage page;
  final bool isReadOnly;

  const NotionPageEditor({
    super.key,
    required this.page,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<NotionPageEditor> createState() => _NotionPageEditorState();
}

class _NotionPageEditorState extends ConsumerState<NotionPageEditor> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, TextEditingController> _textControllers = {};
  String? _selectedBlockId;
  OverlayEntry? _slashMenuOverlay;
  
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final block in widget.page.blocks) {
      final blockId = block['id'] as String;
      _focusNodes[blockId] = FocusNode();
      final blockType = BlockTypeExtension.fromString(block['type'] as String);
      if (blockType.isTextBlock || blockType.isListBlock) {
        _textControllers[blockId] = TextEditingController();
        final content = block['content'] as Map<String, dynamic>?;
        if (content?['text'] != null) {
          _textControllers[blockId]!.text = content!['text'] as String;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocksAsync = ref.watch(pageBlocksProvider(widget.page.id));
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Page Header
          _buildPageHeader(),
          
          // Page Content
          Expanded(
            child: blocksAsync.when(
              data: (blocks) => _buildPageContent(blocks),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error loading blocks: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.isReadOnly ? _buildAddBlockButton() : null,
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Icon and Title
          Row(
            children: [
              // Page Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.page.icon ?? '📄',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Page Title
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: widget.page.title),
                  readOnly: widget.isReadOnly,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Página sin título',
                  ),
                  onChanged: _onPageTitleChanged,
                ),
              ),
              
              // Favorite button
              if (!widget.isReadOnly)
                Consumer(
                  builder: (context, ref, child) {
                    final isFavorite = ref.watch(isFavoriteProvider(widget.page.id));
                    return IconButton(
                      onPressed: () {
                        ref.read(favoritesProvider.notifier).toggleFavorite(widget.page);
                      },
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Theme.of(context).colorScheme.outline,
                      ),
                      tooltip: isFavorite ? 'Quitar de favoritas' : 'Agregar a favoritas',
                    );
                  },
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Collaboration Status
          _buildCollaborationStatus(),
        ],
      ),
    );
  }

  Widget _buildCollaborationStatus() {
    final collaborationState = ref.watch(collaborationProvider);
    
    if (!collaborationState.isConnected) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            '${collaborationState.activeUsers.length + 1} colaboradores',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(List<PageBlock> blocks) {
    if (blocks.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ReorderableColumn(
        onReorder: _onBlocksReordered,
        buildDraggableFeedback: (context, constraints, child) =>
            Material(
              color: Colors.transparent,
              child: Transform.scale(
                scale: 1.1,
                child: Transform.rotate(
                  angle: 0.02,
                  child: Container(
                    constraints: constraints,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Opacity(
                      opacity: 0.9,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
        children: blocks
            .map((block) => _buildBlockItem(block))
            .toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Página vacía',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para agregar tu primer bloque',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewBlock(BlockType.paragraph),
            icon: const Icon(Icons.add),
            label: const Text('Agregar bloque'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockItem(PageBlock block) {
    final isSelected = _selectedBlockId == block.id;
    
    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: isSelected ? Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(100),
          width: 1,
        ) : null,
        color: isSelected 
          ? Theme.of(context).colorScheme.primary.withAlpha(20)
          : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          if (!widget.isReadOnly)
            MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: GestureDetector(
                onTap: () => _selectBlock(block.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 36,
                  margin: const EdgeInsets.only(top: 4, right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected 
                      ? Theme.of(context).colorScheme.primary.withAlpha(60)
                      : Colors.transparent,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? Icons.open_with : Icons.drag_indicator,
                      key: ValueKey(isSelected),
                      size: 18,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withAlpha(120),
                    ),
                  ),
                ),
              ),
            ),
          
          // Block Content
          Expanded(
            child: Container(
              padding: isSelected 
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                : EdgeInsets.zero,
              child: BlockWidgetFactory.create(
                block: block,
                focusNode: _focusNodes[block.id]!,
                textController: _textControllers[block.id],
                isReadOnly: widget.isReadOnly,
                isSelected: isSelected,
                onTextChanged: (text) => _onBlockTextChanged(block.id, text),
                onTypeChanged: (type) => _onBlockTypeChanged(block.id, type),
                onDelete: () => _deleteBlock(block.id),
                onSlashCommand: (offset) => _showSlashMenu(block.id, offset),
                onFocusChanged: (hasFocus) {
                  if (hasFocus) {
                    _selectBlock(block.id);
                  } else if (_selectedBlockId == block.id) {
                    setState(() {
                      _selectedBlockId = null;
                    });
                  }
                },
              ),
            ),
          ),
          
          // Block Actions (show on hover/selection)
          if (!widget.isReadOnly && isSelected)
            _buildBlockActions(block),
        ],
      ),
    );
  }

  Widget _buildBlockActions(PageBlock block) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duplicate Block
          IconButton(
            icon: const Icon(Icons.content_copy, size: 16),
            onPressed: () => _duplicateBlock(block),
            tooltip: 'Duplicar bloque',
            visualDensity: VisualDensity.compact,
          ),
          // Delete Block
          IconButton(
            icon: Icon(Icons.delete_outline, size: 16, color: Theme.of(context).colorScheme.error),
            onPressed: () => _deleteBlock(block.id),
            tooltip: 'Eliminar bloque',
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildAddBlockButton() {
    return FloatingActionButton(
      onPressed: () => _showAddBlockMenu(),
      child: const Icon(Icons.add),
      tooltip: 'Agregar bloque',
    );
  }

  void _onPageTitleChanged(String title) {
    final updatedPage = widget.page.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
    // Update page through workspace pages notifier
    if (widget.page.workspaceId != null) {
      ref.read(workspacePagesNotifierProvider(widget.page.workspaceId!).notifier).updatePage(updatedPage);
    }
  }

  void _onBlocksReordered(int oldIndex, int newIndex) {
    // Handle block reordering logic
    if (oldIndex != newIndex) {
      ref.read(pageBlocksProvider(widget.page.id).notifier)
          .reorderBlocks(oldIndex, newIndex);
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bloque reordenado'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear selection after reordering
      setState(() {
        _selectedBlockId = null;
      });
    }
  }

  void _onBlockTextChanged(String blockId, String text) {
    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .updateBlockContent(blockId, {'text': text});
  }

  void _onBlockTypeChanged(String blockId, BlockType newType) {
    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .changeBlockType(blockId, newType);
  }

  void _selectBlock(String blockId) {
    setState(() {
      _selectedBlockId = blockId;
    });
  }

  void _addNewBlock(BlockType type, [int? position]) {
    final newBlock = PageBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      content: type.isTextBlock ? '' : '',
      position: position ?? widget.page.blocks.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .addBlock(newBlock);
  }

  void _deleteBlock(String blockId) {
    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .deleteBlock(blockId);
  }

  void _duplicateBlock(PageBlock block) {
    final newBlock = PageBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: block.type,
      content: block.content,
      position: block.position + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .addBlock(newBlock);
  }

  void _showSlashMenu(String blockId, Offset position) {
    _hideSlashMenu();

    _slashMenuOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy,
        child: NotionSlashMenu(
          onBlockTypeSelected: (type) {
            _hideSlashMenu();
            _onBlockTypeChanged(blockId, type);
          },
          onDismiss: _hideSlashMenu,
        ),
      ),
    );

    Overlay.of(context).insert(_slashMenuOverlay!);
  }

  void _hideSlashMenu() {
    _slashMenuOverlay?.remove();
    _slashMenuOverlay = null;
  }

  void _showAddBlockMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildAddBlockBottomSheet(),
    );
  }

  Widget _buildAddBlockBottomSheet() {
    final blockTypes = BlockType.values;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Agregar bloque',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: blockTypes.length,
            itemBuilder: (context, index) {
              final type = blockTypes[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _addNewBlock(type);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withAlpha(80),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        type.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.displayName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    try {
      // Hide slash menu first
      _hideSlashMenu();

      // Dispose scroll controller
      _scrollController.dispose();

      // Dispose focus nodes safely
      final focusNodes = List<FocusNode>.from(_focusNodes.values);
      _focusNodes.clear();
      for (final node in focusNodes) {
        node.dispose();
      }

      // Dispose text controllers safely
      final textControllers = List<TextEditingController>.from(_textControllers.values);
      _textControllers.clear();
      for (final controller in textControllers) {
        controller.dispose();
      }
    } catch (e) {
      print('Error disposing NotionPageEditor: $e');
    }

    super.dispose();
  }
}