import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';
import '../models/block.dart';
import '../models/page.dart';
import '../providers/page_provider.dart';
import '../providers/collaboration_provider.dart';
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
      _focusNodes[block.id] = FocusNode();
      if (block.type.isTextBlock || block.type.isListBlock) {
        _textControllers[block.id] = TextEditingController();
        if (block.content['text'] != null) {
          _textControllers[block.id]!.text = block.content['text'] as String;
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
    return Container(
      key: ValueKey(block.id),
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          if (!widget.isReadOnly)
            GestureDetector(
              onTap: () => _selectBlock(block.id),
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 8, right: 8),
                child: Icon(
                  Icons.drag_indicator,
                  size: 16,
                  color: _selectedBlockId == block.id
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withAlpha(128),
                ),
              ),
            ),
          
          // Block Content
          Expanded(
            child: BlockWidgetFactory.create(
              block: block,
              focusNode: _focusNodes[block.id]!,
              textController: _textControllers[block.id],
              isReadOnly: widget.isReadOnly,
              isSelected: _selectedBlockId == block.id,
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
    ref.read(pageProvider(widget.page.id).notifier).updatePage(updatedPage);
  }

  void _onBlocksReordered(int oldIndex, int newIndex) {
    // Handle block reordering logic
    ref.read(pageBlocksProvider(widget.page.id).notifier)
        .reorderBlocks(oldIndex, newIndex);
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
      pageId: widget.page.id,
      type: type,
      content: type.isTextBlock ? {'text': ''} : {},
      properties: {},
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
    _scrollController.dispose();
    _focusNodes.values.forEach((node) => node.dispose());
    _textControllers.values.forEach((controller) => controller.dispose());
    _hideSlashMenu();
    super.dispose();
  }
}