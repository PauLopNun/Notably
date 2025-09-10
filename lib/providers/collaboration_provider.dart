import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/comment.dart';
import '../models/workspace_member.dart';

final collaborationProvider = StateNotifierProvider<CollaborationNotifier, CollaborationState>((ref) {
  return CollaborationNotifier();
});

class CollaborationState {
  final List<Comment> comments;
  final List<WorkspaceMember> activeUsers;
  final bool isCollaborating;
  final bool isConnected;

  const CollaborationState({
    this.comments = const [],
    this.activeUsers = const [],
    this.isCollaborating = false,
    this.isConnected = false,
  });

  CollaborationState copyWith({
    List<Comment>? comments,
    List<WorkspaceMember>? activeUsers,
    bool? isCollaborating,
    bool? isConnected,
  }) {
    return CollaborationState(
      comments: comments ?? this.comments,
      activeUsers: activeUsers ?? this.activeUsers,
      isCollaborating: isCollaborating ?? this.isCollaborating,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  CollaborationNotifier() : super(const CollaborationState());

  void addComment(Comment comment) {
    state = state.copyWith(
      comments: [...state.comments, comment],
    );
  }

  void removeComment(String commentId) {
    state = state.copyWith(
      comments: state.comments.where((c) => c.id != commentId).toList(),
    );
  }

  void updateComment(Comment updatedComment) {
    state = state.copyWith(
      comments: state.comments
          .map((c) => c.id == updatedComment.id ? updatedComment : c)
          .toList(),
    );
  }

  void setActiveUsers(List<WorkspaceMember> users) {
    state = state.copyWith(activeUsers: users);
  }

  void startCollaboration() {
    state = state.copyWith(isCollaborating: true);
  }

  void stopCollaboration() {
    state = state.copyWith(isCollaborating: false);
  }

  void connect() {
    state = state.copyWith(isConnected: true);
  }

  void disconnect() {
    state = state.copyWith(isConnected: false);
  }
}