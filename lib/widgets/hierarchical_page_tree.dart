import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page.dart';
import '../widgets/breadcrumb_navigation.dart';

class HierarchicalPageTree extends ConsumerStatefulWidget {
  final List<NotionPage> pages;
  final String? selectedPageId;
  final Function(NotionPage) onPageSelected;
  final Function(NotionPage) onPageReorder;
  final Function(String?, int) onCreateSubPage;
  final Function(NotionPage) onDeletePage;
  final bool isReadOnly;

  const HierarchicalPageTree({
    super.key,
    required this.pages,
    this.selectedPageId,
    required this.onPageSelected,
    required this.onPageReorder,
    required this.onCreateSubPage,
    required this.onDeletePage,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<HierarchicalPageTree> createState() => _HierarchicalPageTreeState();
}

class _HierarchicalPageTreeState extends ConsumerState<HierarchicalPageTree> {
  final Set<String> _expandedPages = <String>{};
  
  @override
  void initState() {
    super.initState();
    _expandSelectedPagePath();
  }

  @override
  void didUpdateWidget(HierarchicalPageTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPageId != widget.selectedPageId) {
      _expandSelectedPagePath();
    }
  }

  void _expandSelectedPagePath() {
    if (widget.selectedPageId == null) return;
    
    final selectedPage = widget.pages.firstWhere(
      (page) => page.id == widget.selectedPageId,
      orElse: () => widget.pages.first,
    );
    
    final breadcrumb = BreadcrumbBuilder.buildBreadcrumb(selectedPage, widget.pages);
    for (final page in breadcrumb) {
      if (page.parentId != null) {
        _expandedPages.add(page.parentId!);
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final rootNodes = BreadcrumbBuilder.buildPageTree(widget.pages);
    
    return ListView.builder(
      itemCount: rootNodes.length,
      itemBuilder: (context, index) {
        return _buildPageNode(rootNodes[index], 0);
      },
    );
  }

  Widget _buildPageNode(PageNode node, int depth) {
    final isSelected = node.page.id == widget.selectedPageId;
    final isExpanded = _expandedPages.contains(node.page.id);
    final hasChildren = node.hasChildren;
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Page item
        Container(
          margin: EdgeInsets.only(left: depth * 20.0),
          decoration: BoxDecoration(
            color: isSelected 
              ? theme.colorScheme.primaryContainer.withAlpha(100)
              : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expand/collapse button
                if (hasChildren)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      onPressed: () => _toggleExpansion(node.page.id),
                      icon: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.chevron_right),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 24),
                
                // Page icon
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Text(
                      node.page.icon ?? '📄',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              node.page.title.isEmpty ? 'Página sin título' : node.page.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected 
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: !widget.isReadOnly ? _buildPageActions(node.page) : null,
            onTap: () => widget.onPageSelected(node.page),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        
        // Child pages
        if (hasChildren && isExpanded)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: node.children
                  .map((childNode) => _buildPageNode(childNode, depth + 1))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPageActions(NotionPage page) {
    return PopupMenuButton<String>(
      iconSize: 16,
      padding: EdgeInsets.zero,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'add_subpage',
          child: Row(
            children: [
              Icon(Icons.add, size: 16),
              SizedBox(width: 8),
              Text('Agregar subpágina'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit, size: 16),
              SizedBox(width: 8),
              Text('Renombrar'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'move',
          child: Row(
            children: [
              Icon(Icons.drive_file_move, size: 16),
              SizedBox(width: 8),
              Text('Mover'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 16, color: Colors.red),
              SizedBox(width: 8),
              Text('Eliminar', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (value) => _handlePageAction(page, value),
    );
  }

  void _toggleExpansion(String pageId) {
    setState(() {
      if (_expandedPages.contains(pageId)) {
        _expandedPages.remove(pageId);
      } else {
        _expandedPages.add(pageId);
      }
    });
  }

  void _handlePageAction(NotionPage page, String action) {
    switch (action) {
      case 'add_subpage':
        _showCreateSubPageDialog(page);
        break;
      case 'rename':
        _showRenamePageDialog(page);
        break;
      case 'move':
        _showMovePageDialog(page);
        break;
      case 'delete':
        _showDeletePageDialog(page);
        break;
    }
  }

  void _showCreateSubPageDialog(NotionPage parentPage) {
    showDialog(
      context: context,
      builder: (context) => _CreateSubPageDialog(
        parentPage: parentPage,
        onCreateSubPage: (title, icon) {
          // Find the next position for the subpage
          final siblings = BreadcrumbBuilder.getChildPages(parentPage.id, widget.pages);
          final nextPosition = siblings.length;
          
          widget.onCreateSubPage(parentPage.id, nextPosition);
        },
      ),
    );
  }

  void _showRenamePageDialog(NotionPage page) {
    final titleController = TextEditingController(text: page.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar página'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Nuevo título',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement rename functionality
            },
            child: const Text('Renombrar'),
          ),
        ],
      ),
    );
  }

  void _showMovePageDialog(NotionPage page) {
    showDialog(
      context: context,
      builder: (context) => _MovePageDialog(
        page: page,
        allPages: widget.pages,
        onMovePage: widget.onPageReorder,
      ),
    );
  }

  void _showDeletePageDialog(NotionPage page) {
    final childPages = BreadcrumbBuilder.getChildPages(page.id, widget.pages);
    final hasChildren = childPages.isNotEmpty;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar página'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('¿Estás seguro de que quieres eliminar "${page.title}"?'),
            if (hasChildren) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        const Text('Advertencia', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Esta página tiene ${childPages.length} subpágina${childPages.length == 1 ? '' : 's'} que también se eliminará${childPages.length == 1 ? '' : 'n'}.'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeletePage(page);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _CreateSubPageDialog extends StatefulWidget {
  final NotionPage parentPage;
  final Function(String title, String icon) onCreateSubPage;

  const _CreateSubPageDialog({
    required this.parentPage,
    required this.onCreateSubPage,
  });

  @override
  State<_CreateSubPageDialog> createState() => _CreateSubPageDialogState();
}

class _CreateSubPageDialogState extends State<_CreateSubPageDialog> {
  final _titleController = TextEditingController();
  String _selectedIcon = '📄';

  final List<String> _iconOptions = [
    '📄', '📝', '📚', '📖', '📋', '📊', '📈', '📉', '🔍', '💡',
    '⚡', '🎯', '🎨', '🔧', '⚙️', '🏠', '🏢', '🎓', '💻', '📱'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear subpágina en "${widget.parentPage.title}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Título de la subpágina',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          
          // Icon selection
          const Text('Icono:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            height: 60,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: _iconOptions.length,
              itemBuilder: (context, index) {
                final icon = _iconOptions[index];
                final isSelected = icon == _selectedIcon;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withAlpha(100) : null,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.withAlpha(100),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _titleController.text.isNotEmpty
            ? () {
                Navigator.pop(context);
                widget.onCreateSubPage(_titleController.text, _selectedIcon);
              }
            : null,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}

class _MovePageDialog extends StatefulWidget {
  final NotionPage page;
  final List<NotionPage> allPages;
  final Function(NotionPage) onMovePage;

  const _MovePageDialog({
    required this.page,
    required this.allPages,
    required this.onMovePage,
  });

  @override
  State<_MovePageDialog> createState() => _MovePageDialogState();
}

class _MovePageDialogState extends State<_MovePageDialog> {
  String? _selectedParentId;

  @override
  void initState() {
    super.initState();
    _selectedParentId = widget.page.parentId;
  }

  @override
  Widget build(BuildContext context) {
    final availableParents = widget.allPages
        .where((page) => page.id != widget.page.id)
        .where((page) => !BreadcrumbBuilder.isChildOf(page, widget.page, widget.allPages))
        .toList();

    return AlertDialog(
      title: Text('Mover "${widget.page.title}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecciona el nuevo padre:'),
          const SizedBox(height: 12),
          
          // Root option
          RadioListTile<String?>(
            title: const Text('📁 Nivel raíz'),
            value: null,
            groupValue: _selectedParentId,
            onChanged: (value) => setState(() => _selectedParentId = value),
          ),
          
          // Parent options
          ...availableParents.map((page) {
            return RadioListTile<String>(
              title: Row(
                children: [
                  Text(page.icon ?? '📄', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      page.title.isEmpty ? 'Página sin título' : page.title,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              value: page.id,
              groupValue: _selectedParentId,
              onChanged: (value) => setState(() => _selectedParentId = value),
            );
          }),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // TODO: Implement move functionality
          },
          child: const Text('Mover'),
        ),
      ],
    );
  }
}