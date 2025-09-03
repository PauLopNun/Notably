// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'page.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotionPage _$NotionPageFromJson(Map<String, dynamic> json) {
  return _NotionPage.fromJson(json);
}

/// @nodoc
mixin _$NotionPage {
  String get id => throw _privateConstructorUsedError;
  String get workspaceId => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;
  List<PageBlock> get blocks => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  bool get isTemplate => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get lastEditedBy => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  List<NotionPage> get children => throw _privateConstructorUsedError;

  /// Serializes this NotionPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotionPageCopyWith<NotionPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotionPageCopyWith<$Res> {
  factory $NotionPageCopyWith(
    NotionPage value,
    $Res Function(NotionPage) then,
  ) = _$NotionPageCopyWithImpl<$Res, NotionPage>;
  @useResult
  $Res call({
    String id,
    String workspaceId,
    String? parentId,
    String title,
    String? icon,
    String? coverImage,
    List<PageBlock> blocks,
    int position,
    bool isTemplate,
    bool isPublic,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? lastEditedBy,
    Map<String, dynamic> properties,
    List<NotionPage> children,
  });
}

/// @nodoc
class _$NotionPageCopyWithImpl<$Res, $Val extends NotionPage>
    implements $NotionPageCopyWith<$Res> {
  _$NotionPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotionPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workspaceId = null,
    Object? parentId = freezed,
    Object? title = null,
    Object? icon = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? position = null,
    Object? isTemplate = null,
    Object? isPublic = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastEditedBy = freezed,
    Object? properties = null,
    Object? children = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            workspaceId: null == workspaceId
                ? _value.workspaceId
                : workspaceId // ignore: cast_nullable_to_non_nullable
                      as String,
            parentId: freezed == parentId
                ? _value.parentId
                : parentId // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImage: freezed == coverImage
                ? _value.coverImage
                : coverImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            blocks: null == blocks
                ? _value.blocks
                : blocks // ignore: cast_nullable_to_non_nullable
                      as List<PageBlock>,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            isTemplate: null == isTemplate
                ? _value.isTemplate
                : isTemplate // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastEditedBy: freezed == lastEditedBy
                ? _value.lastEditedBy
                : lastEditedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            properties: null == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            children: null == children
                ? _value.children
                : children // ignore: cast_nullable_to_non_nullable
                      as List<NotionPage>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotionPageImplCopyWith<$Res>
    implements $NotionPageCopyWith<$Res> {
  factory _$$NotionPageImplCopyWith(
    _$NotionPageImpl value,
    $Res Function(_$NotionPageImpl) then,
  ) = __$$NotionPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String workspaceId,
    String? parentId,
    String title,
    String? icon,
    String? coverImage,
    List<PageBlock> blocks,
    int position,
    bool isTemplate,
    bool isPublic,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    String? lastEditedBy,
    Map<String, dynamic> properties,
    List<NotionPage> children,
  });
}

