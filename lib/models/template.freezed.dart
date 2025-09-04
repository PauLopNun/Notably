// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PageTemplate _$PageTemplateFromJson(Map<String, dynamic> json) {
  return _PageTemplate.fromJson(json);
}

/// @nodoc
mixin _$PageTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  String? get coverImage => throw _privateConstructorUsedError;
  List<TemplateBlock> get blocks => throw _privateConstructorUsedError;
  List<TemplateProperty> get properties => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  bool get isOfficial => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this PageTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageTemplateCopyWith<PageTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageTemplateCopyWith<$Res> {
  factory $PageTemplateCopyWith(
    PageTemplate value,
    $Res Function(PageTemplate) then,
  ) = _$PageTemplateCopyWithImpl<$Res, PageTemplate>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String category,
    String? icon,
    String? coverImage,
    List<TemplateBlock> blocks,
    List<TemplateProperty> properties,
    bool isPublic,
    bool isOfficial,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    int usageCount,
    List<String> tags,
  });
}

/// @nodoc
class _$PageTemplateCopyWithImpl<$Res, $Val extends PageTemplate>
    implements $PageTemplateCopyWith<$Res> {
  _$PageTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? icon = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? properties = null,
    Object? isPublic = null,
    Object? isOfficial = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? usageCount = null,
    Object? tags = null,
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
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
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
                      as List<TemplateBlock>,
            properties: null == properties
                ? _value.properties
                : properties // ignore: cast_nullable_to_non_nullable
                      as List<TemplateProperty>,
            isPublic: null == isPublic
                ? _value.isPublic
                : isPublic // ignore: cast_nullable_to_non_nullable
                      as bool,
            isOfficial: null == isOfficial
                ? _value.isOfficial
                : isOfficial // ignore: cast_nullable_to_non_nullable
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
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PageTemplateImplCopyWith<$Res>
    implements $PageTemplateCopyWith<$Res> {
  factory _$$PageTemplateImplCopyWith(
    _$PageTemplateImpl value,
    $Res Function(_$PageTemplateImpl) then,
  ) = __$$PageTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String category,
    String? icon,
    String? coverImage,
    List<TemplateBlock> blocks,
    List<TemplateProperty> properties,
    bool isPublic,
    bool isOfficial,
    String createdBy,
    DateTime createdAt,
    DateTime updatedAt,
    int usageCount,
    List<String> tags,
  });
}

