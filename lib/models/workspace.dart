import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace.freezed.dart';
part 'workspace.g.dart';

// Workspace role enum
enum WorkspaceRole {
  owner('owner'),
  admin('admin'),
  member('member'),
  viewer('viewer');

  const WorkspaceRole(this.value);
  final String value;

  static WorkspaceRole fromString(String value) {
    return WorkspaceRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WorkspaceRole.member,
    );
  }

  bool canEdit() => [owner, admin, member].contains(this);
  bool canAdmin() => [owner, admin].contains(this);
  bool canManageMembers() => [owner, admin].contains(this);
  bool canDelete() => this == owner;
}

@freezed
class Workspace with _$Workspace {

  const factory Workspace({
    required String id,
    required String name,
    String? description,
    @Default('📝') String icon,
    required String ownerId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default({}) Map<String, dynamic> settings,
  }) = _Workspace;

  factory Workspace.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceFromJson(json);

  factory Workspace.fromMap(Map<String, dynamic> map) {
    return Workspace(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'],
      icon: map['icon'] ?? '📝',
      ownerId: map['owner_id'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'settings': settings,
    };
  }
}

@freezed
class WorkspaceMember with _$WorkspaceMember {
  const factory WorkspaceMember({
    required String id,
    required String workspaceId,
    required String userId,
    @Default('member') String role,
    required DateTime joinedAt,
    String? userEmail,
    String? userName,
  }) = _WorkspaceMember;

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMemberFromJson(json);

  factory WorkspaceMember.fromMap(Map<String, dynamic> map) {
    return WorkspaceMember(
      id: map['id'].toString(),
      workspaceId: map['workspace_id'].toString(),
      userId: map['user_id'].toString(),
      role: map['role'] ?? 'member',
      joinedAt: DateTime.parse(map['joined_at']),
      userEmail: map['user_email'],
      userName: map['user_name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'user_id': userId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

