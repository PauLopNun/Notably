import 'package:equatable/equatable.dart';

enum BlockType {
  paragraph,
  heading1,
  heading2,
  heading3,
  bulletedList,
  numberedList,
  quote,
  code,
  image,
  divider,
  callout,
  toggle,
  table,
  embed,
  file,
  bookmark,
  equation,
  todo,
  column,
  columnList,
  video,
  database,
}

extension BlockTypeExtension on BlockType {
  String get name {
    switch (this) {
      case BlockType.paragraph:
        return 'paragraph';
      case BlockType.heading1:
        return 'heading_1';
      case BlockType.heading2:
        return 'heading_2';
      case BlockType.heading3:
        return 'heading_3';
      case BlockType.bulletedList:
        return 'bulleted_list_item';
      case BlockType.numberedList:
        return 'numbered_list_item';
      case BlockType.quote:
        return 'quote';
      case BlockType.code:
        return 'code';
      case BlockType.image:
        return 'image';
      case BlockType.divider:
        return 'divider';
      case BlockType.callout:
        return 'callout';
      case BlockType.toggle:
        return 'toggle';
      case BlockType.table:
        return 'table';
      case BlockType.embed:
        return 'embed';
      case BlockType.file:
        return 'file';
      case BlockType.bookmark:
        return 'bookmark';
      case BlockType.equation:
        return 'equation';
      case BlockType.todo:
        return 'to_do';
      case BlockType.column:
        return 'column';
      case BlockType.columnList:
        return 'column_list';
      case BlockType.video:
        return 'video';
      case BlockType.database:
        return 'database';
    }
  }

  String get displayName {
    switch (this) {
      case BlockType.paragraph:
        return 'Paragraph';
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      case BlockType.bulletedList:
        return 'Bulleted List';
      case BlockType.numberedList:
        return 'Numbered List';
      case BlockType.quote:
        return 'Quote';
      case BlockType.code:
        return 'Code';
      case BlockType.image:
        return 'Image';
      case BlockType.divider:
        return 'Divider';
      case BlockType.callout:
        return 'Callout';
      case BlockType.toggle:
        return 'Toggle';
      case BlockType.table:
        return 'Table';
      case BlockType.embed:
        return 'Embed';
      case BlockType.file:
        return 'File';
      case BlockType.bookmark:
        return 'Bookmark';
      case BlockType.equation:
        return 'Equation';
      case BlockType.todo:
        return 'To-do';
      case BlockType.column:
        return 'Column';
      case BlockType.columnList:
        return 'Column List';
      case BlockType.video:
        return 'Video';
      case BlockType.database:
        return 'Database';
    }
  }

  String get icon {
    switch (this) {
      case BlockType.paragraph:
        return '📝';
      case BlockType.heading1:
        return 'H1';
      case BlockType.heading2:
        return 'H2';
      case BlockType.heading3:
        return 'H3';
      case BlockType.bulletedList:
        return '•';
      case BlockType.numberedList:
        return '1.';
      case BlockType.quote:
        return '"';
      case BlockType.code:
        return '⌨️';
      case BlockType.image:
        return '🖼️';
      case BlockType.divider:
        return '—';
      case BlockType.callout:
        return '💡';
      case BlockType.toggle:
        return '▶️';
      case BlockType.table:
        return '📊';
      case BlockType.embed:
        return '🔗';
      case BlockType.file:
        return '📎';
      case BlockType.bookmark:
        return '🔖';
      case BlockType.equation:
        return '∑';
      case BlockType.todo:
        return '☐';
      case BlockType.column:
        return '|';
      case BlockType.columnList:
        return '|||';
      case BlockType.video:
        return '🎥';
      case BlockType.database:
        return '🗄️';
    }
  }

  bool get isTextBlock {
    switch (this) {
      case BlockType.paragraph:
      case BlockType.heading1:
      case BlockType.heading2:
      case BlockType.heading3:
      case BlockType.quote:
      case BlockType.code:
      case BlockType.callout:
      case BlockType.todo:
        return true;
      default:
        return false;
    }
  }

  bool get isListBlock {
    switch (this) {
      case BlockType.bulletedList:
      case BlockType.numberedList:
      case BlockType.todo:
        return true;
      default:
        return false;
    }
  }

  static BlockType fromString(String type) {
    switch (type) {
      case 'paragraph':
        return BlockType.paragraph;
      case 'heading_1':
        return BlockType.heading1;
      case 'heading_2':
        return BlockType.heading2;
      case 'heading_3':
        return BlockType.heading3;
      case 'bulleted_list_item':
        return BlockType.bulletedList;
      case 'numbered_list_item':
        return BlockType.numberedList;
      case 'quote':
        return BlockType.quote;
      case 'code':
        return BlockType.code;
      case 'image':
        return BlockType.image;
      case 'divider':
        return BlockType.divider;
      case 'callout':
        return BlockType.callout;
      case 'toggle':
        return BlockType.toggle;
      case 'table':
        return BlockType.table;
      case 'embed':
        return BlockType.embed;
      case 'file':
        return BlockType.file;
      case 'bookmark':
        return BlockType.bookmark;
      case 'equation':
        return BlockType.equation;
      case 'to_do':
        return BlockType.todo;
      case 'column':
        return BlockType.column;
      case 'column_list':
        return BlockType.columnList;
      case 'video':
        return BlockType.video;
      case 'database':
        return BlockType.database;
      default:
        return BlockType.paragraph;
    }
  }
}

class PageBlock extends Equatable {
  final String id;
  final BlockType type;
  final String content;
  final Map<String, dynamic> properties;
  final List<PageBlock> children;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? parentId;
  final int position;

  const PageBlock({
    required this.id,
    required this.type,
    required this.content,
    this.properties = const {},
    this.children = const [],
    required this.createdAt,
    required this.updatedAt,
    this.parentId,
    this.position = 0,
  });

  PageBlock copyWith({
    String? id,
    BlockType? type,
    String? content,
    Map<String, dynamic>? properties,
    List<PageBlock>? children,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentId,
    int? position,
  }) {
    return PageBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      children: children ?? this.children,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentId: parentId ?? this.parentId,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'properties': properties,
      'children': children.map((child) => child.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'parent_id': parentId,
      'position': position,
    };
  }

  factory PageBlock.fromJson(Map<String, dynamic> json) {
    return PageBlock(
      id: json['id'] as String,
      type: BlockTypeExtension.fromString(json['type'] as String),
      content: json['content'] as String,
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => PageBlock.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      parentId: json['parent_id'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        content,
        properties,
        children,
        createdAt,
        updatedAt,
        parentId,
        position,
      ];
}