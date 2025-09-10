import 'package:flutter/material.dart';
import '../models/block.dart';

class NotionSlashMenu extends StatefulWidget {
  final Function(BlockType) onBlockTypeSelected;
  final VoidCallback onDismiss;
  final String initialQuery;

  const NotionSlashMenu({
    super.key,
    required this.onBlockTypeSelected,
    required this.onDismiss,
    this.initialQuery = '',
  });

  @override
  State<NotionSlashMenu> createState() => _NotionSlashMenuState();
}

class _NotionSlashMenuState extends State<NotionSlashMenu> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<BlockType> _filteredTypes = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _filteredTypes = _getFilteredBlockTypes('');
    _searchController.addListener(_onSearchChanged);
    
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredTypes = _getFilteredBlockTypes(_searchController.text);
      _selectedIndex = 0;
    });
  }

  List<BlockType> _getFilteredBlockTypes(String query) {
    final queryLower = query.toLowerCase().trim();
    
    if (queryLower.isEmpty) {
      return _getMostUsedBlockTypes();
    }

    // Filter by display name or keywords
    return BlockType.values.where((type) {
      final name = type.displayName.toLowerCase();
      final keywords = _getBlockKeywords(type);
      
      return name.contains(queryLower) ||
             keywords.any((keyword) => keyword.contains(queryLower));
    }).toList();
  }

  List<BlockType> _getMostUsedBlockTypes() {
    return [
      BlockType.paragraph,
      BlockType.heading1,
      BlockType.heading2,
      BlockType.heading3,
      BlockType.bulletedList,
      BlockType.numberedList,
      BlockType.todo,
      BlockType.quote,
      BlockType.code,
      BlockType.divider,
      BlockType.callout,
      BlockType.toggle,
      BlockType.image,
      BlockType.table,
      BlockType.bookmark,
      BlockType.equation,
    ];
  }

  List<String> _getBlockKeywords(BlockType type) {
    switch (type) {
      case BlockType.paragraph:
        return ['text', 'paragraph', 'p'];
      case BlockType.heading1:
        return ['heading', 'h1', 'title', 'large'];
      case BlockType.heading2:
        return ['heading', 'h2', 'subtitle', 'medium'];
      case BlockType.heading3:
        return ['heading', 'h3', 'small'];
      case BlockType.bulletedList:
        return ['bullet', 'list', 'ul', 'unordered'];
      case BlockType.numberedList:
        return ['number', 'list', 'ol', 'ordered'];
      case BlockType.todo:
        return ['todo', 'task', 'check', 'checkbox'];
      case BlockType.quote:
        return ['quote', 'blockquote', 'citation'];
      case BlockType.code:
        return ['code', 'programming', 'snippet'];
      case BlockType.divider:
        return ['divider', 'separator', 'line', 'break'];
      case BlockType.callout:
        return ['callout', 'note', 'info', 'highlight'];
      case BlockType.toggle:
        return ['toggle', 'collapse', 'expand', 'fold'];
      case BlockType.image:
        return ['image', 'picture', 'photo', 'img'];
      case BlockType.video:
        return ['video', 'movie', 'clip'];
      case BlockType.file:
        return ['file', 'attachment', 'document'];
      case BlockType.embed:
        return ['embed', 'link', 'url'];
      case BlockType.table:
        return ['table', 'grid', 'spreadsheet'];
      case BlockType.database:
        return ['database', 'data', 'collection'];
      case BlockType.bookmark:
        return ['bookmark', 'link', 'save'];
      case BlockType.equation:
        return ['equation', 'math', 'formula'];
      case BlockType.column:
        return ['column', 'layout'];
      case BlockType.columnList:
        return ['columns', 'layout', 'grid'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Buscar bloques...',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      onSubmitted: (_) => _selectCurrentBlock(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: widget.onDismiss,
                  ),
                ],
              ),
            ),
            
            // Block Types List
            if (_filteredTypes.isEmpty)
              _buildEmptyState()
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredTypes.length,
                  itemBuilder: (context, index) {
                    final type = _filteredTypes[index];
                    final isSelected = index == _selectedIndex;
                    
                    return _buildBlockTypeItem(type, isSelected, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockTypeItem(BlockType type, bool isSelected, int index) {
    return InkWell(
      onTap: () => _selectBlockType(type),
      onHover: (hovering) {
        if (hovering) {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5)
            : null,
        child: Row(
          children: [
            // Block Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  type.icon,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Block Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.displayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  if (_getBlockDescription(type) != null)
                    Text(
                      _getBlockDescription(type)!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            
            // Keyboard Shortcut
            if (_getKeyboardShortcut(type) != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getKeyboardShortcut(type)!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron bloques',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  String? _getBlockDescription(BlockType type) {
    switch (type) {
      case BlockType.paragraph:
        return 'Texto básico';
      case BlockType.heading1:
        return 'Encabezado grande';
      case BlockType.heading2:
        return 'Encabezado mediano';
      case BlockType.heading3:
        return 'Encabezado pequeño';
      case BlockType.bulletedList:
        return 'Lista con viñetas';
      case BlockType.numberedList:
        return 'Lista numerada';
      case BlockType.todo:
        return 'Lista de tareas';
      case BlockType.quote:
        return 'Cita o blockquote';
      case BlockType.code:
        return 'Bloque de código';
      case BlockType.divider:
        return 'Línea divisoria';
      case BlockType.callout:
        return 'Nota destacada';
      case BlockType.image:
        return 'Subir o insertar imagen';
      default:
        return null;
    }
  }

  String? _getKeyboardShortcut(BlockType type) {
    switch (type) {
      case BlockType.heading1:
        return '# ';
      case BlockType.heading2:
        return '## ';
      case BlockType.heading3:
        return '### ';
      case BlockType.bulletedList:
        return '- ';
      case BlockType.numberedList:
        return '1. ';
      case BlockType.todo:
        return '[] ';
      case BlockType.quote:
        return '> ';
      case BlockType.code:
        return '``` ';
      default:
        return null;
    }
  }

  void _selectCurrentBlock() {
    if (_filteredTypes.isNotEmpty) {
      _selectBlockType(_filteredTypes[_selectedIndex]);
    }
  }

  void _selectBlockType(BlockType type) {
    widget.onBlockTypeSelected(type);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}