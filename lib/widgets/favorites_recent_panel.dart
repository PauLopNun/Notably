import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page.dart';
import '../providers/favorites_provider.dart';

enum PanelView {
  favorites,
  recent,
}

class FavoritesRecentPanel extends ConsumerStatefulWidget {
  final Function(NotionPage)? onPageSelected;
  final VoidCallback? onClose;

  const FavoritesRecentPanel({
    super.key,
    this.onPageSelected,
    this.onClose,
  });

  @override
  ConsumerState<FavoritesRecentPanel> createState() => _FavoritesRecentPanelState();
}

class _FavoritesRecentPanelState extends ConsumerState<FavoritesRecentPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PanelView _currentView = PanelView.favorites;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentView = _tabController.index == 0 ? PanelView.favorites : PanelView.recent;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: 500,
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 500,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesView(),
                  _buildRecentView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Icon(
            _currentView == PanelView.favorites ? Icons.favorite : Icons.history,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentView == PanelView.favorites ? 'Páginas Favoritas' : 'Páginas Recientes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  _currentView == PanelView.favorites 
                    ? 'Tus páginas marcadas como favoritas'
                    : 'Páginas que has visitado recientemente',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(100),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorColor: Theme.of(context).colorScheme.primary,
        tabs: const [
          Tab(
            icon: Icon(Icons.favorite_outline),
            text: 'Favoritas',
          ),
          Tab(
            icon: Icon(Icons.history),
            text: 'Recientes',
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesView() {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) {
          return _buildEmptyFavorites();
        }
        return _buildPagesList(favorites, showFavoriteButton: true);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Error al cargar favoritas: $error'),
    );
  }

  Widget _buildRecentView() {
    final recentAsync = ref.watch(recentPagesProvider);

    return recentAsync.when(
      data: (recent) {
        if (recent.isEmpty) {
          return _buildEmptyRecent();
        }
        return Column(
          children: [
            // Clear recent button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    '${recent.length} página${recent.length == 1 ? '' : 's'} reciente${recent.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _clearRecentPages,
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Limpiar historial'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildPagesList(recent, showRemoveButton: true),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState('Error al cargar recientes: $error'),
    );
  }

  Widget _buildPagesList(List<NotionPage> pages, {
    bool showFavoriteButton = false,
    bool showRemoveButton = false,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final page = pages[index];
        return _buildPageItem(
          page,
          showFavoriteButton: showFavoriteButton,
          showRemoveButton: showRemoveButton,
        );
      },
    );
  }

  Widget _buildPageItem(NotionPage page, {
    bool showFavoriteButton = false,
    bool showRemoveButton = false,
  }) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(page.id));
    
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            page.icon ?? '📄',
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Text(
        page.title.isEmpty ? 'Página sin título' : page.title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Modificado ${_formatDate(page.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          if (page.blocks.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${page.blocks.length} bloque${page.blocks.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFavoriteButton)
            IconButton(
              onPressed: () => _toggleFavorite(page),
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : theme.colorScheme.outline,
                size: 20,
              ),
              tooltip: isFavorite ? 'Quitar de favoritas' : 'Agregar a favoritas',
            ),
          if (showRemoveButton)
            IconButton(
              onPressed: () => _removeFromRecent(page.id),
              icon: Icon(
                Icons.remove_circle_outline,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              tooltip: 'Quitar del historial',
            ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: 20,
              color: theme.colorScheme.outline,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.open_in_new, size: 16, color: theme.colorScheme.onSurface),
                    const SizedBox(width: 8),
                    const Text('Abrir página'),
                  ],
                ),
              ),
              if (!showFavoriteButton)
                PopupMenuItem(
                  value: 'favorite',
                  child: Row(
                    children: [
                      Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isFavorite ? Colors.red : theme.colorScheme.onSurface,
                      ),
                      const SizedBox(width: 8),
                      Text(isFavorite ? 'Quitar de favoritas' : 'Agregar a favoritas'),
                    ],
                  ),
                ),
            ],
            onSelected: (value) => _handlePageAction(page, value),
          ),
        ],
      ),
      onTap: () => _selectPage(page),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: theme.colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin páginas favoritas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Marca páginas como favoritas para\nacceso rápido desde cualquier lugar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              // Switch to recent tab
              _tabController.animateTo(1);
            },
            icon: const Icon(Icons.history),
            label: const Text('Ver páginas recientes'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin páginas recientes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las páginas que visites aparecerán aquí\npara acceso rápido',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
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
            'Error',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              if (_currentView == PanelView.favorites) {
                ref.read(favoritesProvider.notifier).refresh();
              } else {
                ref.read(recentPagesProvider.notifier).refresh();
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _selectPage(NotionPage page) {
    // Add to recent pages when selected
    ref.read(recentPagesProvider.notifier).addRecentPage(page);
    
    widget.onPageSelected?.call(page);
    Navigator.pop(context);
  }

  void _toggleFavorite(NotionPage page) {
    ref.read(favoritesProvider.notifier).toggleFavorite(page);
  }

  void _removeFromRecent(String pageId) {
    ref.read(recentPagesProvider.notifier).removeRecentPage(pageId);
  }

  void _clearRecentPages() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Estás seguro de que quieres eliminar todas las páginas recientes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(recentPagesProvider.notifier).clearRecentPages();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _handlePageAction(NotionPage page, String action) {
    switch (action) {
      case 'open':
        _selectPage(page);
        break;
      case 'favorite':
        _toggleFavorite(page);
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'hoy';
    } else if (difference.inDays == 1) {
      return 'ayer';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return 'hace ${(difference.inDays / 7).round()} semana${(difference.inDays / 7).round() == 1 ? '' : 's'}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Floating Action Button for quick access
class FavoritesRecentFAB extends ConsumerWidget {
  final Function(NotionPage)? onPageSelected;

  const FavoritesRecentFAB({
    super.key,
    this.onPageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showPanel(context),
      tooltip: 'Favoritas y Recientes',
      child: const Icon(Icons.favorite),
    );
  }

  void _showPanel(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => FavoritesRecentPanel(
        onPageSelected: onPageSelected,
      ),
    );
  }
}