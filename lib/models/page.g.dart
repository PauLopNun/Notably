// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotionPageImpl _$$NotionPageImplFromJson(Map<String, dynamic> json) =>
    _$NotionPageImpl(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      coverImage: json['coverImage'] as String?,
      blocks:
          (json['blocks'] as List<dynamic>?)
              ?.map((e) => PageBlock.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      position: (json['position'] as num?)?.toInt() ?? 0,
      isTemplate: json['isTemplate'] as bool? ?? false,
      isPublic: json['isPublic'] as bool? ?? false,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastEditedBy: json['lastEditedBy'] as String?,
      properties: json['properties'] as Map<String, dynamic>? ?? const {},
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => NotionPage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$NotionPageImplToJson(_$NotionPageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workspaceId': instance.workspaceId,
      'parentId': instance.parentId,
      'title': instance.title,
      'icon': instance.icon,
      'coverImage': instance.coverImage,
      'blocks': instance.blocks,
      'position': instance.position,
      'isTemplate': instance.isTemplate,
      'isPublic': instance.isPublic,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastEditedBy': instance.lastEditedBy,
      'properties': instance.properties,
      'children': instance.children,
    };

_$PagePermissionImpl _$$PagePermissionImplFromJson(Map<String, dynamic> json) =>
    _$PagePermissionImpl(
      id: json['id'] as String,
      pageId: json['pageId'] as String,
      userId: json['userId'] as String?,
      permissionType: json['permissionType'] as String? ?? 'view',
      grantedBy: json['grantedBy'] as String?,
      grantedAt: DateTime.parse(json['grantedAt'] as String),
    );

Map<String, dynamic> _$$PagePermissionImplToJson(
  _$PagePermissionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'pageId': instance.pageId,
  'userId': instance.userId,
  'permissionType': instance.permissionType,
  'grantedBy': instance.grantedBy,
  'grantedAt': instance.grantedAt.toIso8601String(),
};
