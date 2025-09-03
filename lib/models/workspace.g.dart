// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WorkspaceImpl _$$WorkspaceImplFromJson(Map<String, dynamic> json) =>
    _$WorkspaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String? ?? '📝',
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      settings: json['settings'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$WorkspaceImplToJson(_$WorkspaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'settings': instance.settings,
    };

_$WorkspaceMemberImpl _$$WorkspaceMemberImplFromJson(
  Map<String, dynamic> json,
) => _$WorkspaceMemberImpl(
  id: json['id'] as String,
  workspaceId: json['workspaceId'] as String,
  userId: json['userId'] as String,
  role: json['role'] as String? ?? 'member',
  joinedAt: DateTime.parse(json['joinedAt'] as String),
  userEmail: json['userEmail'] as String?,
  userName: json['userName'] as String?,
);

Map<String, dynamic> _$$WorkspaceMemberImplToJson(
  _$WorkspaceMemberImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'workspaceId': instance.workspaceId,
  'userId': instance.userId,
  'role': instance.role,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'userEmail': instance.userEmail,
  'userName': instance.userName,
};
