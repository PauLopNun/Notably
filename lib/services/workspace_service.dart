import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workspace.dart';

final workspaceServiceProvider = Provider<WorkspaceService>((ref) => WorkspaceService());

class WorkspaceService {
  final _client = Supabase.instance.client;

  // Workspace CRUD operations
  Future<List<Workspace>> fetchUserWorkspaces() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('workspace_members')
          .select('''
            workspace_id,
            role,
            workspaces (
              id, name, description, icon, owner_id, 
              created_at, updated_at, settings
            )
          ''')
          .eq('user_id', user.id);

      return response.map<Workspace>((item) {
        final workspace = item['workspaces'];
        return Workspace.fromMap({
          ...workspace,
          'user_role': item['role'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch workspaces: $e');
    }
  }

  Future<Workspace> getWorkspace(String workspaceId) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('workspaces')
          .select('*')
          .eq('id', workspaceId)
          .single();

      // Check if user has access to this workspace
      final memberResponse = await _client
          .from('workspace_members')
          .select('role')
          .eq('workspace_id', workspaceId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (memberResponse == null) {
        throw Exception('Access denied to workspace');
      }

      return Workspace.fromMap({
        ...response,
        'user_role': memberResponse['role'],
      });
    } catch (e) {
      throw Exception('Failed to fetch workspace: $e');
    }
  }

  Future<Workspace> createWorkspace({
    required String name,
    String? description,
    String icon = '📝',
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create workspace
      final workspaceResponse = await _client.from('workspaces').insert({
        'name': name,
        'description': description,
        'icon': icon,
        'owner_id': user.id,
      }).select().single();

      // Add owner as member
      await _client.from('workspace_members').insert({
        'workspace_id': workspaceResponse['id'],
        'user_id': user.id,
        'role': 'owner',
      });

      return Workspace.fromMap(workspaceResponse);
    } catch (e) {
      throw Exception('Failed to create workspace: $e');
    }
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      final data = workspace.toJson();
      data.remove('id'); // Don't update ID
      data.remove('created_at'); // Don't update created_at
      data.remove('updated_at'); // Don't update updated_at
      data['updated_at'] = DateTime.now().toIso8601String();
      
      await _client.from('workspaces').update(data).eq('id', workspace.id);
    } catch (e) {
      throw Exception('Failed to update workspace: $e');
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await _client.from('workspaces').delete().eq('id', workspaceId);
    } catch (e) {
      throw Exception('Failed to delete workspace: $e');
    }
  }

  // Member management
  Future<List<WorkspaceMember>> getWorkspaceMembers(String workspaceId) async {
    try {
      final response = await _client
          .from('workspace_members')
          .select('''
            id, workspace_id, user_id, role, joined_at,
            users:user_id (email, raw_user_meta_data)
          ''')
          .eq('workspace_id', workspaceId);

      return response.map<WorkspaceMember>((item) {
        final userData = item['users'];
        return WorkspaceMember.fromMap({
          ...item,
          'user_email': userData?['email'],
          'user_name': userData?['raw_user_meta_data']?['name'] ?? userData?['email'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch workspace members: $e');
    }
  }

  Future<void> inviteMember({
    required String workspaceId,
    required String email,
    required String role,
  }) async {
    try {
      // Find user by email
      final userResponse = await _client
          .from('auth.users')
          .select('id')
          .eq('email', email)
          .single();

      // userResponse is never null from .single() - it throws if no data

      await _client.from('workspace_members').insert({
        'workspace_id': workspaceId,
        'user_id': userResponse['id'],
        'role': role,
      });
    } catch (e) {
      throw Exception('Failed to invite member: $e');
    }
  }

  Future<void> updateMemberRole({
    required String workspaceId,
    required String userId,
    required String role,
  }) async {
    try {
      await _client
          .from('workspace_members')
          .update({'role': role})
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update member role: $e');
    }
  }

  Future<void> removeMember({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      await _client
          .from('workspace_members')
          .delete()
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to remove member: $e');
    }
  }

  // Utility methods
  Future<WorkspaceRole> getUserRoleInWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    try {
      final response = await _client
          .from('workspace_members')
          .select('role')
          .eq('workspace_id', workspaceId)
          .eq('user_id', userId)
          .single();

      return WorkspaceRole.fromString(response['role']);
    } catch (e) {
      return WorkspaceRole.viewer;
    }
  }

  Future<bool> hasPermission({
    required String workspaceId,
    required String userId,
    required WorkspaceRole requiredRole,
  }) async {
    final userRole = await getUserRoleInWorkspace(
      workspaceId: workspaceId,
      userId: userId,
    );
    
    switch (requiredRole) {
      case WorkspaceRole.viewer:
        return true;
      case WorkspaceRole.member:
        return userRole.canEdit();
      case WorkspaceRole.admin:
        return userRole.canAdmin();
      case WorkspaceRole.owner:
        return userRole.canDelete();
    }
  }
}