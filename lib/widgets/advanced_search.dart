import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../providers/workspace_provider.dart';
import '../providers/page_provider.dart';

enum SearchScope {
  currentWorkspace,
  allWorkspaces,
  specificPages,
}

enum SearchType {
  content,
  titles,
  both,
}

enum SortOrder {
  relevance,
  modified,
  created,
  title,
}

class SearchResult {
  final NotionPage page;
  final String? blockId;
  final String matchedText;
  final String contextSnippet;
  final double relevanceScore;

  const SearchResult({
    required this.page,
    this.blockId,
    required this.matchedText,
    required this.contextSnippet,
    required this.relevanceScore,
  });
}

class AdvancedSearch extends ConsumerStatefulWidget {
  final String? initialQuery;
  final String? workspaceId;
  final Function(SearchResult)? onResultSelected;
  final VoidCallback? onClose;

  const AdvancedSearch({
    super.key,
    this.initialQuery,
    this.workspaceId,
    this.onResultSelected,
    this.onClose,
  });

  @override
  ConsumerState<AdvancedSearch> createState() => _AdvancedSearchState();
}

class _AdvancedSearchState extends ConsumerState<AdvancedSearch> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  SearchScope _selectedScope = SearchScope.currentWorkspace;
  SearchType _selectedType = SearchType.both;
  SortOrder _selectedSort = SortOrder.relevance;
  
  List<SearchResult> _results = [];
  bool _isSearching = false;
  bool _showFilters = false;
  
  // Filter states
  bool _caseSensitive = false;
  bool _wholeWords = false;
  bool _useRegex = false;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  List<String> _selectedTags = [];
  List<String> _selectedAuthors = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
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
            _buildSearchBar(),
            if (_showFilters) _buildFilters(),
            Expanded(child: _buildResults()),
            _buildFooter(),
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
            Icons.search,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Búsqueda Avanzada',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Busca contenido en todas tus páginas y bloques',
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Main search input
          TextField(
            controller: _searchController,
            focusNode: _searchFocus,
            decoration: InputDecoration(
              hintText: 'Buscar en páginas y contenido...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _results.clear();
                        });
                      },
                      icon: const Icon(Icons.clear, size: 20),
                    ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_list : Icons.tune,
                      color: _showFilters 
                        ? Theme.of(context).colorScheme.primary 
                        : null,
                    ),
                    tooltip: 'Filtros avanzados',
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
            textInputAction: TextInputAction.search,
          ),
          
          const SizedBox(height: 16),
          
          // Quick filter buttons
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Row(
      children: [
        // Search scope
        _buildFilterChip(
          'En workspace actual',
          _selectedScope == SearchScope.currentWorkspace,
          () => setState(() => _selectedScope = SearchScope.currentWorkspace),
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          'En todos los workspaces',
          _selectedScope == SearchScope.allWorkspaces,
          () => setState(() => _selectedScope = SearchScope.allWorkspaces),
        ),
        const SizedBox(width: 16),
        
        // Search type
        _buildFilterChip(
          'Solo títulos',
          _selectedType == SearchType.titles,
          () => setState(() => _selectedType = SearchType.titles),
        ),
        const SizedBox(width: 8),
        _buildFilterChip(
          'Todo el contenido',
          _selectedType == SearchType.both,
          () => setState(() => _selectedType = SearchType.both),
        ),
        
        const Spacer(),
        
        // Sort order
        DropdownButtonHideUnderline(
          child: DropdownButton<SortOrder>(
            value: _selectedSort,
            icon: const Icon(Icons.sort, size: 16),
            items: SortOrder.values.map((order) {
              return DropdownMenuItem(
                value: order,
                child: Text(_getSortOrderName(order)),
              );
            }).toList(),
            onChanged: (order) {
              if (order != null) {
                setState(() => _selectedSort = order);
                if (_results.isNotEmpty) {
                  _sortResults();
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros Avanzados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Options row
          Wrap(
            spacing: 16,
            children: [
              _buildCheckboxOption(
                'Sensible a mayúsculas',
                _caseSensitive,
                (value) => setState(() => _caseSensitive = value),
              ),
              _buildCheckboxOption(
                'Palabras completas',
                _wholeWords,
                (value) => setState(() => _wholeWords = value),
              ),
              _buildCheckboxOption(
                'Expresiones regulares',
                _useRegex,
                (value) => setState(() => _useRegex = value),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date range
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Desde',
                  _dateFrom,
                  (date) => setState(() => _dateFrom = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'Hasta',
                  _dateTo,
                  (date) => setState(() => _dateTo = date),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: date != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => onChanged(null),
              )
            : const Icon(Icons.calendar_today, size: 16),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: Text(
          date != null
            ? '${date.day}/${date.month}/${date.year}'
            : 'Seleccionar fecha',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: date != null 
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando...'),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(
                '${_results.length} resultado${_results.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _performSearch,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Actualizar'),
              ),
            ],
          ),
        ),
        
        // Results list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            itemCount: _results.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildResultItem(_results[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildResultItem(SearchResult result) {
    final theme = Theme.of(context);
    
    return ListTile(
      contentPadding: const EdgeInsets.all(12),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            result.page.icon ?? '📄',
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              result.page.title.isEmpty ? 'Página sin título' : result.page.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (result.blockId != null) ...[
            Icon(
              Icons.article_outlined,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'En bloque',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              children: _buildHighlightedText(
                result.contextSnippet,
                result.matchedText,
              ),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 12,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(width: 4),
              Text(
                'Modificado ${_formatDate(result.page.updatedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withAlpha(100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${(result.relevanceScore * 100).round()}% relevancia',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        widget.onResultSelected?.call(result);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: theme.colorScheme.surfaceContainerHighest,
    );
  }

  List<TextSpan> _buildHighlightedText(String text, String query) {
    if (!text.toLowerCase().contains(query.toLowerCase())) {
      return [TextSpan(text: text)];
    }

    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      
      // Add highlighted match
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor: theme.colorScheme.secondary.withAlpha(100),
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ));
      
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    
    return spans;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Busca en tus páginas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe para buscar títulos, contenido de bloques\ny encontrar exactamente lo que necesitas',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Sin resultados',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No se encontraron páginas que coincidan\ncon "${_searchController.text}"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _caseSensitive = false;
                _wholeWords = false;
                _useRegex = false;
                _dateFrom = null;
                _dateTo = null;
                _selectedScope = SearchScope.currentWorkspace;
                _selectedType = SearchType.both;
              });
              _performSearch();
            },
            icon: const Icon(Icons.filter_alt_off),
            label: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer.withAlpha(50),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Text(
            'Consejos: Usa comillas para frases exactas, * para comodines',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            child: Text(_showFilters ? 'Ocultar filtros' : 'Mostrar filtros'),
          ),
        ],
      ),
    );
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Get pages based on scope
      List<NotionPage> searchPages = [];
      
      if (_selectedScope == SearchScope.currentWorkspace && widget.workspaceId != null) {
        final pagesAsync = ref.read(workspacePagesProvider(widget.workspaceId!));
        searchPages = pagesAsync.value ?? [];
      } else if (_selectedScope == SearchScope.allWorkspaces) {
        final workspacesAsync = ref.read(userWorkspacesProvider);
        final workspaces = workspacesAsync.value ?? [];
        
        for (final workspace in workspaces) {
          final pagesAsync = ref.read(workspacePagesProvider(workspace.id));
          searchPages.addAll(pagesAsync.value ?? []);
        }
      }

      // Perform search
      final results = await _searchInPages(searchPages, query);
      
      setState(() {
        _results = results;
        _isSearching = false;
      });
      
      _sortResults();
      
    } catch (error) {
      setState(() {
        _isSearching = false;
        _results.clear();
      });
    }
  }

  Future<List<SearchResult>> _searchInPages(List<NotionPage> pages, String query) async {
    final results = <SearchResult>[];
    
    for (final page in pages) {
      // Apply date filters
      if (_dateFrom != null && page.createdAt.isBefore(_dateFrom!)) continue;
      if (_dateTo != null && page.createdAt.isAfter(_dateTo!.add(const Duration(days: 1)))) continue;
      
      // Search in title
      if (_selectedType == SearchType.titles || _selectedType == SearchType.both) {
        if (_matchesQuery(page.title, query)) {
          results.add(SearchResult(
            page: page,
            matchedText: query,
            contextSnippet: page.title,
            relevanceScore: _calculateTitleRelevance(page.title, query),
          ));
        }
      }
      
      // Search in content blocks
      if (_selectedType == SearchType.content || _selectedType == SearchType.both) {
        for (final block in page.blocks) {
          final blockText = _extractTextFromBlock(block);
          if (_matchesQuery(blockText, query)) {
            results.add(SearchResult(
              page: page,
              blockId: block.id,
              matchedText: query,
              contextSnippet: _createContextSnippet(blockText, query),
              relevanceScore: _calculateContentRelevance(blockText, query),
            ));
          }
        }
      }
    }
    
    return results;
  }

  bool _matchesQuery(String text, String query) {
    if (text.isEmpty || query.isEmpty) return false;
    
    String searchText = _caseSensitive ? text : text.toLowerCase();
    String searchQuery = _caseSensitive ? query : query.toLowerCase();
    
    if (_useRegex) {
      try {
        final regex = RegExp(searchQuery, caseSensitive: _caseSensitive);
        return regex.hasMatch(text);
      } catch (e) {
        // Invalid regex, fall back to simple search
      }
    }
    
    if (_wholeWords) {
      final regex = RegExp(r'\b' + RegExp.escape(searchQuery) + r'\b', 
          caseSensitive: _caseSensitive);
      return regex.hasMatch(text);
    }
    
    return searchText.contains(searchQuery);
  }

  String _extractTextFromBlock(NotionBlock block) {
    switch (block.type) {
      case BlockType.text:
        return block.content['text'] ?? '';
      case BlockType.heading:
        return block.content['text'] ?? '';
      case BlockType.bulletList:
      case BlockType.numberedList:
        final items = block.content['items'] as List? ?? [];
        return items.join(' ');
      case BlockType.quote:
        return block.content['text'] ?? '';
      case BlockType.callout:
        return block.content['text'] ?? '';
      case BlockType.code:
        return block.content['code'] ?? '';
      case BlockType.table:
        final rows = block.content['rows'] as List? ?? [];
        final allCells = <String>[];
        for (final row in rows) {
          if (row is List) {
            allCells.addAll(row.map((cell) => cell.toString()));
          }
        }
        return allCells.join(' ');
      default:
        return '';
    }
  }

  String _createContextSnippet(String text, String query) {
    if (text.length <= 100) return text;
    
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    
    if (index == -1) return text.substring(0, 100) + '...';
    
    const contextLength = 40;
    final start = (index - contextLength).clamp(0, text.length);
    final end = (index + query.length + contextLength).clamp(0, text.length);
    
    String snippet = text.substring(start, end);
    if (start > 0) snippet = '...$snippet';
    if (end < text.length) snippet = '$snippet...';
    
    return snippet;
  }

  double _calculateTitleRelevance(String title, String query) {
    if (title.toLowerCase() == query.toLowerCase()) return 1.0;
    if (title.toLowerCase().startsWith(query.toLowerCase())) return 0.9;
    return 0.7;
  }

  double _calculateContentRelevance(String content, String query) {
    final lowerContent = content.toLowerCase();
    final lowerQuery = query.toLowerCase();
    
    // Count occurrences
    int count = 0;
    int index = lowerContent.indexOf(lowerQuery);
    while (index != -1) {
      count++;
      index = lowerContent.indexOf(lowerQuery, index + 1);
    }
    
    // Calculate relevance based on frequency and content length
    final frequency = count / (content.length / query.length);
    return (frequency * 0.5).clamp(0.1, 0.6);
  }

  void _sortResults() {
    switch (_selectedSort) {
      case SortOrder.relevance:
        _results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
        break;
      case SortOrder.modified:
        _results.sort((a, b) => b.page.updatedAt.compareTo(a.page.updatedAt));
        break;
      case SortOrder.created:
        _results.sort((a, b) => b.page.createdAt.compareTo(a.page.createdAt));
        break;
      case SortOrder.title:
        _results.sort((a, b) => a.page.title.compareTo(b.page.title));
        break;
    }
    setState(() {});
  }

  String _getSortOrderName(SortOrder order) {
    switch (order) {
      case SortOrder.relevance:
        return 'Relevancia';
      case SortOrder.modified:
        return 'Modificado';
      case SortOrder.created:
        return 'Creado';
      case SortOrder.title:
        return 'Título';
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