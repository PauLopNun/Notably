import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import '../models/page.dart';
import '../models/template.dart';
import '../providers/workspace_provider.dart';
import '../providers/page_provider.dart';
import 'hierarchical_page_tree.dart';

class WorkspaceSidebar extends ConsumerStatefulWidget {
  final String? selectedWorkspaceId;
  final String? selectedPageId;
  final Function(String)? onWorkspaceSelected;
  final Function(String)? onPageSelected;
  final Function(String)? onCreatePage;

  const WorkspaceSidebar({
    super.key,
    this.selectedWorkspaceId,
    this.selectedPageId,
    this.onWorkspaceSelected,
    this.onPageSelected,
    this.onCreatePage,
  });

  @override
  ConsumerState<WorkspaceSidebar> createState() => _WorkspaceSidebarState();
}

class _WorkspaceSidebarState extends ConsumerState<WorkspaceSidebar> {
  final Map<String, bool> _expandedWorkspaces = {};

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(userWorkspacesProvider);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Workspaces List
          Expanded(
            child: workspacesAsync.when(
              data: (workspaces) => _buildWorkspacesList(workspaces),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
          
          // Footer Actions
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.school,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mis Espacios de Trabajo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: _showCreateWorkspaceDialog,
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Crear workspace',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspacesList(List<Workspace> workspaces) {
    if (workspaces.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: workspaces.length,
      itemBuilder: (context, index) {
        final workspace = workspaces[index];
        final isExpanded = _expandedWorkspaces[workspace.id] ?? true;
        final isSelected = workspace.id == widget.selectedWorkspaceId;

        return _buildWorkspaceItem(workspace, isExpanded, isSelected);
      },
    );
  }

  Widget _buildWorkspaceItem(Workspace workspace, bool isExpanded, bool isSelected) {
    return Column(
      children: [
        // Workspace Header
        InkWell(
          onTap: () {
            setState(() {
              _expandedWorkspaces[workspace.id] = !isExpanded;
            });
            widget.onWorkspaceSelected?.call(workspace.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: isSelected ? BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ) : null,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                // Expand/Collapse Icon
                Icon(
                  isExpanded ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                
                // Workspace Icon
                Text(
                  workspace.icon,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                
                // Workspace Name
                Expanded(
                  child: Text(
                    workspace.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // More Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'new_page',
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 8),
                          Text('Nueva página'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'templates',
                      child: Row(
                        children: [
                          Icon(Icons.add_box_rounded, size: 16),
                          SizedBox(width: 8),
                          Text('Templates'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 16),
                          SizedBox(width: 8),
                          Text('Configuración'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleWorkspaceAction(workspace.id, value),
                ),
              ],
            ),
          ),
        ),
        
        // Pages List
        if (isExpanded)
          _buildPagesList(workspace.id),
      ],
    );
  }

  Widget _buildPagesList(String workspaceId) {
    final pagesAsync = ref.watch(workspacePagesProvider(workspaceId));
    
    return pagesAsync.when(
      data: (pages) {
        if (pages.isEmpty) {
          return _buildEmptyPagesState(workspaceId);
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: HierarchicalPageTree(
            pages: pages,
            selectedPageId: widget.selectedPageId,
            onPageSelected: (page) => widget.onPageSelected?.call(page.id),
            onPageReorder: (page) {
              // TODO: Implement page reorder functionality
            },
            onCreateSubPage: (parentId, position) {
              // TODO: Implement create subpage functionality
              widget.onCreatePage?.call(workspaceId);
            },
            onDeletePage: (page) {
              // TODO: Implement delete page functionality
            },
            isReadOnly: false,
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Error al cargar páginas',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }


  Widget _buildEmptyPagesState(String workspaceId) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            Icons.note_add,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'Sin páginas',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => widget.onCreatePage?.call(workspaceId),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Crear página'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              textStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin espacios de trabajo',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer workspace\npara empezar a organizar\ntus notas por asignaturas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateWorkspaceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear Workspace'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton.icon(
              onPressed: _showTemplatesDialog,
              icon: const Icon(Icons.add_box_rounded, size: 16),
              label: const Text('Templates'),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Show settings
            },
            icon: const Icon(Icons.settings, size: 18),
            tooltip: 'Configuración',
          ),
        ],
      ),
    );
  }

  void _handleWorkspaceAction(String workspaceId, String action) {
    switch (action) {
      case 'new_page':
        widget.onCreatePage?.call(workspaceId);
        break;
      case 'templates':
        _showTemplatesDialog();
        break;
      case 'settings':
        _showWorkspaceSettings(workspaceId);
        break;
    }
  }

  void _showCreateWorkspaceDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateWorkspaceDialog(),
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplatesDialog(
        onTemplateSelected: (template) {
          // Create page from template
          if (widget.selectedWorkspaceId != null) {
            widget.onCreatePage?.call(widget.selectedWorkspaceId!);
          }
        },
      ),
    );
  }

  void _showWorkspaceSettings(String workspaceId) {
    // Show workspace settings dialog
  }
}

class _CreateWorkspaceDialog extends StatefulWidget {
  @override
  State<_CreateWorkspaceDialog> createState() => _CreateWorkspaceDialogState();
}

class _CreateWorkspaceDialogState extends State<_CreateWorkspaceDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = '📚';
  
  final List<String> _icons = [
    '📚', '🎓', '💼', '🔬', '🎨', '🏛️', '💻', '📊', 
    '🌟', '🚀', '💡', '🎯', '📝', '🔥', '⭐', '🌈'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear Nuevo Workspace'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Selection
          Text('Icono:', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _icons.map((icon) => GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedIcon == icon
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          
          // Name Field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del workspace',
              hintText: 'ej. Matemáticas 2024',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          // Description Field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción (opcional)',
              hintText: 'Describe el propósito de este workspace',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.isNotEmpty ? _createWorkspace : null,
          child: const Text('Crear'),
        ),
      ],
    );
  }

  void _createWorkspace() {
    // Create workspace logic would go here
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _TemplatesDialog extends StatelessWidget {
  final Function(PageTemplate) onTemplateSelected;

  const _TemplatesDialog({
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final templates = SubjectTemplates.getAcademicTemplates();

    return AlertDialog(
      title: const Text('Templates'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return ListTile(
              leading: Text(template.icon ?? '📄', style: const TextStyle(fontSize: 24)),
              title: Text(template.name),
              subtitle: Text(template.description ?? ''),
              onTap: () {
                Navigator.pop(context);
                onTemplateSelected(template);
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}