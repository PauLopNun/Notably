// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PageTemplateImpl _$$PageTemplateImplFromJson(Map<String, dynamic> json) =>
    _$PageTemplateImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      icon: json['icon'] as String?,
      coverImage: json['coverImage'] as String?,
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => TemplateBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      properties:
          (json['properties'] as List<dynamic>?)
              ?.map((e) => TemplateProperty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isPublic: json['isPublic'] as bool? ?? false,
      isOfficial: json['isOfficial'] as bool? ?? false,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
    );

Map<String, dynamic> _$$PageTemplateImplToJson(_$PageTemplateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'icon': instance.icon,
      'coverImage': instance.coverImage,
      'blocks': instance.blocks,
      'properties': instance.properties,
      'isPublic': instance.isPublic,
      'isOfficial': instance.isOfficial,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'usageCount': instance.usageCount,
      'tags': instance.tags,
    };

_$TemplateBlockImpl _$$TemplateBlockImplFromJson(Map<String, dynamic> json) =>
    _$TemplateBlockImpl(
      id: json['id'] as String,
      parentBlockId: json['parentBlockId'] as String?,
      type: $enumDecode(_$BlockTypeEnumMap, json['type']),
      content: json['content'] as Map<String, dynamic>? ?? const {},
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
      position: (json['position'] as num?)?.toInt() ?? 0,
      isPlaceholder: json['isPlaceholder'] as bool? ?? false,
      placeholderText: json['placeholderText'] as String?,
    );

Map<String, dynamic> _$$TemplateBlockImplToJson(_$TemplateBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentBlockId': instance.parentBlockId,
      'type': _$BlockTypeEnumMap[instance.type]!,
      'content': instance.content,
      'properties': instance.properties,
      'position': instance.position,
      'isPlaceholder': instance.isPlaceholder,
      'placeholderText': instance.placeholderText,
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

_$TemplatePropertyImpl _$$TemplatePropertyImplFromJson(
  Map<String, dynamic> json,
) => _$TemplatePropertyImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  type: $enumDecode(_$TemplatePropertyTypeEnumMap, json['type']),
  options: json['options'] as Map<String, dynamic>? ?? const {},
  isRequired: json['isRequired'] as bool? ?? false,
  defaultValue: json['defaultValue'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$$TemplatePropertyImplToJson(
  _$TemplatePropertyImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$TemplatePropertyTypeEnumMap[instance.type]!,
  'options': instance.options,
  'isRequired': instance.isRequired,
  'defaultValue': instance.defaultValue,
  'description': instance.description,
};

const _$TemplatePropertyTypeEnumMap = {
  TemplatePropertyType.text: 'text',
  TemplatePropertyType.number: 'number',
  TemplatePropertyType.date: 'date',
  TemplatePropertyType.select: 'select',
  TemplatePropertyType.multiSelect: 'multiSelect',
  TemplatePropertyType.checkbox: 'checkbox',
  TemplatePropertyType.url: 'url',
  TemplatePropertyType.email: 'email',
  TemplatePropertyType.person: 'person',
  TemplatePropertyType.file: 'file',
};
