import 'package:equatable/equatable.dart';

class NotionPage extends Equatable {
  final String id;
  final String title;
  final String content;
  final String? icon;
  final List<Map<String, dynamic>> blocks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final bool isPublic;
  final List<String> tags;
  final String? workspaceId;
  final int position;

  const NotionPage({
    required this.id,
    required this.title,
    required this.content,
    this.icon,
    this.blocks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.isPublic = false,
    this.tags = const [],
    this.workspaceId,
    this.position = 0,
  });

  NotionPage copyWith({
    String? id,
    String? title,
    String? content,
    String? icon,
    List<Map<String, dynamic>>? blocks,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    bool? isPublic,
    List<String>? tags,
    String? workspaceId,
    int? position,
  }) {
    return NotionPage(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      blocks: blocks ?? this.blocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
      workspaceId: workspaceId ?? this.workspaceId,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'icon': icon,
      'blocks': blocks,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'parent_id': parentId,
      'is_public': isPublic,
      'tags': tags,
      'workspace_id': workspaceId,
      'position': position,
    };
  }

  factory NotionPage.fromJson(Map<String, dynamic> json) {
    return NotionPage(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      icon: json['icon'] as String?,
      blocks: (json['blocks'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentId: json['parent_id'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      workspaceId: json['workspace_id'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        icon,
        blocks,
        createdAt,
        updatedAt,
        parentId,
        isPublic,
        tags,
        workspaceId,
        position,
      ];
}