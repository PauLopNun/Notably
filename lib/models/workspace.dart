import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String ownerId;
  final List<String> memberIds;
  final bool isPublic;

  const Workspace({
    required this.id,
    required this.name,
    required this.description,
    this.icon = '📚',
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    this.memberIds = const [],
    this.isPublic = false,
  });

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? ownerId,
    List<String>? memberIds,
    bool? isPublic,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'icon_url': iconUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'owner_id': ownerId,
      'member_ids': memberIds,
      'is_public': isPublic,
    };
  }

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? '📚',
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      ownerId: json['owner_id'] as String,
      memberIds: (json['member_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      isPublic: json['is_public'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        iconUrl,
        createdAt,
        updatedAt,
        ownerId,
        memberIds,
        isPublic,
      ];
}