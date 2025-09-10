import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String pageId;
  final String? blockId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentCommentId;
  final List<Comment> replies;
  final bool isResolved;
  final List<String> mentions;

  const Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.pageId,
    this.blockId,
    required this.createdAt,
    required this.updatedAt,
    this.parentCommentId,
    this.replies = const [],
    this.isResolved = false,
    this.mentions = const [],
  });

  Comment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? pageId,
    String? blockId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentCommentId,
    List<Comment>? replies,
    bool? isResolved,
    List<String>? mentions,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      pageId: pageId ?? this.pageId,
      blockId: blockId ?? this.blockId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      isResolved: isResolved ?? this.isResolved,
      mentions: mentions ?? this.mentions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'page_id': pageId,
      'block_id': blockId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'parent_comment_id': parentCommentId,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'is_resolved': isResolved,
      'mentions': mentions,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      authorAvatar: json['author_avatar'] as String?,
      pageId: json['page_id'] as String,
      blockId: json['block_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentCommentId: json['parent_comment_id'] as String?,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((reply) => Comment.fromJson(reply as Map<String, dynamic>))
              .toList() ??
          [],
      isResolved: json['is_resolved'] as bool? ?? false,
      mentions: (json['mentions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  factory Comment.fromMap(Map<String, dynamic> map) => Comment.fromJson(map);

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorName,
        authorAvatar,
        pageId,
        blockId,
        createdAt,
        updatedAt,
        parentCommentId,
        replies,
        isResolved,
        mentions,
      ];
}