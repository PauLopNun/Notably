import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import '../widgets/workspace_sidebar.dart';
import '../widgets/notion_page_editor.dart';
import '../widgets/template_selector.dart';
import '../widgets/breadcrumb_navigation.dart';
import '../widgets/advanced_search.dart';
import '../widgets/favorites_recent_panel.dart';
import '../providers/workspace_provider.dart';
import '../providers/page_provider.dart';
import '../providers/template_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/export_service.dart';

class WorkspaceMainPage extends ConsumerStatefulWidget {
  const WorkspaceMainPage({super.key});

  @override
  ConsumerState<WorkspaceMainPage> createState() => _WorkspaceMainPageState();
}

class _WorkspaceMainPageState extends ConsumerState<WorkspaceMainPage> {
  String? _selectedWorkspaceId;
  String? _selectedPageId;
  bool _isSidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    _loadInitialWorkspace();
  }

  Future<void> _loadInitialWorkspace() async {
    // Load the first workspace and its first page
    final workspacesAsync = ref.read(userWorkspacesProvider);
    workspacesAsync.whenData((workspaces) {
      if (workspaces.isNotEmpty) {
        final firstWorkspace = workspaces.first;
        setState(() {
          _selectedWorkspaceId = firstWorkspace.id;
        });
        _loadFirstPageOfWorkspace(firstWorkspace.id);
      }
    });
  }

  Future<void> _loadFirstPageOfWorkspace(String workspaceId) async {
    final pagesAsync = ref.read(workspacePagesProvider(workspaceId));
    pagesAsync.whenData((pages) {
      if (pages.isNotEmpty) {
        setState(() {
          _selectedPageId = pages.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Row(
        children: [
          // Sidebar
          if (!_isSidebarCollapsed)
            WorkspaceSidebar(
              selectedWorkspaceId: _selectedWorkspaceId,
              selectedPageId: _selectedPageId,
              onWorkspaceSelected: _onWorkspaceSelected,
              onPageSelected: _onPageSelected,
              onCreatePage: _onCreatePage,
            ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),
                
                // Content
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Sidebar Toggle
          IconButton(
            onPressed: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
            icon: Icon(
              _isSidebarCollapsed ? Icons.menu_open : Icons.menu,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: _isSidebarCollapsed ? 'Mostrar sidebar' : 'Ocultar sidebar',
          ),
          
          // Breadcrumb
          Expanded(
            child: _buildBreadcrumb(),
          ),
          
          // Favorites and Recent Button
          IconButton(
            onPressed: _showFavoritesAndRecent,
            icon: const Icon(Icons.favorite),
            tooltip: 'Favoritas y Recientes',
          ),
          
          // Search Button
          IconButton(
            onPressed: _showAdvancedSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
          ),
          
          // Actions
          _buildTopActions(),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
    if (_selectedPageId == null || _selectedWorkspaceId == null) {
      return const SizedBox.shrink();
    }

    final pageAsync = ref.watch(pageProvider(_selectedPageId!));
    final pagesAsync = ref.watch(workspacePagesProvider(_selectedWorkspaceId!));
    
    return pageAsync.when(
      data: (currentPage) => pagesAsync.when(
        data: (allPages) {
          final breadcrumbPages = BreadcrumbBuilder.buildBreadcrumb(currentPage, allPages);
          
          return BreadcrumbNavigation(
            breadcrumbPages: breadcrumbPages,
            currentPage: currentPage,
            onPageTap: (page) => _onPageSelected(page.id),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }


  Widget _buildTopActions() {
    return Row(
      children: [
        // Share Button
        if (_selectedPageId != null)
          IconButton(
            onPressed: _showShareDialog,
            icon: const Icon(Icons.share),
            tooltip: 'Compartir página',
          ),
        
        // More Actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download, size: 16),
                  SizedBox(width: 8),
                  Text('Exportar'),
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
          onSelected: _handleTopAction,
        ),
        
        // User Avatar
        const SizedBox(width: 8),
        _buildUserAvatar(),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.person,
        size: 18,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedPageId == null) {
      return _buildWelcomeScreen();
    }

    final pageAsync = ref.watch(pageProvider(_selectedPageId!));
    
    return pageAsync.when(
      data: (page) => NotionPageEditor(
        page: page,
        key: ValueKey(page.id), // Force rebuild when page changes
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar la página',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            '¡Bienvenido a Notably!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tu espacio de trabajo colaborativo para\norganizar notas por asignaturas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 32),
          
          // Quick Actions
          Wrap(
            spacing: 16,
            children: [
              ElevatedButton.icon(
                onPressed: () => _showCreateWorkspaceDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Crear Workspace'),
              ),
              OutlinedButton.icon(
                onPressed: _showTemplatesDialog,
                icon: const Icon(Icons.add_box_rounded),
                label: const Text('Ver Templates'),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // Feature Highlights
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildFeatureHighlight(
                  Icons.people,
                  'Colaboración en Tiempo Real',
                  'Trabaja con compañeros de clase en tiempo real',
                ),
                const SizedBox(height: 16),
                _buildFeatureHighlight(
                  Icons.auto_awesome,
                  'Templates Académicos',
                  'Plantillas listas para diferentes asignaturas',
                ),
                const SizedBox(height: 16),
                _buildFeatureHighlight(
                  Icons.folder_copy,
                  'Organización por Workspaces',
                  'Mantén tus notas organizadas por materias',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlight(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onWorkspaceSelected(String workspaceId) {
    setState(() {
      _selectedWorkspaceId = workspaceId;
      _selectedPageId = null; // Reset page selection
    });
    _loadFirstPageOfWorkspace(workspaceId);
  }

  void _onPageSelected(String pageId) {
    setState(() {
      _selectedPageId = pageId;
    });
    
    // Add to recent pages when a page is selected
    final pageAsync = ref.read(pageProvider(pageId));
    pageAsync.whenData((page) {
      ref.read(recentPagesProvider.notifier).addRecentPage(page);
    });
  }

  void _onCreatePage(String workspaceId) {
    _showCreatePageDialog(workspaceId);
  }

  void _handleTopAction(String action) {
    switch (action) {
      case 'export':
        _showExportDialog();
        break;
      case 'templates':
        _showTemplatesDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showShareDialog() {
    // Implement share dialog
  }

  void _showCreateWorkspaceDialog() {
    // This would be handled by the sidebar
  }

  void _showCreatePageDialog(String workspaceId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreatePageBottomSheet(workspaceId: workspaceId),
    );
  }

  void _showTemplatesDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplatesDialog(),
    );
  }

  void _showExportDialog() {
    if (_selectedPageId == null) return;
    
    showDialog(
      context: context,
      builder: (context) => _ExportDialog(pageId: _selectedPageId!),
    );
  }

  void _showSettingsDialog() {
    // Implement settings dialog
  }

  void _showAdvancedSearch() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AdvancedSearch(
        workspaceId: _selectedWorkspaceId,
        onResultSelected: (result) {
          // Navigate to the selected page
          _onPageSelected(result.page.id);
          
          // If there's a specific block, we could scroll to it later
          if (result.blockId != null) {
            // TODO: Implement block navigation/highlighting
          }
        },
      ),
    );
  }

  void _showFavoritesAndRecent() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FavoritesRecentPanel(
        onPageSelected: (page) => _onPageSelected(page.id),
      ),
    );
  }
}

class _CreatePageBottomSheet extends ConsumerStatefulWidget {
  final String workspaceId;

  const _CreatePageBottomSheet({required this.workspaceId});

  @override
  ConsumerState<_CreatePageBottomSheet> createState() => _CreatePageBottomSheetState();
}

class _CreatePageBottomSheetState extends ConsumerState<_CreatePageBottomSheet> {
  bool _showTemplates = false;

  @override
  Widget build(BuildContext context) {
    if (_showTemplates) {
      return TemplateSelector(
        onTemplateSelected: _onTemplateSelected,
        onCancel: () => setState(() => _showTemplates = false),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Options
          Expanded(
            child: _buildOptions(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 28,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Nueva Página',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Elige cómo quieres empezar',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Create blank page
          _buildOptionCard(
            icon: Icons.description_outlined,
            title: 'Página en Blanco',
            description: 'Empieza con una página completamente vacía',
            color: theme.colorScheme.primary,
            onTap: () => _createBlankPage(),
          ),
          
          const SizedBox(height: 16),
          
          // Use template
          _buildOptionCard(
            icon: Icons.article_outlined,
            title: 'Usar Template',
            description: 'Crea una página basada en un template predefinido',
            color: theme.colorScheme.secondary,
            onTap: () => setState(() => _showTemplates = true),
          ),
          
          const SizedBox(height: 24),
          
          // Quick templates
          _buildQuickTemplates(),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTemplates() {
    final theme = Theme.of(context);
    final featuredTemplates = ref.read(featuredTemplatesProvider);
    
    if (featuredTemplates.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Templates Populares',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: featuredTemplates.map((template) => 
              _buildQuickTemplateCard(template)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTemplateCard(PageTemplate template) {
    final theme = Theme.of(context);
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _onTemplateSelected(template),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.icon ?? '📝',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  template.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createBlankPage() {
    _createPageFromTemplate(null);
  }

  void _onTemplateSelected(PageTemplate template) {
    _createPageFromTemplate(template);
  }

  void _createPageFromTemplate(PageTemplate? template) async {
    if (template != null) {
      // Apply template
      final templateNotifier = ref.read(templateApplicationProvider.notifier);
      await templateNotifier.applyTemplate(
        template: template,
        workspaceId: widget.workspaceId,
      );
      
      // Listen to application state
      ref.listen(templateApplicationProvider, (previous, next) {
        switch (next.runtimeType.toString()) {
          case '_Success':
            Navigator.pop(context);
            // Navigate to the new page or refresh the workspace
            break;
          case '_Error':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error applying template')),
            );
            break;
        }
      });
    } else {
      // Create blank page
      try {
        final workspaceNotifier = ref.read(workspacePagesNotifierProvider(widget.workspaceId).notifier);
        await workspaceNotifier.createPage(
          title: 'Página sin título',
          icon: '📄',
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear página: $e')),
        );
      }
    }
  }
}

class _TemplatesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final templates = SubjectTemplates.getAcademicTemplates();

    return AlertDialog(
      title: const Text('Templates Académicos'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return Card(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  // Create page with template
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        template.icon ?? '📄',
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          template.description ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

class _ExportDialog extends ConsumerStatefulWidget {
  final String pageId;

  const _ExportDialog({required this.pageId});

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  PdfTheme _selectedPdfTheme = PdfTheme.professional;
  HtmlTheme _selectedHtmlTheme = HtmlTheme.clean;
  bool _includeMetadata = true;
  bool _includeImages = true;
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    final pageAsync = ref.watch(pageProvider(widget.pageId));

    return AlertDialog(
      title: const Text('Exportar Página'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            pageAsync.when(
              data: (page) => Row(
                children: [
                  Text(page.icon ?? '📄', style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      page.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 20),
            
            // Format Selection
            Text('Formato:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<ExportFormat>(
              initialValue: _selectedFormat,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ExportFormat.values.map((format) {
                final formatInfo = _getFormatInfo(format);
                return DropdownMenuItem(
                  value: format,
                  child: Row(
                    children: [
                      Icon(formatInfo['icon'], size: 16),
                      const SizedBox(width: 8),
                      Text(formatInfo['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (format) {
                setState(() {
                  _selectedFormat = format!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Format-specific options
            if (_selectedFormat == ExportFormat.pdf) ...[
              Text('Tema PDF:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<PdfTheme>(
                initialValue: _selectedPdfTheme,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: PdfTheme.values.map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(_getPdfThemeName(theme)),
                  );
                }).toList(),
                onChanged: (theme) {
                  setState(() {
                    _selectedPdfTheme = theme!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ] else if (_selectedFormat == ExportFormat.html) ...[
              Text('Tema HTML:', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              DropdownButtonFormField<HtmlTheme>(
                initialValue: _selectedHtmlTheme,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: HtmlTheme.values.map((theme) {
                  return DropdownMenuItem(
                    value: theme,
                    child: Text(_getHtmlThemeName(theme)),
                  );
                }).toList(),
                onChanged: (theme) {
                  setState(() {
                    _selectedHtmlTheme = theme!;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],
            
            // Options
            CheckboxListTile(
              title: const Text('Incluir metadatos'),
              value: _includeMetadata,
              onChanged: (value) {
                setState(() {
                  _includeMetadata = value ?? true;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
            CheckboxListTile(
              title: const Text('Incluir imágenes'),
              value: _includeImages,
              onChanged: (value) {
                setState(() {
                  _includeImages = value ?? true;
                });
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _isExporting ? null : _exportPage,
          icon: _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download, size: 16),
          label: Text(_isExporting ? 'Exportando...' : 'Exportar'),
        ),
      ],
    );
  }

  Map<String, dynamic> _getFormatInfo(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return {'name': 'PDF', 'icon': Icons.picture_as_pdf};
      case ExportFormat.markdown:
        return {'name': 'Markdown', 'icon': Icons.text_snippet};
      case ExportFormat.html:
        return {'name': 'HTML', 'icon': Icons.web};
      case ExportFormat.plainText:
        return {'name': 'Texto Plano', 'icon': Icons.text_fields};
      case ExportFormat.json:
        return {'name': 'JSON', 'icon': Icons.data_object};
    }
  }

  String _getPdfThemeName(PdfTheme theme) {
    switch (theme) {
      case PdfTheme.professional:
        return 'Profesional';
      case PdfTheme.academic:
        return 'Académico';
      case PdfTheme.minimal:
        return 'Minimalista';
      case PdfTheme.creative:
        return 'Creativo';
    }
  }

  String _getHtmlThemeName(HtmlTheme theme) {
    switch (theme) {
      case HtmlTheme.clean:
        return 'Limpio';
      case HtmlTheme.modern:
        return 'Moderno';
      case HtmlTheme.classic:
        return 'Clásico';
    }
  }

  Future<void> _exportPage() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final pageAsync = ref.read(pageProvider(widget.pageId));
      final page = pageAsync.value;

      final exportService = ref.read(exportServiceProvider);
      
      final options = ExportOptions(
        format: _selectedFormat,
        pdfTheme: _selectedPdfTheme == PdfTheme.academic ? PdfThemeData.academic() : null,
        htmlTheme: _selectedHtmlTheme == HtmlTheme.clean ? HtmlThemeData.clean() : null,
        includeMetadata: _includeMetadata,
        includeImages: _includeImages,
      );

      final result = await exportService.exportPage(page!, options);
      
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Página exportada como ${_getFormatInfo(_selectedFormat)['name']}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Compartir',
              onPressed: () => exportService.shareFile(result),
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al exportar: ${error.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}