/// @nodoc
class __$$NotionPageImplCopyWithImpl<$Res>
    extends _$NotionPageCopyWithImpl<$Res, _$NotionPageImpl>
    implements _$$NotionPageImplCopyWith<$Res> {
  __$$NotionPageImplCopyWithImpl(
    _$NotionPageImpl _value,
    $Res Function(_$NotionPageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotionPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workspaceId = null,
    Object? parentId = freezed,
    Object? title = null,
    Object? icon = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? position = null,
    Object? isTemplate = null,
    Object? isPublic = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? lastEditedBy = freezed,
    Object? properties = null,
    Object? children = null,
  }) {
    return _then(
      _$NotionPageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        workspaceId: null == workspaceId
            ? _value.workspaceId
            : workspaceId // ignore: cast_nullable_to_non_nullable
                  as String,
        parentId: freezed == parentId
            ? _value.parentId
            : parentId // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImage: freezed == coverImage
            ? _value.coverImage
            : coverImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        blocks: null == blocks
            ? _value._blocks
            : blocks // ignore: cast_nullable_to_non_nullable
                  as List<PageBlock>,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        isTemplate: null == isTemplate
            ? _value.isTemplate
            : isTemplate // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastEditedBy: freezed == lastEditedBy
            ? _value.lastEditedBy
            : lastEditedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        properties: null == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        children: null == children
            ? _value._children
            : children // ignore: cast_nullable_to_non_nullable
                  as List<NotionPage>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotionPageImpl implements _NotionPage {
  const _$NotionPageImpl({
    required this.id,
    required this.workspaceId,
    this.parentId,
    required this.title,
    this.icon,
    this.coverImage,
    final List<PageBlock> blocks = const [],
    this.position = 0,
    this.isTemplate = false,
    this.isPublic = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.lastEditedBy,
    final Map<String, dynamic> properties = const {},
    final List<NotionPage> children = const [],
  }) : _blocks = blocks,
       _properties = properties,
       _children = children;

  factory _$NotionPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotionPageImplFromJson(json);

  @override
  final String id;
  @override
  final String workspaceId;
  @override
  final String? parentId;
  @override
  final String title;
  @override
  final String? icon;
  @override
  final String? coverImage;
  final List<PageBlock> _blocks;
  @override
  @JsonKey()
  List<PageBlock> get blocks {
    if (_blocks is EqualUnmodifiableListView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blocks);
  }

  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey()
  final bool isTemplate;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? lastEditedBy;
  final Map<String, dynamic> _properties;
  @override
  @JsonKey()
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  final List<NotionPage> _children;
  @override
  @JsonKey()
  List<NotionPage> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'NotionPage(id: $id, workspaceId: $workspaceId, parentId: $parentId, title: $title, icon: $icon, coverImage: $coverImage, blocks: $blocks, position: $position, isTemplate: $isTemplate, isPublic: $isPublic, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, lastEditedBy: $lastEditedBy, properties: $properties, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotionPageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workspaceId, workspaceId) ||
                other.workspaceId == workspaceId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.isTemplate, isTemplate) ||
                other.isTemplate == isTemplate) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastEditedBy, lastEditedBy) ||
                other.lastEditedBy == lastEditedBy) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workspaceId,
    parentId,
    title,
    icon,
    coverImage,
    const DeepCollectionEquality().hash(_blocks),
    position,
    isTemplate,
    isPublic,
    createdBy,
    createdAt,
    updatedAt,
    lastEditedBy,
    const DeepCollectionEquality().hash(_properties),
    const DeepCollectionEquality().hash(_children),
  );

  /// Create a copy of NotionPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotionPageImplCopyWith<_$NotionPageImpl> get copyWith =>
      __$$NotionPageImplCopyWithImpl<_$NotionPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotionPageImplToJson(this);
  }
}

abstract class _NotionPage implements NotionPage {
  const factory _NotionPage({
    required final String id,
    required final String workspaceId,
    final String? parentId,
    required final String title,
    final String? icon,
    final String? coverImage,
    final List<PageBlock> blocks,
    final int position,
    final bool isTemplate,
    final bool isPublic,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final String? lastEditedBy,
    final Map<String, dynamic> properties,
    final List<NotionPage> children,
  }) = _$NotionPageImpl;

  factory _NotionPage.fromJson(Map<String, dynamic> json) =
      _$NotionPageImpl.fromJson;

  @override
  String get id;
  @override
  String get workspaceId;
  @override
  String? get parentId;
  @override
  String get title;
  @override
  String? get icon;
  @override
  String? get coverImage;
  @override
  List<PageBlock> get blocks;
  @override
  int get position;
  @override
  bool get isTemplate;
  @override
  bool get isPublic;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get lastEditedBy;
  @override
  Map<String, dynamic> get properties;
  @override
  List<NotionPage> get children;

  /// Create a copy of NotionPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotionPageImplCopyWith<_$NotionPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PagePermission _$PagePermissionFromJson(Map<String, dynamic> json) {
  return _PagePermission.fromJson(json);
}

/// @nodoc
mixin _$PagePermission {
  String get id => throw _privateConstructorUsedError;
  String get pageId => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String get permissionType => throw _privateConstructorUsedError;
  String? get grantedBy => throw _privateConstructorUsedError;
  DateTime get grantedAt => throw _privateConstructorUsedError;

  /// Serializes this PagePermission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PagePermission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PagePermissionCopyWith<PagePermission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PagePermissionCopyWith<$Res> {
  factory $PagePermissionCopyWith(
    PagePermission value,
    $Res Function(PagePermission) then,
  ) = _$PagePermissionCopyWithImpl<$Res, PagePermission>;
  @useResult
  $Res call({
    String id,
    String pageId,
    String? userId,
    String permissionType,
    String? grantedBy,
    DateTime grantedAt,
  });
}

