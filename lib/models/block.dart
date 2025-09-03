import 'package:freezed_annotation/freezed_annotation.dart';

part 'block.freezed.dart';
part 'block.g.dart';

@freezed
class PageBlock with _$PageBlock {
  const factory PageBlock({
    required String id,
    required String pageId,
    String? parentBlockId,
    required BlockType type,
    @Default({}) Map<String, dynamic> content,
    @Default({}) Map<String, dynamic> properties,
    @Default(0) int position,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PageBlock;

  factory PageBlock.fromJson(Map<String, dynamic> json) =>
      _$PageBlockFromJson(json);

  factory PageBlock.fromMap(Map<String, dynamic> map) {
    return PageBlock(
      id: map['id'].toString(),
      pageId: map['page_id'].toString(),
      parentBlockId: map['parent_block_id']?.toString(),
      type: BlockType.fromString(map['type'] ?? 'paragraph'),
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      properties: Map<String, dynamic>.from(map['properties'] ?? {}),
      position: map['position'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'page_id': pageId,
      'parent_block_id': parentBlockId,
      'type': type.value,
      'content': content,
      'properties': properties,
      'position': position,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Block types enum
enum BlockType {
  paragraph('paragraph'),
  heading1('heading1'),
  heading2('heading2'),
  heading3('heading3'),
  bulletedList('bulleted_list'),
  numberedList('numbered_list'),
  todo('todo'),
  quote('quote'),
  code('code'),
  divider('divider'),
  image('image'),
  video('video'),
  file('file'),
  embed('embed'),
  table('table'),
  database('database'),
  callout('callout');

  const BlockType(this.value);
  final String value;

  static BlockType fromString(String value) {
    return BlockType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => BlockType.paragraph,
    );
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
      case BlockType.todo:
        return 'To-do';
      case BlockType.quote:
        return 'Quote';
      case BlockType.code:
        return 'Code';
      case BlockType.divider:
        return 'Divider';
      case BlockType.image:
        return 'Image';
      case BlockType.video:
        return 'Video';
      case BlockType.file:
        return 'File';
      case BlockType.embed:
        return 'Embed';
      case BlockType.table:
        return 'Table';
      case BlockType.database:
        return 'Database';
      case BlockType.callout:
        return 'Callout';
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
      case BlockType.todo:
        return '☐';
      case BlockType.quote:
        return '❝';
      case BlockType.code:
        return '</>';
      case BlockType.divider:
        return '―';
      case BlockType.image:
        return '🖼️';
      case BlockType.video:
        return '🎥';
      case BlockType.file:
        return '📎';
      case BlockType.embed:
        return '🔗';
      case BlockType.table:
        return '📊';
      case BlockType.database:
        return '🗃️';
      case BlockType.callout:
        return '💡';
    }
  }

  bool get isTextBlock => [
        paragraph,
        heading1,
        heading2,
        heading3,
        quote,
      ].contains(this);

  bool get isListBlock => [
        bulletedList,
        numberedList,
        todo,
      ].contains(this);

  bool get isMediaBlock => [
        image,
        video,
        file,
        embed,
      ].contains(this);

  bool get isStructuralBlock => [
        divider,
        table,
        database,
        callout,
      ].contains(this);
}

// Helper classes for specific block content

@freezed
class TextContent with _$TextContent {
  const factory TextContent({
    @Default('') String text,
    @Default([]) List<Map<String, dynamic>> styles,
  }) = _TextContent;

  factory TextContent.fromJson(Map<String, dynamic> json) =>
      _$TextContentFromJson(json);
}

@freezed
class BlockTextStyle with _$BlockTextStyle {
  const factory BlockTextStyle({
    required int start,
    required int end,
    required String type, // 'bold', 'italic', 'underline', 'strikethrough', 'code', 'color'
    Map<String, dynamic>? attributes,
  }) = _BlockTextStyle;

  factory BlockTextStyle.fromJson(Map<String, dynamic> json) =>
      _$BlockTextStyleFromJson(json);
}

@freezed
class TodoContent with _$TodoContent {
  const factory TodoContent({
    @Default('') String text,
    @Default(false) bool checked,
    @Default([]) List<Map<String, dynamic>> styles,
  }) = _TodoContent;

  factory TodoContent.fromJson(Map<String, dynamic> json) =>
      _$TodoContentFromJson(json);
}

@freezed
class ImageContent with _$ImageContent {
  const factory ImageContent({
    required String url,
    String? caption,
    double? width,
    double? height,
  }) = _ImageContent;

  factory ImageContent.fromJson(Map<String, dynamic> json) =>
      _$ImageContentFromJson(json);
}

@freezed
class CodeContent with _$CodeContent {
  const factory CodeContent({
    required String code,
    String? language,
    String? caption,
  }) = _CodeContent;

  factory CodeContent.fromJson(Map<String, dynamic> json) =>
      _$CodeContentFromJson(json);
}

@freezed
class CalloutContent with _$CalloutContent {
  const factory CalloutContent({
    @Default('💡') String icon,
    required String text,
    @Default([]) List<Map<String, dynamic>> styles,
    String? backgroundColor,
  }) = _CalloutContent;

  factory CalloutContent.fromJson(Map<String, dynamic> json) =>
      _$CalloutContentFromJson(json);
}