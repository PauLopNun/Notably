// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collaborative_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CollaborativeOperationImpl _$$CollaborativeOperationImplFromJson(
  Map<String, dynamic> json,
) => _$CollaborativeOperationImpl(
  id: json['id'] as String,
  documentId: json['documentId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  type: $enumDecode(_$OperationTypeEnumMap, json['type']),
  data: json['data'] as Map<String, dynamic>,
  timestamp: DateTime.parse(json['timestamp'] as String),
  position: (json['position'] as num?)?.toInt(),
  content: json['content'] as String?,
);

Map<String, dynamic> _$$CollaborativeOperationImplToJson(
  _$CollaborativeOperationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'documentId': instance.documentId,
  'userId': instance.userId,
  'userName': instance.userName,
  'type': _$OperationTypeEnumMap[instance.type]!,
  'data': instance.data,
  'timestamp': instance.timestamp.toIso8601String(),
  'position': instance.position,
  'content': instance.content,
};

const _$OperationTypeEnumMap = {
  OperationType.insert: 'insert',
  OperationType.delete: 'delete',
  OperationType.retain: 'retain',
  OperationType.format: 'format',
  OperationType.cursorMove: 'cursor_move',
};

_$CursorPositionImpl _$$CursorPositionImplFromJson(Map<String, dynamic> json) =>
    _$CursorPositionImpl(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      position: (json['position'] as num).toInt(),
      selection: (json['selection'] as num).toInt(),
      color: json['color'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$CursorPositionImplToJson(
  _$CursorPositionImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'userName': instance.userName,
  'position': instance.position,
  'selection': instance.selection,
  'color': instance.color,
  'timestamp': instance.timestamp.toIso8601String(),
};