/// @nodoc
class _$PagePermissionCopyWithImpl<$Res, $Val extends PagePermission>
    implements $PagePermissionCopyWith<$Res> {
  _$PagePermissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PagePermission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? userId = freezed,
    Object? permissionType = null,
    Object? grantedBy = freezed,
    Object? grantedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pageId: null == pageId
                ? _value.pageId
                : pageId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            permissionType: null == permissionType
                ? _value.permissionType
                : permissionType // ignore: cast_nullable_to_non_nullable
                      as String,
            grantedBy: freezed == grantedBy
                ? _value.grantedBy
                : grantedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            grantedAt: null == grantedAt
                ? _value.grantedAt
                : grantedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PagePermissionImplCopyWith<$Res>
    implements $PagePermissionCopyWith<$Res> {
  factory _$$PagePermissionImplCopyWith(
    _$PagePermissionImpl value,
    $Res Function(_$PagePermissionImpl) then,
  ) = __$$PagePermissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pageId,
    String? userId,
    String permissionType,
    String? grantedBy,
    DateTime grantedAt,
  });
}

/// @nodoc
class __$$PagePermissionImplCopyWithImpl<$Res>
    extends _$PagePermissionCopyWithImpl<$Res, _$PagePermissionImpl>
    implements _$$PagePermissionImplCopyWith<$Res> {
  __$$PagePermissionImplCopyWithImpl(
    _$PagePermissionImpl _value,
    $Res Function(_$PagePermissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PagePermission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? userId = freezed,
    Object? permissionType = null,
    Object? grantedBy = freezed,
    Object? grantedAt = null,
  }) {
    return _then(
      _$PagePermissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pageId: null == pageId
            ? _value.pageId
            : pageId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        permissionType: null == permissionType
            ? _value.permissionType
            : permissionType // ignore: cast_nullable_to_non_nullable
                  as String,
        grantedBy: freezed == grantedBy
            ? _value.grantedBy
            : grantedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        grantedAt: null == grantedAt
            ? _value.grantedAt
            : grantedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PagePermissionImpl implements _PagePermission {
  const _$PagePermissionImpl({
    required this.id,
    required this.pageId,
    this.userId,
    this.permissionType = 'view',
    this.grantedBy,
    required this.grantedAt,
  });

  factory _$PagePermissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PagePermissionImplFromJson(json);

  @override
  final String id;
  @override
  final String pageId;
  @override
  final String? userId;
  @override
  @JsonKey()
  final String permissionType;
  @override
  final String? grantedBy;
  @override
  final DateTime grantedAt;

  @override
  String toString() {
    return 'PagePermission(id: $id, pageId: $pageId, userId: $userId, permissionType: $permissionType, grantedBy: $grantedBy, grantedAt: $grantedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PagePermissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.permissionType, permissionType) ||
                other.permissionType == permissionType) &&
            (identical(other.grantedBy, grantedBy) ||
                other.grantedBy == grantedBy) &&
            (identical(other.grantedAt, grantedAt) ||
                other.grantedAt == grantedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pageId,
    userId,
    permissionType,
    grantedBy,
    grantedAt,
  );

  /// Create a copy of PagePermission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PagePermissionImplCopyWith<_$PagePermissionImpl> get copyWith =>
      __$$PagePermissionImplCopyWithImpl<_$PagePermissionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PagePermissionImplToJson(this);
  }
}

abstract class _PagePermission implements PagePermission {
  const factory _PagePermission({
    required final String id,
    required final String pageId,
    final String? userId,
    final String permissionType,
    final String? grantedBy,
    required final DateTime grantedAt,
  }) = _$PagePermissionImpl;

  factory _PagePermission.fromJson(Map<String, dynamic> json) =
      _$PagePermissionImpl.fromJson;

  @override
  String get id;
  @override
  String get pageId;
  @override
  String? get userId;
  @override
  String get permissionType;
  @override
  String? get grantedBy;
  @override
  DateTime get grantedAt;

  /// Create a copy of PagePermission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PagePermissionImplCopyWith<_$PagePermissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
