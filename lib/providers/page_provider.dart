import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/comment.dart';
import '../services/page_service.dart';
import 'workspace_provider.dart';

// Enums for permissions and roles
enum WorkspaceRole { owner, admin, member, guest }
enum PagePermissionType { edit, comment, view }

// Service provider
final pageServiceProvider = Provider<PageService>((ref) => PageService(ref.read(workspaceServiceProvider)));

// Individual page provider
final pageProvider = FutureProvider.family<NotionPage, String>((ref, pageId) async {
  final service = ref.read(pageServiceProvider);
  return service.getPage(pageId);
});

// Workspace pages provider  
final workspacePagesProvider = FutureProvider.family<List<NotionPage>, String>((ref, workspaceId) async {
  final service = ref.read(pageServiceProvider);
  return service.getWorkspacePages(workspaceId);
});

// State providers for page management
final selectedPageProvider = StateProvider<NotionPage?>((ref) => null);

final workspacePagesNotifierProvider = StateNotifierProvider.family<WorkspacePagesNotifier, AsyncValue<List<NotionPage>>, String>((ref, workspaceId) {
  return WorkspacePagesNotifier(ref.read(pageServiceProvider), workspaceId);
});

final pageBlocksProvider = StateNotifierProvider.family<PageBlocksNotifier, AsyncValue<List<PageBlock>>, String>((ref, pageId) {
  return PageBlocksNotifier(ref.read(pageServiceProvider), pageId);
});

final pageCommentsProvider = StateNotifierProvider.family<PageCommentsNotifier, AsyncValue<List<Comment>>, String>((ref, pageId) {
  return PageCommentsNotifier(ref.read(pageServiceProvider), pageId);
});

final searchResultsProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<NotionPage>>>((ref) {
  return SearchNotifier(ref.read(pageServiceProvider));
});

class WorkspacePagesNotifier extends StateNotifier<AsyncValue<List<NotionPage>>> {
  final PageService _pageService;
  final String workspaceId;

  WorkspacePagesNotifier(this._pageService, this.workspaceId) : super(const AsyncValue.loading()) {
    loadPages();
  }

