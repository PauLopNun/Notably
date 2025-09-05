import 'package:freezed_annotation/freezed_annotation.dart';
import 'block.dart';

part 'page.freezed.dart';
part 'page.g.dart';

@freezed
class NotionPage with _$NotionPage {
  const factory NotionPage({
    required String id,
    required String workspaceId,
    String? parentId,
    required String title,
    String? icon,
    String? coverImage,
    @Default([]) List<PageBlock> blocks,
    @Default(0) int position,
    @Default(false) bool isTemplate,
    @Default(false) bool isPublic,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lastEditedBy,
    @Default({}) Map<String, dynamic> properties,
    @Default([]) List<NotionPage> children,
  }) = _NotionPage;

  factory NotionPage.fromJson(Map<String, dynamic> json) =>
      _$NotionPageFromJson(json);

  factory NotionPage.fromMap(Map<String, dynamic> map) {
    return NotionPage(
      id: map['id'].toString(),
      workspaceId: map['workspace_id'].toString(),
      parentId: map['parent_id']?.toString(),
      title: map['title'] ?? 'Untitled',
      icon: map['icon'],
      coverImage: map['cover_image'],
      blocks: [], // Blocks loaded separately
      position: map['position'] ?? 0,
      isTemplate: map['is_template'] ?? false,
      isPublic: map['is_public'] ?? false,
      createdBy: map['created_by'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      lastEditedBy: map['last_edited_by']?.toString(),
      properties: Map<String, dynamic>.from(map['properties'] ?? {}),
    );
  }

}

@freezed
class PagePermission with _$PagePermission {
  const factory PagePermission({
    required String id,
    required String pageId,
    String? userId,
    @Default('view') String permissionType,
    String? grantedBy,
    required DateTime grantedAt,
  }) = _PagePermission;

  factory PagePermission.fromJson(Map<String, dynamic> json) =>
      _$PagePermissionFromJson(json);

  factory PagePermission.fromMap(Map<String, dynamic> map) {
    return PagePermission(
      id: map['id'].toString(),
      pageId: map['page_id'].toString(),
      userId: map['user_id']?.toString(),
      permissionType: map['permission_type'] ?? 'view',
      grantedBy: map['granted_by']?.toString(),
      grantedAt: DateTime.parse(map['granted_at']),
    );
  }

}

enum PagePermissionType {
  owner('owner'),
  edit('edit'),
  comment('comment'),
  view('view');

  const PagePermissionType(this.value);
  final String value;

  static PagePermissionType fromString(String value) {
    return PagePermissionType.values.firstWhere(
      (permission) => permission.value == value,
      orElse: () => PagePermissionType.view,
    );
  }

  bool canEdit() => [owner, edit].contains(this);
  bool canComment() => [owner, edit, comment].contains(this);
  bool canView() => PagePermissionType.values.contains(this);
  bool canManage() => this == owner;
}