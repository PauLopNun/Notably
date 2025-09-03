// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageBlock _$PageBlockFromJson(Map<String, dynamic> json) {
  return _PageBlock.fromJson(json);
}

/// @nodoc
mixin _$PageBlock {
  String get id => throw _privateConstructorUsedError;
  String get pageId => throw _privateConstructorUsedError;
  String? get parentBlockId => throw _privateConstructorUsedError;
  BlockType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PageBlock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageBlockCopyWith<PageBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageBlockCopyWith<$Res> {
  factory $PageBlockCopyWith(PageBlock value, $Res Function(PageBlock) then) =
      _$PageBlockCopyWithImpl<$Res, PageBlock>;
  @useResult
  $Res call({
    String id,
    String pageId,
    String? parentBlockId,
    BlockType type,
    Map<String, dynamic> content,
    Map<String, dynamic> properties,
    int position,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$PageBlockCopyWithImpl<$Res, $Val extends PageBlock>
    implements $PageBlockCopyWith<$Res> {
  _$PageBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? parentBlockId = freezed,
    Object? type = null,
    Object? content = null,
    Object? properties = null,
    Object? position = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
            parentBlockId: freezed == parentBlockId
                ? _value.parentBlockId
                : parentBlockId // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as BlockType,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            properties: null == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            position: null == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageBlockImplCopyWith<$Res>
    implements $PageBlockCopyWith<$Res> {
  factory _$$PageBlockImplCopyWith(
    _$PageBlockImpl value,
    $Res Function(_$PageBlockImpl) then,
  ) = __$$PageBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String pageId,
    String? parentBlockId,
    BlockType type,
    Map<String, dynamic> content,
    Map<String, dynamic> properties,
    int position,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$PageBlockImplCopyWithImpl<$Res>
    extends _$PageBlockCopyWithImpl<$Res, _$PageBlockImpl>
    implements _$$PageBlockImplCopyWith<$Res> {
  __$$PageBlockImplCopyWithImpl(
    _$PageBlockImpl _value,
    $Res Function(_$PageBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageId = null,
    Object? parentBlockId = freezed,
    Object? type = null,
    Object? content = null,
    Object? properties = null,
    Object? position = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$PageBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pageId: null == pageId
            ? _value.pageId
            : pageId // ignore: cast_nullable_to_non_nullable
                  as String,
        parentBlockId: freezed == parentBlockId
            ? _value.parentBlockId
            : parentBlockId // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as BlockType,
        content: null == content
            ? _value._content
            : content // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        properties: null == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        position: null == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageBlockImpl implements _PageBlock {
  const _$PageBlockImpl({
    required this.id,
    required this.pageId,
    this.parentBlockId,
    required this.type,
    final Map<String, dynamic> content = const {},
    final Map<String, dynamic> properties = const {},
    this.position = 0,
    required this.createdAt,
    required this.updatedAt,
  }) : _content = content,
       _properties = properties;

  factory _$PageBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageBlockImplFromJson(json);

  @override
  final String id;
  @override
  final String pageId;
  @override
  final String? parentBlockId;
  @override
  final BlockType type;
  final Map<String, dynamic> _content;
  @override
  @JsonKey()
  Map<String, dynamic> get content {
    if (_content is EqualUnmodifiableMapView) return _content;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_content);
  }

  final Map<String, dynamic> _properties;
  @override
  @JsonKey()
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  @JsonKey()
  final int position;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PageBlock(id: $id, pageId: $pageId, parentBlockId: $parentBlockId, type: $type, content: $content, properties: $properties, position: $position, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageId, pageId) || other.pageId == pageId) &&
            (identical(other.parentBlockId, parentBlockId) ||
                other.parentBlockId == parentBlockId) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._content, _content) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pageId,
    parentBlockId,
    type,
    const DeepCollectionEquality().hash(_content),
    const DeepCollectionEquality().hash(_properties),
    position,
    createdAt,
    updatedAt,
  );

  /// Create a copy of PageBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageBlockImplCopyWith<_$PageBlockImpl> get copyWith =>
      __$$PageBlockImplCopyWithImpl<_$PageBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageBlockImplToJson(this);
  }
}

abstract class _PageBlock implements PageBlock {
  const factory _PageBlock({
    required final String id,
    required final String pageId,
    final String? parentBlockId,
    required final BlockType type,
    final Map<String, dynamic> content,
    final Map<String, dynamic> properties,
    final int position,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$PageBlockImpl;

  factory _PageBlock.fromJson(Map<String, dynamic> json) =
      _$PageBlockImpl.fromJson;

  @override
  String get id;
  @override
  String get pageId;
  @override
  String? get parentBlockId;
  @override
  BlockType get type;
  @override
  Map<String, dynamic> get content;
  @override
  Map<String, dynamic> get properties;
  @override
  int get position;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of PageBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageBlockImplCopyWith<_$PageBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TextContent _$TextContentFromJson(Map<String, dynamic> json) {
  return _TextContent.fromJson(json);
}

/// @nodoc
mixin _$TextContent {
  String get text => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get styles => throw _privateConstructorUsedError;

  /// Serializes this TextContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TextContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TextContentCopyWith<TextContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TextContentCopyWith<$Res> {
  factory $TextContentCopyWith(
    TextContent value,
    $Res Function(TextContent) then,
  ) = _$TextContentCopyWithImpl<$Res, TextContent>;
  @useResult
  $Res call({String text, List<Map<String, dynamic>> styles});
}

/// @nodoc
class _$TextContentCopyWithImpl<$Res, $Val extends TextContent>
    implements $TextContentCopyWith<$Res> {
  _$TextContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TextContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null, Object? styles = null}) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            styles: null == styles
                ? _value.styles
                : styles // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TextContentImplCopyWith<$Res>
    implements $TextContentCopyWith<$Res> {
  factory _$$TextContentImplCopyWith(
    _$TextContentImpl value,
    $Res Function(_$TextContentImpl) then,
  ) = __$$TextContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, List<Map<String, dynamic>> styles});
}

/// @nodoc
class __$$TextContentImplCopyWithImpl<$Res>
    extends _$TextContentCopyWithImpl<$Res, _$TextContentImpl>
    implements _$$TextContentImplCopyWith<$Res> {
  __$$TextContentImplCopyWithImpl(
    _$TextContentImpl _value,
    $Res Function(_$TextContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TextContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? text = null, Object? styles = null}) {
    return _then(
      _$TextContentImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        styles: null == styles
            ? _value._styles
            : styles // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TextContentImpl implements _TextContent {
  const _$TextContentImpl({
    this.text = '',
    final List<Map<String, dynamic>> styles = const [],
  }) : _styles = styles;

  factory _$TextContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TextContentImplFromJson(json);

  @override
  @JsonKey()
  final String text;
  final List<Map<String, dynamic>> _styles;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get styles {
    if (_styles is EqualUnmodifiableListView) return _styles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_styles);
  }

  @override
  String toString() {
    return 'TextContent(text: $text, styles: $styles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TextContentImpl &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._styles, _styles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    text,
    const DeepCollectionEquality().hash(_styles),
  );

  /// Create a copy of TextContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TextContentImplCopyWith<_$TextContentImpl> get copyWith =>
      __$$TextContentImplCopyWithImpl<_$TextContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TextContentImplToJson(this);
  }
}

abstract class _TextContent implements TextContent {
  const factory _TextContent({
    final String text,
    final List<Map<String, dynamic>> styles,
  }) = _$TextContentImpl;

  factory _TextContent.fromJson(Map<String, dynamic> json) =
      _$TextContentImpl.fromJson;

  @override
  String get text;
  @override
  List<Map<String, dynamic>> get styles;

  /// Create a copy of TextContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TextContentImplCopyWith<_$TextContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BlockTextStyle _$BlockTextStyleFromJson(Map<String, dynamic> json) {
  return _BlockTextStyle.fromJson(json);
}

/// @nodoc
mixin _$BlockTextStyle {
  int get start => throw _privateConstructorUsedError;
  int get end => throw _privateConstructorUsedError;
  String get type =>
      throw _privateConstructorUsedError; // 'bold', 'italic', 'underline', 'strikethrough', 'code', 'color'
  Map<String, dynamic>? get attributes => throw _privateConstructorUsedError;

  /// Serializes this BlockTextStyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BlockTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockTextStyleCopyWith<BlockTextStyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockTextStyleCopyWith<$Res> {
  factory $BlockTextStyleCopyWith(
    BlockTextStyle value,
    $Res Function(BlockTextStyle) then,
  ) = _$BlockTextStyleCopyWithImpl<$Res, BlockTextStyle>;
  @useResult
  $Res call({
    int start,
    int end,
    String type,
    Map<String, dynamic>? attributes,
  });
}

/// @nodoc
class _$BlockTextStyleCopyWithImpl<$Res, $Val extends BlockTextStyle>
    implements $BlockTextStyleCopyWith<$Res> {
  _$BlockTextStyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? type = null,
    Object? attributes = freezed,
  }) {
    return _then(
      _value.copyWith(
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as int,
            end: null == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as int,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            attributes: freezed == attributes
                ? _value.attributes
                : attributes // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BlockTextStyleImplCopyWith<$Res>
    implements $BlockTextStyleCopyWith<$Res> {
  factory _$$BlockTextStyleImplCopyWith(
    _$BlockTextStyleImpl value,
    $Res Function(_$BlockTextStyleImpl) then,
  ) = __$$BlockTextStyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int start,
    int end,
    String type,
    Map<String, dynamic>? attributes,
  });
}

/// @nodoc
class __$$BlockTextStyleImplCopyWithImpl<$Res>
    extends _$BlockTextStyleCopyWithImpl<$Res, _$BlockTextStyleImpl>
    implements _$$BlockTextStyleImplCopyWith<$Res> {
  __$$BlockTextStyleImplCopyWithImpl(
    _$BlockTextStyleImpl _value,
    $Res Function(_$BlockTextStyleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BlockTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
    Object? type = null,
    Object? attributes = freezed,
  }) {
    return _then(
      _$BlockTextStyleImpl(
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as int,
        end: null == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as int,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        attributes: freezed == attributes
            ? _value._attributes
            : attributes // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockTextStyleImpl implements _BlockTextStyle {
  const _$BlockTextStyleImpl({
    required this.start,
    required this.end,
    required this.type,
    final Map<String, dynamic>? attributes,
  }) : _attributes = attributes;

  factory _$BlockTextStyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockTextStyleImplFromJson(json);

  @override
  final int start;
  @override
  final int end;
  @override
  final String type;
  // 'bold', 'italic', 'underline', 'strikethrough', 'code', 'color'
  final Map<String, dynamic>? _attributes;
  // 'bold', 'italic', 'underline', 'strikethrough', 'code', 'color'
  @override
  Map<String, dynamic>? get attributes {
    final value = _attributes;
    if (value == null) return null;
    if (_attributes is EqualUnmodifiableMapView) return _attributes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'BlockTextStyle(start: $start, end: $end, type: $type, attributes: $attributes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockTextStyleImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(
              other._attributes,
              _attributes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    start,
    end,
    type,
    const DeepCollectionEquality().hash(_attributes),
  );

  /// Create a copy of BlockTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockTextStyleImplCopyWith<_$BlockTextStyleImpl> get copyWith =>
      __$$BlockTextStyleImplCopyWithImpl<_$BlockTextStyleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockTextStyleImplToJson(this);
  }
}

abstract class _BlockTextStyle implements BlockTextStyle {
  const factory _BlockTextStyle({
    required final int start,
    required final int end,
    required final String type,
    final Map<String, dynamic>? attributes,
  }) = _$BlockTextStyleImpl;

  factory _BlockTextStyle.fromJson(Map<String, dynamic> json) =
      _$BlockTextStyleImpl.fromJson;

  @override
  int get start;
  @override
  int get end;
  @override
  String get type; // 'bold', 'italic', 'underline', 'strikethrough', 'code', 'color'
  @override
  Map<String, dynamic>? get attributes;

  /// Create a copy of BlockTextStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockTextStyleImplCopyWith<_$BlockTextStyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TodoContent _$TodoContentFromJson(Map<String, dynamic> json) {
  return _TodoContent.fromJson(json);
}

/// @nodoc
mixin _$TodoContent {
  String get text => throw _privateConstructorUsedError;
  bool get checked => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get styles => throw _privateConstructorUsedError;

  /// Serializes this TodoContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoContentCopyWith<TodoContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoContentCopyWith<$Res> {
  factory $TodoContentCopyWith(
    TodoContent value,
    $Res Function(TodoContent) then,
  ) = _$TodoContentCopyWithImpl<$Res, TodoContent>;
  @useResult
  $Res call({String text, bool checked, List<Map<String, dynamic>> styles});
}

/// @nodoc
class _$TodoContentCopyWithImpl<$Res, $Val extends TodoContent>
    implements $TodoContentCopyWith<$Res> {
  _$TodoContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? checked = null,
    Object? styles = null,
  }) {
    return _then(
      _value.copyWith(
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            checked: null == checked
                ? _value.checked
                : checked // ignore: cast_nullable_to_non_nullable
                      as bool,
            styles: null == styles
                ? _value.styles
                : styles // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoContentImplCopyWith<$Res>
    implements $TodoContentCopyWith<$Res> {
  factory _$$TodoContentImplCopyWith(
    _$TodoContentImpl value,
    $Res Function(_$TodoContentImpl) then,
  ) = __$$TodoContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, bool checked, List<Map<String, dynamic>> styles});
}

/// @nodoc
class __$$TodoContentImplCopyWithImpl<$Res>
    extends _$TodoContentCopyWithImpl<$Res, _$TodoContentImpl>
    implements _$$TodoContentImplCopyWith<$Res> {
  __$$TodoContentImplCopyWithImpl(
    _$TodoContentImpl _value,
    $Res Function(_$TodoContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? checked = null,
    Object? styles = null,
  }) {
    return _then(
      _$TodoContentImpl(
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        checked: null == checked
            ? _value.checked
            : checked // ignore: cast_nullable_to_non_nullable
                  as bool,
        styles: null == styles
            ? _value._styles
            : styles // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodoContentImpl implements _TodoContent {
  const _$TodoContentImpl({
    this.text = '',
    this.checked = false,
    final List<Map<String, dynamic>> styles = const [],
  }) : _styles = styles;

  factory _$TodoContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodoContentImplFromJson(json);

  @override
  @JsonKey()
  final String text;
  @override
  @JsonKey()
  final bool checked;
  final List<Map<String, dynamic>> _styles;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get styles {
    if (_styles is EqualUnmodifiableListView) return _styles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_styles);
  }

  @override
  String toString() {
    return 'TodoContent(text: $text, checked: $checked, styles: $styles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoContentImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.checked, checked) || other.checked == checked) &&
            const DeepCollectionEquality().equals(other._styles, _styles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    text,
    checked,
    const DeepCollectionEquality().hash(_styles),
  );

  /// Create a copy of TodoContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoContentImplCopyWith<_$TodoContentImpl> get copyWith =>
      __$$TodoContentImplCopyWithImpl<_$TodoContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoContentImplToJson(this);
  }
}

abstract class _TodoContent implements TodoContent {
  const factory _TodoContent({
    final String text,
    final bool checked,
    final List<Map<String, dynamic>> styles,
  }) = _$TodoContentImpl;

  factory _TodoContent.fromJson(Map<String, dynamic> json) =
      _$TodoContentImpl.fromJson;

  @override
  String get text;
  @override
  bool get checked;
  @override
  List<Map<String, dynamic>> get styles;

  /// Create a copy of TodoContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoContentImplCopyWith<_$TodoContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ImageContent _$ImageContentFromJson(Map<String, dynamic> json) {
  return _ImageContent.fromJson(json);
}

/// @nodoc
mixin _$ImageContent {
  String get url => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  double? get width => throw _privateConstructorUsedError;
  double? get height => throw _privateConstructorUsedError;

  /// Serializes this ImageContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ImageContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImageContentCopyWith<ImageContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImageContentCopyWith<$Res> {
  factory $ImageContentCopyWith(
    ImageContent value,
    $Res Function(ImageContent) then,
  ) = _$ImageContentCopyWithImpl<$Res, ImageContent>;
  @useResult
  $Res call({String url, String? caption, double? width, double? height});
}

/// @nodoc
class _$ImageContentCopyWithImpl<$Res, $Val extends ImageContent>
    implements $ImageContentCopyWith<$Res> {
  _$ImageContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImageContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? caption = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ImageContentImplCopyWith<$Res>
    implements $ImageContentCopyWith<$Res> {
  factory _$$ImageContentImplCopyWith(
    _$ImageContentImpl value,
    $Res Function(_$ImageContentImpl) then,
  ) = __$$ImageContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, String? caption, double? width, double? height});
}

/// @nodoc
class __$$ImageContentImplCopyWithImpl<$Res>
    extends _$ImageContentCopyWithImpl<$Res, _$ImageContentImpl>
    implements _$$ImageContentImplCopyWith<$Res> {
  __$$ImageContentImplCopyWithImpl(
    _$ImageContentImpl _value,
    $Res Function(_$ImageContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ImageContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? caption = freezed,
    Object? width = freezed,
    Object? height = freezed,
  }) {
    return _then(
      _$ImageContentImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ImageContentImpl implements _ImageContent {
  const _$ImageContentImpl({
    required this.url,
    this.caption,
    this.width,
    this.height,
  });

  factory _$ImageContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImageContentImplFromJson(json);

  @override
  final String url;
  @override
  final String? caption;
  @override
  final double? width;
  @override
  final double? height;

  @override
  String toString() {
    return 'ImageContent(url: $url, caption: $caption, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImageContentImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, caption, width, height);

  /// Create a copy of ImageContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImageContentImplCopyWith<_$ImageContentImpl> get copyWith =>
      __$$ImageContentImplCopyWithImpl<_$ImageContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImageContentImplToJson(this);
  }
}

abstract class _ImageContent implements ImageContent {
  const factory _ImageContent({
    required final String url,
    final String? caption,
    final double? width,
    final double? height,
  }) = _$ImageContentImpl;

  factory _ImageContent.fromJson(Map<String, dynamic> json) =
      _$ImageContentImpl.fromJson;

  @override
  String get url;
  @override
  String? get caption;
  @override
  double? get width;
  @override
  double? get height;

  /// Create a copy of ImageContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImageContentImplCopyWith<_$ImageContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CodeContent _$CodeContentFromJson(Map<String, dynamic> json) {
  return _CodeContent.fromJson(json);
}

/// @nodoc
mixin _$CodeContent {
  String get code => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;

  /// Serializes this CodeContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CodeContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CodeContentCopyWith<CodeContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CodeContentCopyWith<$Res> {
  factory $CodeContentCopyWith(
    CodeContent value,
    $Res Function(CodeContent) then,
  ) = _$CodeContentCopyWithImpl<$Res, CodeContent>;
  @useResult
  $Res call({String code, String? language, String? caption});
}

/// @nodoc
class _$CodeContentCopyWithImpl<$Res, $Val extends CodeContent>
    implements $CodeContentCopyWith<$Res> {
  _$CodeContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CodeContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? language = freezed,
    Object? caption = freezed,
  }) {
    return _then(
      _value.copyWith(
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            caption: freezed == caption
                ? _value.caption
                : caption // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CodeContentImplCopyWith<$Res>
    implements $CodeContentCopyWith<$Res> {
  factory _$$CodeContentImplCopyWith(
    _$CodeContentImpl value,
    $Res Function(_$CodeContentImpl) then,
  ) = __$$CodeContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String code, String? language, String? caption});
}

/// @nodoc
class __$$CodeContentImplCopyWithImpl<$Res>
    extends _$CodeContentCopyWithImpl<$Res, _$CodeContentImpl>
    implements _$$CodeContentImplCopyWith<$Res> {
  __$$CodeContentImplCopyWithImpl(
    _$CodeContentImpl _value,
    $Res Function(_$CodeContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CodeContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? language = freezed,
    Object? caption = freezed,
  }) {
    return _then(
      _$CodeContentImpl(
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        caption: freezed == caption
            ? _value.caption
            : caption // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CodeContentImpl implements _CodeContent {
  const _$CodeContentImpl({required this.code, this.language, this.caption});

  factory _$CodeContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CodeContentImplFromJson(json);

  @override
  final String code;
  @override
  final String? language;
  @override
  final String? caption;

  @override
  String toString() {
    return 'CodeContent(code: $code, language: $language, caption: $caption)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CodeContentImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.caption, caption) || other.caption == caption));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, code, language, caption);

  /// Create a copy of CodeContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CodeContentImplCopyWith<_$CodeContentImpl> get copyWith =>
      __$$CodeContentImplCopyWithImpl<_$CodeContentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CodeContentImplToJson(this);
  }
}

abstract class _CodeContent implements CodeContent {
  const factory _CodeContent({
    required final String code,
    final String? language,
    final String? caption,
  }) = _$CodeContentImpl;

  factory _CodeContent.fromJson(Map<String, dynamic> json) =
      _$CodeContentImpl.fromJson;

  @override
  String get code;
  @override
  String? get language;
  @override
  String? get caption;

  /// Create a copy of CodeContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CodeContentImplCopyWith<_$CodeContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CalloutContent _$CalloutContentFromJson(Map<String, dynamic> json) {
  return _CalloutContent.fromJson(json);
}

/// @nodoc
mixin _$CalloutContent {
  String get icon => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get styles => throw _privateConstructorUsedError;
  String? get backgroundColor => throw _privateConstructorUsedError;

  /// Serializes this CalloutContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CalloutContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CalloutContentCopyWith<CalloutContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CalloutContentCopyWith<$Res> {
  factory $CalloutContentCopyWith(
    CalloutContent value,
    $Res Function(CalloutContent) then,
  ) = _$CalloutContentCopyWithImpl<$Res, CalloutContent>;
  @useResult
  $Res call({
    String icon,
    String text,
    List<Map<String, dynamic>> styles,
    String? backgroundColor,
  });
}

/// @nodoc
class _$CalloutContentCopyWithImpl<$Res, $Val extends CalloutContent>
    implements $CalloutContentCopyWith<$Res> {
  _$CalloutContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CalloutContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? text = null,
    Object? styles = null,
    Object? backgroundColor = freezed,
  }) {
    return _then(
      _value.copyWith(
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            text: null == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String,
            styles: null == styles
                ? _value.styles
                : styles // ignore: cast_nullable_to_non_nullable
                      as List<Map<String, dynamic>>,
            backgroundColor: freezed == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CalloutContentImplCopyWith<$Res>
    implements $CalloutContentCopyWith<$Res> {
  factory _$$CalloutContentImplCopyWith(
    _$CalloutContentImpl value,
    $Res Function(_$CalloutContentImpl) then,
  ) = __$$CalloutContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String icon,
    String text,
    List<Map<String, dynamic>> styles,
    String? backgroundColor,
  });
}

/// @nodoc
class __$$CalloutContentImplCopyWithImpl<$Res>
    extends _$CalloutContentCopyWithImpl<$Res, _$CalloutContentImpl>
    implements _$$CalloutContentImplCopyWith<$Res> {
  __$$CalloutContentImplCopyWithImpl(
    _$CalloutContentImpl _value,
    $Res Function(_$CalloutContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CalloutContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? icon = null,
    Object? text = null,
    Object? styles = null,
    Object? backgroundColor = freezed,
  }) {
    return _then(
      _$CalloutContentImpl(
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        text: null == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String,
        styles: null == styles
            ? _value._styles
            : styles // ignore: cast_nullable_to_non_nullable
                  as List<Map<String, dynamic>>,
        backgroundColor: freezed == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CalloutContentImpl implements _CalloutContent {
  const _$CalloutContentImpl({
    this.icon = '💡',
    required this.text,
    final List<Map<String, dynamic>> styles = const [],
    this.backgroundColor,
  }) : _styles = styles;

  factory _$CalloutContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CalloutContentImplFromJson(json);

  @override
  @JsonKey()
  final String icon;
  @override
  final String text;
  final List<Map<String, dynamic>> _styles;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get styles {
    if (_styles is EqualUnmodifiableListView) return _styles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_styles);
  }

  @override
  final String? backgroundColor;

  @override
  String toString() {
    return 'CalloutContent(icon: $icon, text: $text, styles: $styles, backgroundColor: $backgroundColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CalloutContentImpl &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.text, text) || other.text == text) &&
            const DeepCollectionEquality().equals(other._styles, _styles) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    icon,
    text,
    const DeepCollectionEquality().hash(_styles),
    backgroundColor,
  );

  /// Create a copy of CalloutContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CalloutContentImplCopyWith<_$CalloutContentImpl> get copyWith =>
      __$$CalloutContentImplCopyWithImpl<_$CalloutContentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CalloutContentImplToJson(this);
  }
}

abstract class _CalloutContent implements CalloutContent {
  const factory _CalloutContent({
    final String icon,
    required final String text,
    final List<Map<String, dynamic>> styles,
    final String? backgroundColor,
  }) = _$CalloutContentImpl;

  factory _CalloutContent.fromJson(Map<String, dynamic> json) =
      _$CalloutContentImpl.fromJson;

  @override
  String get icon;
  @override
  String get text;
  @override
  List<Map<String, dynamic>> get styles;
  @override
  String? get backgroundColor;

  /// Create a copy of CalloutContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CalloutContentImplCopyWith<_$CalloutContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
