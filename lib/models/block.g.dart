// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageBlockImpl _$$PageBlockImplFromJson(Map<String, dynamic> json) =>
    _$PageBlockImpl(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      parentBlockId: json['parentBlockId'] as String?,
      type: $enumDecode(_$BlockTypeEnumMap, json['type']),
      content: json['content'] as Map<String, dynamic>? ?? const {},
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
      position: (json['position'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PageBlockImplToJson(_$PageBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageId': instance.pageId,
      'parentBlockId': instance.parentBlockId,
      'type': _$BlockTypeEnumMap[instance.type]!,
      'content': instance.content,
      'properties': instance.properties,
      'position': instance.position,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$BlockTypeEnumMap = {
  BlockType.paragraph: 'paragraph',
  BlockType.heading1: 'heading1',
  BlockType.heading2: 'heading2',
  BlockType.heading3: 'heading3',
  BlockType.bulletedList: 'bulletedList',
  BlockType.numberedList: 'numberedList',
  BlockType.todo: 'todo',
  BlockType.quote: 'quote',
  BlockType.code: 'code',
  BlockType.divider: 'divider',
  BlockType.image: 'image',
  BlockType.video: 'video',
  BlockType.file: 'file',
  BlockType.embed: 'embed',
  BlockType.table: 'table',
  BlockType.database: 'database',
  BlockType.callout: 'callout',
};

_$TextContentImpl _$$TextContentImplFromJson(Map<String, dynamic> json) =>
    _$TextContentImpl(
      text: json['text'] as String? ?? '',
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TextContentImplToJson(_$TextContentImpl instance) =>
    <String, dynamic>{'text': instance.text, 'styles': instance.styles};

_$BlockTextStyleImpl _$$BlockTextStyleImplFromJson(Map<String, dynamic> json) =>
    _$BlockTextStyleImpl(
      start: (json['start'] as num).toInt(),
      end: (json['end'] as num).toInt(),
      type: json['type'] as String,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$BlockTextStyleImplToJson(
  _$BlockTextStyleImpl instance,
) => <String, dynamic>{
  'start': instance.start,
  'end': instance.end,
  'type': instance.type,
  'attributes': instance.attributes,
};

_$TodoContentImpl _$$TodoContentImplFromJson(Map<String, dynamic> json) =>
    _$TodoContentImpl(
      text: json['text'] as String? ?? '',
      checked: json['checked'] as bool? ?? false,
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TodoContentImplToJson(_$TodoContentImpl instance) =>
    <String, dynamic>{
      'text': instance.text,
      'checked': instance.checked,
      'styles': instance.styles,
    };

_$ImageContentImpl _$$ImageContentImplFromJson(Map<String, dynamic> json) =>
    _$ImageContentImpl(
      url: json['url'] as String,
      caption: json['caption'] as String?,
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$ImageContentImplToJson(_$ImageContentImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'caption': instance.caption,
      'width': instance.width,
      'height': instance.height,
    };

_$CodeContentImpl _$$CodeContentImplFromJson(Map<String, dynamic> json) =>
    _$CodeContentImpl(
      code: json['code'] as String,
      language: json['language'] as String?,
      caption: json['caption'] as String?,
    );

Map<String, dynamic> _$$CodeContentImplToJson(_$CodeContentImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'language': instance.language,
      'caption': instance.caption,
    };

_$CalloutContentImpl _$$CalloutContentImplFromJson(Map<String, dynamic> json) =>
    _$CalloutContentImpl(
      icon: json['icon'] as String? ?? '💡',
      text: json['text'] as String,
      styles:
          (json['styles'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      backgroundColor: json['backgroundColor'] as String?,
    );

Map<String, dynamic> _$$CalloutContentImplToJson(
  _$CalloutContentImpl instance,
) => <String, dynamic>{
  'icon': instance.icon,
  'text': instance.text,
  'styles': instance.styles,
  'backgroundColor': instance.backgroundColor,
};
