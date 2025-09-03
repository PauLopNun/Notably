import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/comment.dart';
import '../models/workspace.dart';
import '../services/page_service.dart';

// State providers for page management
final selectedPageProvider = StateProvider<NotionPage?>((ref) => null);

final workspacePagesProvider = StateNotifierProvider.family<WorkspacePagesNotifier, AsyncValue<List<NotionPage>>, String>((ref, workspaceId) {
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