  Future<void> loadPages() async {
    state = const AsyncValue.loading();
    try {
      final pages = await _pageService.getWorkspacePages(workspaceId);
      state = AsyncValue.data(pages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<NotionPage> createPage({
    String? parentId,
    String title = 'Untitled',
    String? icon,
    int? position,
  }) async {
    try {
      final page = await _pageService.createPage(
        workspaceId: workspaceId,
        parentId: parentId,
        title: title,
        icon: icon,
        position: position,
      );
      await loadPages(); // Refresh the list
      return page;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePage(NotionPage page) async {
    try {
      await _pageService.updatePage(page);
      await loadPages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePage(String pageId) async {
    try {
      await _pageService.deletePage(pageId);
      await loadPages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> movePage({
    required String pageId,
    String? newParentId,
    required int newPosition,
  }) async {
    try {
      await _pageService.movePage(
        pageId: pageId,
        newParentId: newParentId,
        newPosition: newPosition,
      );
      await loadPages(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods for UI
  List<NotionPage> getTopLevelPages() {
    return state.maybeWhen(
      data: (pages) => pages.where((page) => page.parentId == null).toList(),
      orElse: () => [],
    );
  }

  List<NotionPage> getChildPages(String parentId) {
    return state.maybeWhen(
      data: (pages) => pages.where((page) => page.parentId == parentId).toList(),
      orElse: () => [],
    );
  }
}

class PageBlocksNotifier extends StateNotifier<AsyncValue<List<PageBlock>>> {
  final PageService _pageService;
  final String pageId;

  PageBlocksNotifier(this._pageService, this.pageId) : super(const AsyncValue.loading()) {
    loadBlocks();
  }

  Future<void> loadBlocks() async {
    state = const AsyncValue.loading();
    try {
      final blocks = await _pageService.getPageBlocks(pageId);
      state = AsyncValue.data(blocks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<PageBlock> createBlock({
    String? parentBlockId,
    required BlockType type,
    required Map<String, dynamic> content,
    required int position,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final block = await _pageService.createBlock(
        pageId: pageId,
        parentBlockId: parentBlockId,
        type: type,
        content: content,
        position: position,
        properties: properties,
      );
      await loadBlocks(); // Refresh the list
      return block;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBlock(PageBlock block) async {
    try {
      await _pageService.updateBlock(block);
      
      // Update state optimistically
      state.whenData((blocks) {
        final updatedBlocks = blocks.map((b) => b.id == block.id ? block : b).toList();
        state = AsyncValue.data(updatedBlocks);
      });
    } catch (e) {
      // Revert on error
      await loadBlocks();
      rethrow;
    }
  }

  Future<void> deleteBlock(String blockId) async {
    try {
      await _pageService.deleteBlock(blockId);
      await loadBlocks(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> moveBlock({
    required String blockId,
    String? newParentId,
    required int newPosition,
  }) async {
    try {
      await _pageService.moveBlock(
        blockId: blockId,
        newParentId: newParentId,
        newPosition: newPosition,
      );
      await loadBlocks(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  // Additional methods for notion_page_editor
  Future<void> reorderBlocks(int oldIndex, int newIndex) async {
    state.whenData((blocks) async {
      if (oldIndex < 0 || oldIndex >= blocks.length || newIndex < 0 || newIndex >= blocks.length || oldIndex == newIndex) {
        return;
      }
      
      // Adjust newIndex if moving down
      int adjustedNewIndex = newIndex;
      if (oldIndex < newIndex) {
        adjustedNewIndex = newIndex - 1;
      }
      
      final List<PageBlock> updatedBlocks = List.from(blocks);
      final block = updatedBlocks.removeAt(oldIndex);
      updatedBlocks.insert(adjustedNewIndex, block);
      
      // Update state optimistically
      state = AsyncValue.data(updatedBlocks);
      
      // Update positions in backend
      await _updateBlockPositions(updatedBlocks);
    });
  }

  Future<void> updateBlockContent(String blockId, Map<String, dynamic> content) async {
    final currentBlocks = state.valueOrNull;
    if (currentBlocks == null) return;
    
    final blocks = currentBlocks;
    final blockIndex = blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex != -1) {
      final updatedBlock = blocks[blockIndex].copyWith(content: content.toString());
      final updatedBlocks = List<PageBlock>.from(blocks);
      updatedBlocks[blockIndex] = updatedBlock;
      
      // Update state optimistically
      state = AsyncValue.data(updatedBlocks);
      
      try {
        await _pageService.updateBlock(updatedBlock);
      } catch (e) {
        // Revert on error
        await loadBlocks();
        rethrow;
      }
    }
  }

  Future<void> changeBlockType(String blockId, BlockType newType) async {
    final currentBlocks = state.valueOrNull;
    if (currentBlocks == null) return;
    
    final blocks = currentBlocks;
    final blockIndex = blocks.indexWhere((b) => b.id == blockId);
    if (blockIndex != -1) {
      final block = blocks[blockIndex];
      final updatedBlock = block.copyWith(type: newType);
      final updatedBlocks = List<PageBlock>.from(blocks);
      updatedBlocks[blockIndex] = updatedBlock;
      
      // Update state optimistically
      state = AsyncValue.data(updatedBlocks);
      
      try {
        await _pageService.updateBlock(updatedBlock);
      } catch (e) {
        // Revert on error
        await loadBlocks();
        rethrow;
      }
    }
  }

  Future<void> addBlock(PageBlock block) async {
    try {
      await _pageService.updateBlock(block);
      
      // Add to current state
      final currentBlocks = state.valueOrNull;
      if (currentBlocks != null) {
        final updatedBlocks = List<PageBlock>.from(currentBlocks)..add(block);
        state = AsyncValue.data(updatedBlocks);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _updateBlockPositions(List<PageBlock> blocks) async {
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].position != i) {
        try {
          final updatedBlock = blocks[i].copyWith(position: i);
          await _pageService.updateBlock(updatedBlock);
        } catch (e) {
          // Continue with other blocks even if one fails
          debugPrint('Failed to update block position: $e');
        }
      }
    }
  }

  // Helper method to get blocks by type
  List<PageBlock> getBlocksByType(BlockType type) {
    return state.maybeWhen(
      data: (blocks) => blocks.where((block) => block.type == type).toList(),
      orElse: () => [],
    );
  }

  // Helper method to find a block by ID
  PageBlock? findBlockById(String blockId) {
    return state.maybeWhen(
      data: (blocks) {
        try {
          return blocks.firstWhere((block) => block.id == blockId);
        } catch (e) {
          return null;
        }
      },
      orElse: () => null,
    );
  }
}

class PageCommentsNotifier extends StateNotifier<AsyncValue<List<Comment>>> {
  final PageService _pageService;
  final String pageId;

  PageCommentsNotifier(this._pageService, this.pageId) : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _pageService.getPageComments(pageId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Comment> addComment({
    String? blockId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final comment = await _pageService.addComment(
        pageId: pageId,
        blockId: blockId,
        content: content,
        parentCommentId: parentCommentId,
      );
      await loadComments(); // Refresh the list
      return comment;
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods
  List<Comment> getTopLevelComments() {
    return state.maybeWhen(
      data: (comments) => comments.where((comment) => comment.parentCommentId == null).toList(),
      orElse: () => [],
    );
  }

  List<Comment> getReplies(String parentCommentId) {
    return state.maybeWhen(
      data: (comments) => comments.where((comment) => comment.parentCommentId == parentCommentId).toList(),
      orElse: () => [],
    );
  }

  List<Comment> getBlockComments(String blockId) {
    return state.maybeWhen(
      data: (comments) => comments.where((comment) => comment.blockId == blockId).toList(),
      orElse: () => [],
    );
  }
}

class SearchNotifier extends StateNotifier<AsyncValue<List<NotionPage>>> {
  final PageService _pageService;

  SearchNotifier(this._pageService) : super(const AsyncValue.data([]));

  Future<void> searchPages({
    required String workspaceId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final results = await _pageService.searchPages(
        workspaceId: workspaceId,
        query: query,
      );
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Utility providers
final currentUserRoleProvider = FutureProvider.family<WorkspaceRole, String>((ref, workspaceId) async {
  // This would typically come from the workspace service
  // For now, return a default role
  return WorkspaceRole.member;
});

final pagePermissionsProvider = FutureProvider.family<PagePermissionType, String>((ref, pageId) async {
  // This would typically come from the page service
  // For now, return a default permission
  return PagePermissionType.edit;
});