import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import '../services/workspace_service.dart';

// State providers for workspace management
final selectedWorkspaceProvider = StateProvider<Workspace?>((ref) => null);

final workspaceListProvider = StateNotifierProvider<WorkspaceListNotifier, AsyncValue<List<Workspace>>>((ref) {
  return WorkspaceListNotifier(ref.read(workspaceServiceProvider));
});

final workspaceMembersProvider = StateNotifierProvider.family<WorkspaceMembersNotifier, AsyncValue<List<WorkspaceMember>>, String>((ref, workspaceId) {
  return WorkspaceMembersNotifier(ref.read(workspaceServiceProvider), workspaceId);
});

class WorkspaceListNotifier extends StateNotifier<AsyncValue<List<Workspace>>> {
  final WorkspaceService _workspaceService;

  WorkspaceListNotifier(this._workspaceService) : super(const AsyncValue.loading()) {
    loadWorkspaces();
  }

  Future<void> loadWorkspaces() async {
    state = const AsyncValue.loading();
    try {
      final workspaces = await _workspaceService.fetchUserWorkspaces();
      state = AsyncValue.data(workspaces);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createWorkspace({
    required String name,
    String? description,
    String icon = '📝',
  }) async {
    try {
      await _workspaceService.createWorkspace(
        name: name,
        description: description,
        icon: icon,
      );
      await loadWorkspaces(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateWorkspace(Workspace workspace) async {
    try {
      await _workspaceService.updateWorkspace(workspace);
      await loadWorkspaces(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await _workspaceService.deleteWorkspace(workspaceId);
      await loadWorkspaces(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }
}

class WorkspaceMembersNotifier extends StateNotifier<AsyncValue<List<WorkspaceMember>>> {
  final WorkspaceService _workspaceService;
  final String workspaceId;

  WorkspaceMembersNotifier(this._workspaceService, this.workspaceId) : super(const AsyncValue.loading()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    state = const AsyncValue.loading();
    try {
      final members = await _workspaceService.getWorkspaceMembers(workspaceId);
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> inviteMember({
    required String email,
    required String role,
  }) async {
    try {
      await _workspaceService.inviteMember(
        workspaceId: workspaceId,
        email: email,
        role: role,
      );
      await loadMembers(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMemberRole({
    required String userId,
    required String role,
  }) async {
    try {
      await _workspaceService.updateMemberRole(
        workspaceId: workspaceId,
        userId: userId,
        role: role,
      );
      await loadMembers(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await _workspaceService.removeMember(
        workspaceId: workspaceId,
        userId: userId,
      );
      await loadMembers(); // Refresh the list
    } catch (e) {
      rethrow;
    }
  }
}