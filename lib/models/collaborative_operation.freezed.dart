// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collaborative_operation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CollaborativeOperation _$CollaborativeOperationFromJson(
  Map<String, dynamic> json,
) {
  return _CollaborativeOperation.fromJson(json);
}

/// @nodoc
mixin _$CollaborativeOperation {
  String get id => throw _privateConstructorUsedError;
  String get documentId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  OperationType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int? get position => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;

  /// Serializes this CollaborativeOperation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CollaborativeOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CollaborativeOperationCopyWith<CollaborativeOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CollaborativeOperationCopyWith<$Res> {
  factory $CollaborativeOperationCopyWith(
    CollaborativeOperation value,
    $Res Function(CollaborativeOperation) then,
  ) = _$CollaborativeOperationCopyWithImpl<$Res, CollaborativeOperation>;
  @useResult
  $Res call({
    String id,
    String documentId,
    String userId,
    String userName,
    OperationType type,
    Map<String, dynamic> data,
    DateTime timestamp,
    int? position,
    String? content,
  });
}

/// @nodoc
class _$CollaborativeOperationCopyWithImpl<
  $Res,
  $Val extends CollaborativeOperation
>
    implements $CollaborativeOperationCopyWith<$Res> {
  _$CollaborativeOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CollaborativeOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentId = null,
    Object? userId = null,
    Object? userName = null,
    Object? type = null,
    Object? data = null,
    Object? timestamp = null,
    Object? position = freezed,
    Object? content = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            documentId: null == documentId
                ? _value.documentId
                : documentId // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as OperationType,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int?,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CollaborativeOperationImplCopyWith<$Res>
    implements $CollaborativeOperationCopyWith<$Res> {
  factory _$$CollaborativeOperationImplCopyWith(
    _$CollaborativeOperationImpl value,
    $Res Function(_$CollaborativeOperationImpl) then,
  ) = __$$CollaborativeOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String documentId,
    String userId,
    String userName,
    OperationType type,
    Map<String, dynamic> data,
    DateTime timestamp,
    int? position,
    String? content,
  });
}

/// @nodoc
class __$$CollaborativeOperationImplCopyWithImpl<$Res>
    extends
        _$CollaborativeOperationCopyWithImpl<$Res, _$CollaborativeOperationImpl>
    implements _$$CollaborativeOperationImplCopyWith<$Res> {
  __$$CollaborativeOperationImplCopyWithImpl(
    _$CollaborativeOperationImpl _value,
    $Res Function(_$CollaborativeOperationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CollaborativeOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentId = null,
    Object? userId = null,
    Object? userName = null,
    Object? type = null,
    Object? data = null,
    Object? timestamp = null,
    Object? position = freezed,
    Object? content = freezed,
  }) {
    return _then(
      _$CollaborativeOperationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        documentId: null == documentId
            ? _value.documentId
            : documentId // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as OperationType,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int?,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CollaborativeOperationImpl
    with DiagnosticableTreeMixin
    implements _CollaborativeOperation {
  const _$CollaborativeOperationImpl({
    required this.id,
    required this.documentId,
    required this.userId,
    required this.userName,
    required this.type,
    required final Map<String, dynamic> data,
    required this.timestamp,
    this.position,
    this.content,
  }) : _data = data;

  factory _$CollaborativeOperationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CollaborativeOperationImplFromJson(json);

  @override
  final String id;
  @override
  final String documentId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final OperationType type;
  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final DateTime timestamp;
  @override
  final int? position;
  @override
  final String? content;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CollaborativeOperation(id: $id, documentId: $documentId, userId: $userId, userName: $userName, type: $type, data: $data, timestamp: $timestamp, position: $position, content: $content)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CollaborativeOperation'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('documentId', documentId))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('data', data))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('content', content));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CollaborativeOperationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentId, documentId) ||
                other.documentId == documentId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.content, content) || other.content == content));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    documentId,
    userId,
    userName,
    type,
    const DeepCollectionEquality().hash(_data),
    timestamp,
    position,
    content,
  );

  /// Create a copy of CollaborativeOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CollaborativeOperationImplCopyWith<_$CollaborativeOperationImpl>
  get copyWith =>
      __$$CollaborativeOperationImplCopyWithImpl<_$CollaborativeOperationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CollaborativeOperationImplToJson(this);
  }
}

