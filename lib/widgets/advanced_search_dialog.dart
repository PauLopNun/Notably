import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note.dart';

class AdvancedSearchDialog extends StatefulWidget {
  final List<Note> notes;
  final Function(Note) onNoteSelected;

  const AdvancedSearchDialog({
    super.key,
    required this.notes,
    required this.onNoteSelected,
  });

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog>
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Note> _filteredNotes = [];
  int _selectedIndex = 0;
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;
  
  final List<SearchFilter> _filters = [
    SearchFilter('all', 'All notes', Icons.notes, null),
    SearchFilter('recent', 'Recent', Icons.schedule, null),
    SearchFilter('today', 'Today', Icons.today, null),
    SearchFilter('week', 'This week', Icons.date_range, null),
    SearchFilter('month', 'This month', Icons.calendar_month, null),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _filteredNotes = widget.notes;
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
    
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotes = widget.notes.where((note) {
        // Text search
        final titleMatch = note.title.toLowerCase().contains(query);
        final contentMatch = _getContentText(note.content).toLowerCase().contains(query);
        final textMatch = query.isEmpty || titleMatch || contentMatch;
        
        if (!textMatch) return false;
        
        // Filter by category
        switch (_selectedFilter) {
          case 'recent':
            return DateTime.now().difference(note.updatedAt).inDays <= 7;
          case 'today':
            final today = DateTime.now();
            return note.updatedAt.day == today.day &&
                   note.updatedAt.month == today.month &&
                   note.updatedAt.year == today.year;
          case 'week':
            return DateTime.now().difference(note.updatedAt).inDays <= 7;
          case 'month':
            return DateTime.now().difference(note.updatedAt).inDays <= 30;
          case 'all':
          default:
            return true;
        }
      }).toList();
      
      // Sort by relevance and date
      _filteredNotes.sort((a, b) {
        // Priority for title matches
        final aTitle = a.title.toLowerCase().contains(query);
        final bTitle = b.title.toLowerCase().contains(query);
        
        if (aTitle && !bTitle) return -1;
        if (!aTitle && bTitle) return 1;
        
        // Then by last updated
        return b.updatedAt.compareTo(a.updatedAt);
      });
      
      _selectedIndex = 0;
    });
  }

  String _getContentText(List<dynamic> content) {
    if (content.isEmpty) return '';
    try {
      final buffer = StringBuffer();
      for (final op in content) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert'].toString());
        }
      }
      return buffer.toString();
    } catch (e) {
      return content.toString();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1).clamp(0, _filteredNotes.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex = (_selectedIndex - 1).clamp(0, _filteredNotes.length - 1);
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredNotes.isNotEmpty) {
          widget.onNoteSelected(_filteredNotes[_selectedIndex]);
          Navigator.pop(context);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.6 * _fadeAnimation.value),
            child: Center(
              child: SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 700,
                    height: mediaQuery.size.height * 0.8,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSearchHeader(theme),
                        _buildFilters(theme),
                        Expanded(
                          child: _buildSearchResults(theme),
                        ),
                        _buildFooter(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: theme.textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: 'Search in all notes...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Row(
            children: [
              _buildKeyboardShortcut(theme, '↑↓', 'Navigate'),
              const SizedBox(width: 8),
              _buildKeyboardShortcut(theme, '↵', 'Select'),
              const SizedBox(width: 8),
              _buildKeyboardShortcut(theme, 'ESC', 'Close'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardShortcut(ThemeData theme, String key, String label) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          key,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.asMap().entries.map((entry) {
            final index = entry.key;
            final filter = entry.value;
            final isSelected = filter.id == _selectedFilter;
            
            return Padding(
              padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
              child: FilterChip(
                avatar: Icon(
                  filter.icon,
                  size: 16,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                label: Text(filter.label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter.id;
                    _onSearchChanged();
                  });
                },
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                selectedColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ).animate(delay: (index * 50).ms).slideX(
                begin: -0.1,
                duration: 200.ms,
              ).fadeIn(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_filteredNotes.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) {
        final note = _filteredNotes[index];
        final isSelected = index == _selectedIndex;
        
        return _buildSearchResultItem(theme, note, isSelected, index);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasQuery = _searchController.text.isNotEmpty;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasQuery ? Icons.search_off : Icons.auto_awesome,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasQuery ? 'No matching notes found' : 'Start typing to search',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasQuery 
                ? 'Try different keywords or adjust filters'
                : 'Search across all your notes and content',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasQuery) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged();
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear search'),
            ),
          ],
        ],
      ),
    ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn();
  }

  Widget _buildSearchResultItem(
    ThemeData theme,
    Note note,
    bool isSelected,
    int index,
  ) {
    final contentText = _getContentText(note.content);
    final preview = contentText.length > 150 
        ? '${contentText.substring(0, 150)}...'
        : contentText;

    // Highlight search terms
    final query = _searchController.text.toLowerCase();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected 
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              )
            : null,
      ),
      child: InkWell(
        onTap: () {
          widget.onNoteSelected(note);
          Navigator.pop(context);
        },
        onHover: (hovering) {
          if (hovering) {
            setState(() => _selectedIndex = index);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Note icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('📄', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 16),
              
              // Note content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (preview.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(note.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        if (contentText.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.description,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${contentText.split(' ').length} words',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Action indicator
              if (isSelected) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '↵',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 30).ms).slideX(
      begin: -0.05,
      duration: 200.ms,
    ).fadeIn();
  }

  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Found ${_filteredNotes.length} note${_filteredNotes.length == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

class SearchFilter {
  final String id;
  final String label;
  final IconData icon;
  final Color? color;

  SearchFilter(this.id, this.label, this.icon, this.color);
}