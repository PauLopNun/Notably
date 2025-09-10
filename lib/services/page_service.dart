import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/comment.dart';
import '../models/workspace.dart';
import 'workspace_service.dart';

final pageServiceProvider = Provider<PageService>((ref) => PageService(ref.read(workspaceServiceProvider)));

class PageService {
  final WorkspaceService _workspaceService;
  final _client = Supabase.instance.client;

  PageService(this._workspaceService);

  // Page CRUD operations
  Future<List<NotionPage>> getWorkspacePages(String workspaceId) async {
    try {
      final response = await _client
          .from('pages')
          .select('*')
          .eq('workspace_id', workspaceId)
          .order('position')
          .order('created_at');

      final pages = response.map<NotionPage>((item) => NotionPage.fromJson(item)).toList();
      
      // Build hierarchy
      return _buildPageHierarchy(pages);
    } catch (e) {
      throw Exception('Failed to fetch pages: $e');
    }
  }

  Future<NotionPage> getPage(String pageId) async {
    try {
      final response = await _client
          .from('pages')
          .select('*')
          .eq('id', pageId)
          .single();

      final page = NotionPage.fromJson(response);
      
      // Load blocks
      final blocks = await getPageBlocks(pageId);
      return page.copyWith(blocks: blocks);
    } catch (e) {
      throw Exception('Failed to fetch page: $e');
    }
  }

  Future<NotionPage> createPage({
    required String workspaceId,
    String? parentId,
    String title = 'Untitled',
    String? icon,
    int? position,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Check permissions
      final canEdit = await _workspaceService.hasPermission(
        workspaceId: workspaceId,
        userId: user.id,
        requiredRole: WorkspaceRole.member,
      );
      
      if (!canEdit) throw Exception('Insufficient permissions');

      final pageData = {
        'workspace_id': workspaceId,
        'parent_id': parentId,
        'title': title,
        'icon': icon,
        'position': position ?? 0,
        'created_by': user.id,
        'last_edited_by': user.id,
      };

      final response = await _client.from('pages').insert(pageData).select().single();
      
      // Create initial paragraph block
      await createBlock(
        pageId: response['id'],
        type: BlockType.paragraph,
        content: {'text': ''},
        position: 0,
      );

      // Log activity
      await _logActivity(
        workspaceId: workspaceId,
        pageId: response['id'],
        action: ActivityAction.pageCreated.value,
        details: {'title': title},
      );

      return NotionPage.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create page: $e');
    }
  }

  Future<void> updatePage(NotionPage page) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = page.toJson();
      data.remove('id');
      data.remove('created_at');
      data['last_edited_by'] = user.id;
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await _client.from('pages').update(data).eq('id', page.id);