abstract class _CollaborativeOperation implements CollaborativeOperation {
  const factory _CollaborativeOperation({
    required final String id,
    required final String documentId,
    required final String userId,
    required final String userName,
    required final OperationType type,
    required final Map<String, dynamic> data,
    required final DateTime timestamp,
    final int? position,
    final String? content,
  }) = _$CollaborativeOperationImpl;

  factory _CollaborativeOperation.fromJson(Map<String, dynamic> json) =
      _$CollaborativeOperationImpl.fromJson;

  @override
  String get id;
  @override
  String get documentId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  OperationType get type;
  @override
  Map<String, dynamic> get data;
  @override
  DateTime get timestamp;
  @override
  int? get position;
  @override
  String? get content;

  /// Create a copy of CollaborativeOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CollaborativeOperationImplCopyWith<_$CollaborativeOperationImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CursorPosition _$CursorPositionFromJson(Map<String, dynamic> json) {
  return _CursorPosition.fromJson(json);
}

/// @nodoc
mixin _$CursorPosition {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  int get selection => throw _privateConstructorUsedError;
  String get color => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this CursorPosition to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CursorPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CursorPositionCopyWith<CursorPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CursorPositionCopyWith<$Res> {
  factory $CursorPositionCopyWith(
    CursorPosition value,
    $Res Function(CursorPosition) then,
  ) = _$CursorPositionCopyWithImpl<$Res, CursorPosition>;
  @useResult
  $Res call({
    String userId,
    String userName,
    int position,
    int selection,
    String color,
    DateTime timestamp,
  });
}

/// @nodoc
class _$CursorPositionCopyWithImpl<$Res, $Val extends CursorPosition>
    implements $CursorPositionCopyWith<$Res> {
  _$CursorPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CursorPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? position = null,
    Object? selection = null,
    Object? color = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            selection: null == selection
                ? _value.selection
                : selection // ignore: cast_nullable_to_non_nullable
                      as int,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CursorPositionImplCopyWith<$Res>
    implements $CursorPositionCopyWith<$Res> {
  factory _$$CursorPositionImplCopyWith(
    _$CursorPositionImpl value,
    $Res Function(_$CursorPositionImpl) then,
  ) = __$$CursorPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    int position,
    int selection,
    String color,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$CursorPositionImplCopyWithImpl<$Res>
    extends _$CursorPositionCopyWithImpl<$Res, _$CursorPositionImpl>
    implements _$$CursorPositionImplCopyWith<$Res> {
  __$$CursorPositionImplCopyWithImpl(
    _$CursorPositionImpl _value,
    $Res Function(_$CursorPositionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CursorPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? position = null,
    Object? selection = null,
    Object? color = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$CursorPositionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        selection: null == selection
            ? _value.selection
            : selection // ignore: cast_nullable_to_non_nullable
                  as int,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CursorPositionImpl
    with DiagnosticableTreeMixin
    implements _CursorPosition {
  const _$CursorPositionImpl({
    required this.userId,
    required this.userName,
    required this.position,
    required this.selection,
    required this.color,
    required this.timestamp,
  });

  factory _$CursorPositionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CursorPositionImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final int position;
  @override
  final int selection;
  @override
  final String color;
  @override
  final DateTime timestamp;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CursorPosition(userId: $userId, userName: $userName, position: $position, selection: $selection, color: $color, timestamp: $timestamp)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CursorPosition'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('position', position))
      ..add(DiagnosticsProperty('selection', selection))
      ..add(DiagnosticsProperty('color', color))
      ..add(DiagnosticsProperty('timestamp', timestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CursorPositionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.selection, selection) ||
                other.selection == selection) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    position,
    selection,
    color,
    timestamp,
  );

  /// Create a copy of CursorPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CursorPositionImplCopyWith<_$CursorPositionImpl> get copyWith =>
      __$$CursorPositionImplCopyWithImpl<_$CursorPositionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CursorPositionImplToJson(this);
  }
}

abstract class _CursorPosition implements CursorPosition {
  const factory _CursorPosition({
    required final String userId,
    required final String userName,
    required final int position,
    required final int selection,
    required final String color,
    required final DateTime timestamp,
  }) = _$CursorPositionImpl;

  factory _CursorPosition.fromJson(Map<String, dynamic> json) =
      _$CursorPositionImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  int get position;
  @override
  int get selection;
  @override
  String get color;
  @override
  DateTime get timestamp;

  /// Create a copy of CursorPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CursorPositionImplCopyWith<_$CursorPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
