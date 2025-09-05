import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';
part 'comment.g.dart';

@freezed
class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String pageId,
    String? blockId,
    required String userId,
    required String content,
    String? parentCommentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? userEmail,
    String? userName,
    @Default([]) List<Comment> replies,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'].toString(),
      pageId: map['page_id'].toString(),
      blockId: map['block_id']?.toString(),
      userId: map['user_id'].toString(),
      content: map['content'] ?? '',
      parentCommentId: map['parent_comment_id']?.toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      userEmail: map['user_email'],
      userName: map['user_name'],
    );
  }

}

@freezed
class ActivityLog with _$ActivityLog {
  const factory ActivityLog({
    required String id,
    String? workspaceId,
    String? pageId,
    required String userId,
    required String action,
    @Default({}) Map<String, dynamic> details,
    required DateTime createdAt,
    String? userEmail,
    String? userName,
  }) = _ActivityLog;

  factory ActivityLog.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogFromJson(json);

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      id: map['id'].toString(),
      workspaceId: map['workspace_id']?.toString(),
      pageId: map['page_id']?.toString(),
      userId: map['user_id'].toString(),
      action: map['action'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      createdAt: DateTime.parse(map['created_at']),
      userEmail: map['user_email'],
      userName: map['user_name'],
    );
  }

}

enum ActivityAction {
  pageCreated('page_created'),
  pageUpdated('page_updated'),
  pageDeleted('page_deleted'),
  pageMoved('page_moved'),
  pageShared('page_shared'),
  workspaceCreated('workspace_created'),
  workspaceUpdated('workspace_updated'),
  memberAdded('member_added'),
  memberRemoved('member_removed'),
  memberRoleChanged('member_role_changed'),
  commentAdded('comment_added'),
  commentUpdated('comment_updated'),
  commentDeleted('comment_deleted');

  const ActivityAction(this.value);
  final String value;

  static ActivityAction fromString(String value) {
    return ActivityAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => ActivityAction.pageUpdated,
    );
  }

  String get displayName {
    switch (this) {
      case ActivityAction.pageCreated:
        return 'created a page';
      case ActivityAction.pageUpdated:
        return 'updated a page';
      case ActivityAction.pageDeleted:
        return 'deleted a page';
      case ActivityAction.pageMoved:
        return 'moved a page';
      case ActivityAction.pageShared:
        return 'shared a page';
      case ActivityAction.workspaceCreated:
        return 'created workspace';
      case ActivityAction.workspaceUpdated:
        return 'updated workspace';
      case ActivityAction.memberAdded:
        return 'added member';
      case ActivityAction.memberRemoved:
        return 'removed member';
      case ActivityAction.memberRoleChanged:
        return 'changed member role';
      case ActivityAction.commentAdded:
        return 'added comment';
      case ActivityAction.commentUpdated:
        return 'updated comment';
      case ActivityAction.commentDeleted:
        return 'deleted comment';
    }
  }
}