      // Log activity
      await _logActivity(
        workspaceId: page.workspaceId,
        pageId: page.id,
        action: ActivityAction.pageUpdated.value,
        details: {'title': page.title},
      );
    } catch (e) {
      throw Exception('Failed to update page: $e');
    }
  }

  Future<void> deletePage(String pageId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get page info for logging
      final pageResponse = await _client
          .from('pages')
          .select('workspace_id, title')
          .eq('id', pageId)
          .single();

      await _client.from('pages').delete().eq('id', pageId);

      // Log activity
      await _logActivity(
        workspaceId: pageResponse['workspace_id'],
        action: ActivityAction.pageDeleted.value,
        details: {'title': pageResponse['title']},
      );
    } catch (e) {
      throw Exception('Failed to delete page: $e');
    }
  }

  Future<void> movePage({
    required String pageId,
    String? newParentId,
    required int newPosition,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('pages').update({
        'parent_id': newParentId,
        'position': newPosition,
        'last_edited_by': user.id,
      }).eq('id', pageId);

      // Get page info for logging
      final pageResponse = await _client
          .from('pages')
          .select('workspace_id, title')
          .eq('id', pageId)
          .single();

      // Log activity
      await _logActivity(
        workspaceId: pageResponse['workspace_id'],
        pageId: pageId,
        action: ActivityAction.pageMoved.value,
        details: {'title': pageResponse['title']},
      );
    } catch (e) {
      throw Exception('Failed to move page: $e');
    }
  }

  // Block operations
  Future<List<PageBlock>> getPageBlocks(String pageId) async {
    try {
      final response = await _client
          .from('page_blocks')
          .select('*')
          .eq('page_id', pageId)
          .order('position');

      final blocks = response.map<PageBlock>((item) => PageBlock.fromMap(item)).toList();
      return _buildBlockHierarchy(blocks);
    } catch (e) {
      throw Exception('Failed to fetch blocks: $e');
    }
  }

  Future<PageBlock> createBlock({
    required String pageId,
    String? parentBlockId,
    required BlockType type,
    required Map<String, dynamic> content,
    required int position,
    Map<String, dynamic>? properties,
  }) async {
    try {
      final response = await _client.from('page_blocks').insert({
        'page_id': pageId,
        'parent_block_id': parentBlockId,
        'type': type.value,
        'content': content,
        'properties': properties ?? {},
        'position': position,
      }).select().single();

      return PageBlock.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create block: $e');
    }
  }

  Future<void> updateBlock(PageBlock block) async {
    try {
      final data = block.toJson();
      data.remove('id');
      data.remove('created_at');
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await _client.from('page_blocks').update(data).eq('id', block.id);
    } catch (e) {
      throw Exception('Failed to update block: $e');
    }
  }

  Future<void> deleteBlock(String blockId) async {
    try {
      await _client.from('page_blocks').delete().eq('id', blockId);
    } catch (e) {
      throw Exception('Failed to delete block: $e');
    }
  }

  Future<void> moveBlock({
    required String blockId,
    String? newParentId,
    required int newPosition,
  }) async {
    try {
      await _client.from('page_blocks').update({
        'parent_block_id': newParentId,
        'position': newPosition,
      }).eq('id', blockId);
    } catch (e) {
      throw Exception('Failed to move block: $e');
    }
  }

  // Comments
  Future<List<Comment>> getPageComments(String pageId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            id, page_id, block_id, user_id, content, 
            parent_comment_id, created_at, updated_at,
            users:user_id (email, raw_user_meta_data)
          ''')
          .eq('page_id', pageId)
          .order('created_at');

      return response.map<Comment>((item) {
        final userData = item['users'];
        return Comment.fromMap({
          ...item,
          'user_email': userData?['email'],
          'user_name': userData?['raw_user_meta_data']?['name'] ?? userData?['email'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch comments: $e');
    }
  }

  Future<Comment> addComment({
    required String pageId,
    String? blockId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('comments').insert({
        'page_id': pageId,
        'block_id': blockId,
        'user_id': user.id,
        'content': content,
        'parent_comment_id': parentCommentId,
      }).select().single();

      return Comment.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Search
  Future<List<NotionPage>> searchPages({
    required String workspaceId,
    required String query,
  }) async {
    try {
      final response = await _client
          .from('pages')
          .select('*')
          .eq('workspace_id', workspaceId)
          .textSearch('title', query)
          .order('updated_at', ascending: false);

      return response.map<NotionPage>((item) => NotionPage.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Failed to search pages: $e');
    }
  }

  // Private helper methods
  List<NotionPage> _buildPageHierarchy(List<NotionPage> pages) {
    final Map<String, List<NotionPage>> childrenMap = {};
    final List<NotionPage> rootPages = [];

    // Group children by parent
    for (final page in pages) {
      if (page.parentId == null) {
        rootPages.add(page);
      } else {
        childrenMap[page.parentId!] = [...(childrenMap[page.parentId!] ?? []), page];
      }
    }

    // Recursively build hierarchy
    List<NotionPage> buildChildren(NotionPage parent) {
      final children = childrenMap[parent.id] ?? [];
      return children.map((child) {
        final grandChildren = buildChildren(child);
        return child.copyWith(children: grandChildren);
      }).toList();
    }

    return rootPages.map((root) {
      final children = buildChildren(root);
      return root.copyWith(children: children);
    }).toList();
  }

  List<PageBlock> _buildBlockHierarchy(List<PageBlock> blocks) {
    final Map<String, List<PageBlock>> childrenMap = {};
    final List<PageBlock> rootBlocks = [];

    // Group children by parent
    for (final block in blocks) {
      if (block.parentBlockId == null) {
        rootBlocks.add(block);
      } else {
        childrenMap[block.parentBlockId!] = [...(childrenMap[block.parentBlockId!] ?? []), block];
      }
    }

    // Recursively build hierarchy
    // Return blocks in hierarchical order (root blocks first, then children)
    return rootBlocks;
  }

  Future<void> _logActivity({
    String? workspaceId,
    String? pageId,
    required String action,
    Map<String, dynamic>? details,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      await _client.from('activity_log').insert({
        'workspace_id': workspaceId,
        'page_id': pageId,
        'user_id': user.id,
        'action': action,
        'details': details ?? {},
      });
    } catch (e) {
      // Silently fail - activity logging shouldn't break the main operation
    }
  }
}