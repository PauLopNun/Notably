// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Workspace _$WorkspaceFromJson(Map<String, dynamic> json) {
  return _Workspace.fromJson(json);
}

/// @nodoc
mixin _$Workspace {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get settings => throw _privateConstructorUsedError;

  /// Serializes this Workspace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workspace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceCopyWith<Workspace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceCopyWith<$Res> {
  factory $WorkspaceCopyWith(Workspace value, $Res Function(Workspace) then) =
      _$WorkspaceCopyWithImpl<$Res, Workspace>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String icon,
    String ownerId,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic> settings,
  });
}

/// @nodoc
class _$WorkspaceCopyWithImpl<$Res, $Val extends Workspace>
    implements $WorkspaceCopyWith<$Res> {
  _$WorkspaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workspace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = null,
    Object? ownerId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? settings = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            settings: null == settings
                ? _value.settings
                : settings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkspaceImplCopyWith<$Res>
    implements $WorkspaceCopyWith<$Res> {
  factory _$$WorkspaceImplCopyWith(
    _$WorkspaceImpl value,
    $Res Function(_$WorkspaceImpl) then,
  ) = __$$WorkspaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String icon,
    String ownerId,
    DateTime createdAt,
    DateTime updatedAt,
    Map<String, dynamic> settings,
  });
}

