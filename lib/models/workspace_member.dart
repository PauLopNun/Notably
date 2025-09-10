import 'package:equatable/equatable.dart';

enum MemberRole { owner, admin, member, guest }

enum WorkspaceRole { owner, admin, member, guest }

enum ActivityAction { created, updated, deleted, shared, archived }

class WorkspaceMember extends Equatable {
  final String id;
  final String userId;
  final String workspaceId;
  final String name;
  final String email;
  final String? avatarUrl;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime? lastActiveAt;
  final bool isActive;
  final Map<String, dynamic> permissions;

  const WorkspaceMember({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
    this.lastActiveAt,
    this.isActive = true,
    this.permissions = const {},
  });

  WorkspaceMember copyWith({
    String? id,
    String? userId,
    String? workspaceId,
    String? name,
    String? email,
    String? avatarUrl,
    MemberRole? role,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    bool? isActive,
    Map<String, dynamic>? permissions,
  }) {
    return WorkspaceMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isActive: isActive ?? this.isActive,
      permissions: permissions ?? this.permissions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workspace_id': workspaceId,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role.name,
      'joined_at': joinedAt.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_active': isActive,
      'permissions': permissions,
    };
  }

  factory WorkspaceMember.fromJson(Map<String, dynamic> json) {
    return WorkspaceMember(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workspaceId: json['workspace_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      role: MemberRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      permissions: Map<String, dynamic>.from(json['permissions'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        workspaceId,
        name,
        email,
        avatarUrl,
        role,
        joinedAt,
        lastActiveAt,
        isActive,
        permissions,
      ];
}

extension MemberRoleExtension on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return 'Member';
      case MemberRole.guest:
        return 'Guest';
    }
  }

  bool get canEdit {
    switch (this) {
      case MemberRole.owner:
      case MemberRole.admin:
      case MemberRole.member:
        return true;
      case MemberRole.guest:
        return false;
    }
  }

  bool get canInvite {
    switch (this) {
      case MemberRole.owner:
      case MemberRole.admin:
        return true;
      case MemberRole.member:
      case MemberRole.guest:
        return false;
    }
  }

  bool get canDelete {
    switch (this) {
      case MemberRole.owner:
      case MemberRole.admin:
        return true;
      case MemberRole.member:
      case MemberRole.guest:
        return false;
    }
  }
}