/// @nodoc
class __$$PageTemplateImplCopyWithImpl<$Res>
    extends _$PageTemplateCopyWithImpl<$Res, _$PageTemplateImpl>
    implements _$$PageTemplateImplCopyWith<$Res> {
  __$$PageTemplateImplCopyWithImpl(
    _$PageTemplateImpl _value,
    $Res Function(_$PageTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? category = null,
    Object? icon = freezed,
    Object? coverImage = freezed,
    Object? blocks = null,
    Object? properties = null,
    Object? isPublic = null,
    Object? isOfficial = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? usageCount = null,
    Object? tags = null,
  }) {
    return _then(
      _$PageTemplateImpl(
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
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
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
                  as List<TemplateBlock>,
        properties: null == properties
            ? _value._properties
            : properties // ignore: cast_nullable_to_non_nullable
                  as List<TemplateProperty>,
        isPublic: null == isPublic
            ? _value.isPublic
            : isPublic // ignore: cast_nullable_to_non_nullable
                  as bool,
        isOfficial: null == isOfficial
            ? _value.isOfficial
            : isOfficial // ignore: cast_nullable_to_non_nullable
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
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PageTemplateImpl implements _PageTemplate {
  const _$PageTemplateImpl({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.icon,
    this.coverImage,
    required final List<TemplateBlock> blocks,
    final List<TemplateProperty> properties = const [],
    this.isPublic = false,
    this.isOfficial = false,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.usageCount = 0,
    final List<String> tags = const [],
  }) : _blocks = blocks,
       _properties = properties,
       _tags = tags;

  factory _$PageTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PageTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String category;
  @override
  final String? icon;
  @override
  final String? coverImage;
  final List<TemplateBlock> _blocks;
  @override
  List<TemplateBlock> get blocks {
    if (_blocks is EqualUnmodifiableListView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blocks);
  }

  final List<TemplateProperty> _properties;
  @override
  @JsonKey()
  List<TemplateProperty> get properties {
    if (_properties is EqualUnmodifiableListView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_properties);
  }

  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final bool isOfficial;
  @override
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final int usageCount;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'PageTemplate(id: $id, name: $name, description: $description, category: $category, icon: $icon, coverImage: $coverImage, blocks: $blocks, properties: $properties, isPublic: $isPublic, isOfficial: $isOfficial, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, usageCount: $usageCount, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks) &&
            const DeepCollectionEquality().equals(
              other._properties,
              _properties,
            ) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    category,
    icon,
    coverImage,
    const DeepCollectionEquality().hash(_blocks),
    const DeepCollectionEquality().hash(_properties),
    isPublic,
    isOfficial,
    createdBy,
    createdAt,
    updatedAt,
    usageCount,
    const DeepCollectionEquality().hash(_tags),
  );

  /// Create a copy of PageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageTemplateImplCopyWith<_$PageTemplateImpl> get copyWith =>
      __$$PageTemplateImplCopyWithImpl<_$PageTemplateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PageTemplateImplToJson(this);
  }
}

abstract class _PageTemplate implements PageTemplate {
  const factory _PageTemplate({
    required final String id,
    required final String name,
    final String? description,
    required final String category,
    final String? icon,
    final String? coverImage,
    required final List<TemplateBlock> blocks,
    final List<TemplateProperty> properties,
    final bool isPublic,
    final bool isOfficial,
    required final String createdBy,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final int usageCount,
    final List<String> tags,
  }) = _$PageTemplateImpl;

  factory _PageTemplate.fromJson(Map<String, dynamic> json) =
      _$PageTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String get category;
  @override
  String? get icon;
  @override
  String? get coverImage;
  @override
  List<TemplateBlock> get blocks;
  @override
  List<TemplateProperty> get properties;
  @override
  bool get isPublic;
  @override
  bool get isOfficial;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  int get usageCount;
  @override
  List<String> get tags;

  /// Create a copy of PageTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageTemplateImplCopyWith<_$PageTemplateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateBlock _$TemplateBlockFromJson(Map<String, dynamic> json) {
  return _TemplateBlock.fromJson(json);
}

/// @nodoc
mixin _$TemplateBlock {
  String get id => throw _privateConstructorUsedError;
  String? get parentBlockId => throw _privateConstructorUsedError;
  BlockType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get content => throw _privateConstructorUsedError;
  Map<String, dynamic> get properties => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  bool get isPlaceholder => throw _privateConstructorUsedError;
  String? get placeholderText => throw _privateConstructorUsedError;

  /// Serializes this TemplateBlock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemplateBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateBlockCopyWith<TemplateBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateBlockCopyWith<$Res> {
  factory $TemplateBlockCopyWith(
    TemplateBlock value,
    $Res Function(TemplateBlock) then,
  ) = _$TemplateBlockCopyWithImpl<$Res, TemplateBlock>;
  @useResult
  $Res call({
    String id,
    String? parentBlockId,
    BlockType type,
    Map<String, dynamic> content,
    Map<String, dynamic> properties,
    int position,
    bool isPlaceholder,
    String? placeholderText,
  });
}

/// @nodoc
class _$TemplateBlockCopyWithImpl<$Res, $Val extends TemplateBlock>
    implements $TemplateBlockCopyWith<$Res> {
  _$TemplateBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemplateBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentBlockId = freezed,
    Object? type = null,
    Object? content = null,
    Object? properties = null,
    Object? position = null,
    Object? isPlaceholder = null,
    Object? placeholderText = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
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
            isPlaceholder: null == isPlaceholder
                ? _value.isPlaceholder
                : isPlaceholder // ignore: cast_nullable_to_non_nullable
                      as bool,
            placeholderText: freezed == placeholderText
                ? _value.placeholderText
                : placeholderText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TemplateBlockImplCopyWith<$Res>
    implements $TemplateBlockCopyWith<$Res> {
  factory _$$TemplateBlockImplCopyWith(
    _$TemplateBlockImpl value,
    $Res Function(_$TemplateBlockImpl) then,
  ) = __$$TemplateBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? parentBlockId,
    BlockType type,
    Map<String, dynamic> content,
    Map<String, dynamic> properties,
    int position,
    bool isPlaceholder,
    String? placeholderText,
  });
}

/// @nodoc
class __$$TemplateBlockImplCopyWithImpl<$Res>
    extends _$TemplateBlockCopyWithImpl<$Res, _$TemplateBlockImpl>
    implements _$$TemplateBlockImplCopyWith<$Res> {
  __$$TemplateBlockImplCopyWithImpl(
    _$TemplateBlockImpl _value,
    $Res Function(_$TemplateBlockImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TemplateBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? parentBlockId = freezed,
    Object? type = null,
    Object? content = null,
    Object? properties = null,
    Object? position = null,
    Object? isPlaceholder = null,
    Object? placeholderText = freezed,
  }) {
    return _then(
      _$TemplateBlockImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
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
        isPlaceholder: null == isPlaceholder
            ? _value.isPlaceholder
            : isPlaceholder // ignore: cast_nullable_to_non_nullable
                  as bool,
        placeholderText: freezed == placeholderText
            ? _value.placeholderText
            : placeholderText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateBlockImpl implements _TemplateBlock {
  const _$TemplateBlockImpl({
    required this.id,
    this.parentBlockId,
    required this.type,
    final Map<String, dynamic> content = const {},
    final Map<String, dynamic> properties = const {},
    this.position = 0,
    this.isPlaceholder = false,
    this.placeholderText,
  }) : _content = content,
       _properties = properties;

  factory _$TemplateBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateBlockImplFromJson(json);

  @override
  final String id;
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
  @JsonKey()
  final bool isPlaceholder;
  @override
  final String? placeholderText;

  @override
  String toString() {
    return 'TemplateBlock(id: $id, parentBlockId: $parentBlockId, type: $type, content: $content, properties: $properties, position: $position, isPlaceholder: $isPlaceholder, placeholderText: $placeholderText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
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
            (identical(other.isPlaceholder, isPlaceholder) ||
                other.isPlaceholder == isPlaceholder) &&
            (identical(other.placeholderText, placeholderText) ||
                other.placeholderText == placeholderText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    parentBlockId,
    type,
    const DeepCollectionEquality().hash(_content),
    const DeepCollectionEquality().hash(_properties),
    position,
    isPlaceholder,
    placeholderText,
  );

  /// Create a copy of TemplateBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateBlockImplCopyWith<_$TemplateBlockImpl> get copyWith =>
      __$$TemplateBlockImplCopyWithImpl<_$TemplateBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateBlockImplToJson(this);
  }
}

abstract class _TemplateBlock implements TemplateBlock {
  const factory _TemplateBlock({
    required final String id,
    final String? parentBlockId,
    required final BlockType type,
    final Map<String, dynamic> content,
    final Map<String, dynamic> properties,
    final int position,
    final bool isPlaceholder,
    final String? placeholderText,
  }) = _$TemplateBlockImpl;

  factory _TemplateBlock.fromJson(Map<String, dynamic> json) =
      _$TemplateBlockImpl.fromJson;

  @override
  String get id;
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
  bool get isPlaceholder;
  @override
  String? get placeholderText;

  /// Create a copy of TemplateBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateBlockImplCopyWith<_$TemplateBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TemplateProperty _$TemplatePropertyFromJson(Map<String, dynamic> json) {
  return _TemplateProperty.fromJson(json);
}

/// @nodoc
mixin _$TemplateProperty {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  TemplatePropertyType get type => throw _privateConstructorUsedError;
  Map<String, dynamic> get options => throw _privateConstructorUsedError;
  bool get isRequired => throw _privateConstructorUsedError;
  String? get defaultValue => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this TemplateProperty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemplateProperty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplatePropertyCopyWith<TemplateProperty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplatePropertyCopyWith<$Res> {
  factory $TemplatePropertyCopyWith(
    TemplateProperty value,
    $Res Function(TemplateProperty) then,
  ) = _$TemplatePropertyCopyWithImpl<$Res, TemplateProperty>;
  @useResult
  $Res call({
    String id,
    String name,
    TemplatePropertyType type,
    Map<String, dynamic> options,
    bool isRequired,
    String? defaultValue,
    String? description,
  });
}

/// @nodoc
class _$TemplatePropertyCopyWithImpl<$Res, $Val extends TemplateProperty>
    implements $TemplatePropertyCopyWith<$Res> {
  _$TemplatePropertyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemplateProperty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? options = null,
    Object? isRequired = null,
    Object? defaultValue = freezed,
    Object? description = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as TemplatePropertyType,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            isRequired: null == isRequired
                ? _value.isRequired
                : isRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
            defaultValue: freezed == defaultValue
                ? _value.defaultValue
                : defaultValue // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TemplatePropertyImplCopyWith<$Res>
    implements $TemplatePropertyCopyWith<$Res> {
  factory _$$TemplatePropertyImplCopyWith(
    _$TemplatePropertyImpl value,
    $Res Function(_$TemplatePropertyImpl) then,
  ) = __$$TemplatePropertyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    TemplatePropertyType type,
    Map<String, dynamic> options,
    bool isRequired,
    String? defaultValue,
    String? description,
  });
}

/// @nodoc
class __$$TemplatePropertyImplCopyWithImpl<$Res>
    extends _$TemplatePropertyCopyWithImpl<$Res, _$TemplatePropertyImpl>
    implements _$$TemplatePropertyImplCopyWith<$Res> {
  __$$TemplatePropertyImplCopyWithImpl(
    _$TemplatePropertyImpl _value,
    $Res Function(_$TemplatePropertyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TemplateProperty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? options = null,
    Object? isRequired = null,
    Object? defaultValue = freezed,
    Object? description = freezed,
  }) {
    return _then(
      _$TemplatePropertyImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as TemplatePropertyType,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        isRequired: null == isRequired
            ? _value.isRequired
            : isRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
        defaultValue: freezed == defaultValue
            ? _value.defaultValue
            : defaultValue // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplatePropertyImpl implements _TemplateProperty {
  const _$TemplatePropertyImpl({
    required this.id,
    required this.name,
    required this.type,
    final Map<String, dynamic> options = const {},
    this.isRequired = false,
    this.defaultValue,
    this.description,
  }) : _options = options;

  factory _$TemplatePropertyImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplatePropertyImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final TemplatePropertyType type;
  final Map<String, dynamic> _options;
  @override
  @JsonKey()
  Map<String, dynamic> get options {
    if (_options is EqualUnmodifiableMapView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_options);
  }

  @override
  @JsonKey()
  final bool isRequired;
  @override
  final String? defaultValue;
  @override
  final String? description;

  @override
  String toString() {
    return 'TemplateProperty(id: $id, name: $name, type: $type, options: $options, isRequired: $isRequired, defaultValue: $defaultValue, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplatePropertyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.isRequired, isRequired) ||
                other.isRequired == isRequired) &&
            (identical(other.defaultValue, defaultValue) ||
                other.defaultValue == defaultValue) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    const DeepCollectionEquality().hash(_options),
    isRequired,
    defaultValue,
    description,
  );

  /// Create a copy of TemplateProperty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplatePropertyImplCopyWith<_$TemplatePropertyImpl> get copyWith =>
      __$$TemplatePropertyImplCopyWithImpl<_$TemplatePropertyImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplatePropertyImplToJson(this);
  }
}

abstract class _TemplateProperty implements TemplateProperty {
  const factory _TemplateProperty({
    required final String id,
    required final String name,
    required final TemplatePropertyType type,
    final Map<String, dynamic> options,
    final bool isRequired,
    final String? defaultValue,
    final String? description,
  }) = _$TemplatePropertyImpl;

  factory _TemplateProperty.fromJson(Map<String, dynamic> json) =
      _$TemplatePropertyImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  TemplatePropertyType get type;
  @override
  Map<String, dynamic> get options;
  @override
  bool get isRequired;
  @override
  String? get defaultValue;
  @override
  String? get description;

  /// Create a copy of TemplateProperty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplatePropertyImplCopyWith<_$TemplatePropertyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