/// @nodoc
class __$$WorkspaceImplCopyWithImpl<$Res>
    extends _$WorkspaceCopyWithImpl<$Res, _$WorkspaceImpl>
    implements _$$WorkspaceImplCopyWith<$Res> {
  __$$WorkspaceImplCopyWithImpl(
    _$WorkspaceImpl _value,
    $Res Function(_$WorkspaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Workspace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? icon = null,
    Object? ownerId = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? settings = null,
  }) {
    return _then(
      _$WorkspaceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        settings: null == settings
            ? _value._settings
            : settings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceImpl implements _Workspace {
  const _$WorkspaceImpl({
    required this.id,
    required this.name,
    this.description,
    this.icon = '📝',
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    final Map<String, dynamic> settings = const {},
  }) : _settings = settings;

  factory _$WorkspaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  @JsonKey()
  final String icon;
  @override
  final String ownerId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final Map<String, dynamic> _settings;
  @override
  @JsonKey()
  Map<String, dynamic> get settings {
    if (_settings is EqualUnmodifiableMapView) return _settings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_settings);
  }

  @override
  String toString() {
    return 'Workspace(id: $id, name: $name, description: $description, icon: $icon, ownerId: $ownerId, createdAt: $createdAt, updatedAt: $updatedAt, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._settings, _settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    ownerId,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_settings),
  );

  /// Create a copy of Workspace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceImplCopyWith<_$WorkspaceImpl> get copyWith =>
      __$$WorkspaceImplCopyWithImpl<_$WorkspaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceImplToJson(this);
  }
}

abstract class _Workspace implements Workspace {
  const factory _Workspace({
    required final String id,
    required final String name,
    final String? description,
    final String icon,
    required final String ownerId,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final Map<String, dynamic> settings,
  }) = _$WorkspaceImpl;

  factory _Workspace.fromJson(Map<String, dynamic> json) =
      _$WorkspaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get icon;
  @override
  String get ownerId;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  Map<String, dynamic> get settings;

  /// Create a copy of Workspace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceImplCopyWith<_$WorkspaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceMember _$WorkspaceMemberFromJson(Map<String, dynamic> json) {
  return _WorkspaceMember.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceMember {
  String get id => throw _privateConstructorUsedError;
  String get workspaceId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;
  String? get userEmail => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceMemberCopyWith<WorkspaceMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceMemberCopyWith<$Res> {
  factory $WorkspaceMemberCopyWith(
    WorkspaceMember value,
    $Res Function(WorkspaceMember) then,
  ) = _$WorkspaceMemberCopyWithImpl<$Res, WorkspaceMember>;
  @useResult
  $Res call({
    String id,
    String workspaceId,
    String userId,
    String role,
    DateTime joinedAt,
    String? userEmail,
    String? userName,
  });
}

/// @nodoc
class _$WorkspaceMemberCopyWithImpl<$Res, $Val extends WorkspaceMember>
    implements $WorkspaceMemberCopyWith<$Res> {
  _$WorkspaceMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workspaceId = null,
    Object? userId = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? userEmail = freezed,
    Object? userName = freezed,
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
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userEmail: freezed == userEmail
                ? _value.userEmail
                : userEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            userName: freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkspaceMemberImplCopyWith<$Res>
    implements $WorkspaceMemberCopyWith<$Res> {
  factory _$$WorkspaceMemberImplCopyWith(
    _$WorkspaceMemberImpl value,
    $Res Function(_$WorkspaceMemberImpl) then,
  ) = __$$WorkspaceMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String workspaceId,
    String userId,
    String role,
    DateTime joinedAt,
    String? userEmail,
    String? userName,
  });
}

/// @nodoc
class __$$WorkspaceMemberImplCopyWithImpl<$Res>
    extends _$WorkspaceMemberCopyWithImpl<$Res, _$WorkspaceMemberImpl>
    implements _$$WorkspaceMemberImplCopyWith<$Res> {
  __$$WorkspaceMemberImplCopyWithImpl(
    _$WorkspaceMemberImpl _value,
    $Res Function(_$WorkspaceMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkspaceMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workspaceId = null,
    Object? userId = null,
    Object? role = null,
    Object? joinedAt = null,
    Object? userEmail = freezed,
    Object? userName = freezed,
  }) {
    return _then(
      _$WorkspaceMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        workspaceId: null == workspaceId
            ? _value.workspaceId
            : workspaceId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userEmail: freezed == userEmail
            ? _value.userEmail
            : userEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        userName: freezed == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceMemberImpl implements _WorkspaceMember {
  const _$WorkspaceMemberImpl({
    required this.id,
    required this.workspaceId,
    required this.userId,
    this.role = 'member',
    required this.joinedAt,
    this.userEmail,
    this.userName,
  });

  factory _$WorkspaceMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceMemberImplFromJson(json);

  @override
  final String id;
  @override
  final String workspaceId;
  @override
  final String userId;
  @override
  @JsonKey()
  final String role;
  @override
  final DateTime joinedAt;
  @override
  final String? userEmail;
  @override
  final String? userName;

  @override
  String toString() {
    return 'WorkspaceMember(id: $id, workspaceId: $workspaceId, userId: $userId, role: $role, joinedAt: $joinedAt, userEmail: $userEmail, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workspaceId, workspaceId) ||
                other.workspaceId == workspaceId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.userEmail, userEmail) ||
                other.userEmail == userEmail) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    workspaceId,
    userId,
    role,
    joinedAt,
    userEmail,
    userName,
  );

  /// Create a copy of WorkspaceMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceMemberImplCopyWith<_$WorkspaceMemberImpl> get copyWith =>
      __$$WorkspaceMemberImplCopyWithImpl<_$WorkspaceMemberImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceMemberImplToJson(this);
  }
}

abstract class _WorkspaceMember implements WorkspaceMember {
  const factory _WorkspaceMember({
    required final String id,
    required final String workspaceId,
    required final String userId,
    final String role,
    required final DateTime joinedAt,
    final String? userEmail,
    final String? userName,
  }) = _$WorkspaceMemberImpl;

  factory _WorkspaceMember.fromJson(Map<String, dynamic> json) =
      _$WorkspaceMemberImpl.fromJson;

  @override
  String get id;
  @override
  String get workspaceId;
  @override
  String get userId;
  @override
  String get role;
  @override
  DateTime get joinedAt;
  @override
  String? get userEmail;
  @override
  String? get userName;

  /// Create a copy of WorkspaceMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceMemberImplCopyWith<_$WorkspaceMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
