// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CommentImpl _$$CommentImplFromJson(Map<String, dynamic> json) =>
    _$CommentImpl(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      blockId: json['blockId'] as String?,
      userId: json['userId'] as String,
      content: json['content'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CommentImplToJson(_$CommentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'blockId': instance.blockId,
      'userId': instance.userId,
      'content': instance.content,
      'parentCommentId': instance.parentCommentId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userEmail': instance.userEmail,
      'userName': instance.userName,
      'replies': instance.replies,
    };

_$ActivityLogImpl _$$ActivityLogImplFromJson(Map<String, dynamic> json) =>
    _$ActivityLogImpl(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String?,
      pageId: json['pageId'] as String?,
      userId: json['userId'] as String,
      action: json['action'] as String,
      details: json['details'] as Map<String, dynamic>? ?? const {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      userEmail: json['userEmail'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$$ActivityLogImplToJson(_$ActivityLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workspaceId': instance.workspaceId,
      'pageId': instance.pageId,
      'userId': instance.userId,
      'action': instance.action,
      'details': instance.details,
      'createdAt': instance.createdAt.toIso8601String(),
      'userEmail': instance.userEmail,
      'userName': instance.userName,
    };
