import 'package:flutter/material.dart';
import '../models/page.dart';

class BreadcrumbNavigation extends StatelessWidget {
  final List<NotionPage> breadcrumbPages;
  final Function(NotionPage) onPageTap;
  final NotionPage? currentPage;

  const BreadcrumbNavigation({
    super.key,
    required this.breadcrumbPages,
    required this.onPageTap,
    this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (breadcrumbPages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(60),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _buildBreadcrumbItems(theme),
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(ThemeData theme) {
    final items = <Widget>[];
    
    // Add workspace icon
    items.add(
      Icon(
        Icons.folder_outlined,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    
    // Add separator if there are pages
    if (breadcrumbPages.isNotEmpty) {
      items.add(_buildSeparator(theme));
    }

    // Add breadcrumb pages
    for (int i = 0; i < breadcrumbPages.length; i++) {
      final page = breadcrumbPages[i];
      final isLast = i == breadcrumbPages.length - 1;
      final isCurrent = currentPage?.id == page.id;
      
      // Add page item
      items.add(_buildBreadcrumbItem(page, isLast || isCurrent, theme));
      
      // Add separator if not last
      if (!isLast) {
        items.add(_buildSeparator(theme));
      }
    }
    
    return items;
  }

  Widget _buildBreadcrumbItem(NotionPage page, bool isCurrentOrLast, ThemeData theme) {
    return GestureDetector(
      onTap: isCurrentOrLast ? null : () => onPageTap(page),
      child: MouseRegion(
        cursor: isCurrentOrLast ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrentOrLast 
              ? theme.colorScheme.primary.withAlpha(100)
              : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page icon
              if (page.icon != null && page.icon!.isNotEmpty) ...[
                Text(
                  page.icon!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 4),
              ],
              
              // Page title
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  page.title.isEmpty ? 'Página sin título' : page.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isCurrentOrLast 
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isCurrentOrLast 
                      ? FontWeight.w600
                      : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
      ),
    );
  }
}

class BreadcrumbBuilder {
  /// Build breadcrumb path from a page up to the root
  static List<NotionPage> buildBreadcrumb(
    NotionPage currentPage,
    List<NotionPage> allPages,
  ) {
    final breadcrumb = <NotionPage>[];
    NotionPage? current = currentPage;
    
    // Traverse up the hierarchy
    while (current != null) {
      breadcrumb.insert(0, current);
      
      // Find parent page
      if (current.parentId != null) {
        current = allPages.firstWhere(
          (page) => page.id == current!.parentId,
          orElse: () => current!, // Fallback to current if parent not found
        );
        
        // Avoid infinite loops
        if (breadcrumb.contains(current)) {
          break;
        }
      } else {
        break;
      }
    }
    
    return breadcrumb;
  }

  /// Get all child pages of a parent page
  static List<NotionPage> getChildPages(
    String parentId,
    List<NotionPage> allPages,
  ) {
    return allPages
        .where((page) => page.parentId == parentId)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Get the depth level of a page in the hierarchy
  static int getPageDepth(NotionPage page, List<NotionPage> allPages) {
    int depth = 0;
    NotionPage? current = page;
    
    while (current?.parentId != null) {
      depth++;
      current = allPages.firstWhere(
        (p) => p.id == current!.parentId,
        orElse: () => current!, // Fallback
      );
      
      // Avoid infinite loops
      if (depth > 10) break;
    }
    
    return depth;
  }

  /// Check if a page is a child of another page
  static bool isChildOf(
    NotionPage childPage,
    NotionPage parentPage,
    List<NotionPage> allPages,
  ) {
    NotionPage? current = childPage;
    
    while (current?.parentId != null) {
      if (current!.parentId == parentPage.id) {
        return true;
      }
      
      try {
        current = allPages.firstWhere((p) => p.id == current!.parentId);
      } catch (e) {
        current = null;
      }
    }
    
    return false;
  }

  /// Get the root pages (pages with no parent)
  static List<NotionPage> getRootPages(List<NotionPage> allPages) {
    return allPages
        .where((page) => page.parentId == null)
        .toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  /// Build a hierarchical tree structure from flat page list
  static List<PageNode> buildPageTree(List<NotionPage> allPages) {
    final pageMap = <String, PageNode>{};
    final rootNodes = <PageNode>[];

    // Create nodes for all pages
    for (final page in allPages) {
      pageMap[page.id] = PageNode(page: page);
    }

    // Build hierarchy
    for (final page in allPages) {
      final node = pageMap[page.id]!;
      
      if (page.parentId != null && pageMap.containsKey(page.parentId)) {
        // Add as child to parent
        pageMap[page.parentId]!.children.add(node);
      } else {
        // Add as root node
        rootNodes.add(node);
      }
    }

    // Sort nodes by position
    for (final node in pageMap.values) {
      node.children.sort((a, b) => 
        a.page.position.compareTo(b.page.position));
    }
    
    rootNodes.sort((a, b) => 
      a.page.position.compareTo(b.page.position));

    return rootNodes;
  }
}

class PageNode {
  final NotionPage page;
  final List<PageNode> children = [];

  PageNode({required this.page});

  bool get hasChildren => children.isNotEmpty;
  
  int get depth => _calculateDepth(0);
  
  int _calculateDepth(int currentDepth) {
    if (children.isEmpty) return currentDepth;
    return children
        .map((child) => child._calculateDepth(currentDepth + 1))
        .fold(currentDepth, (max, depth) => depth > max ? depth : max);
  }
}