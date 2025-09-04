import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'collaborative_operation.freezed.dart';
part 'collaborative_operation.g.dart';

@freezed
class CollaborativeOperation with _$CollaborativeOperation {
  const factory CollaborativeOperation({
    required String id,
    required String documentId,
    required String userId,
    required String userName,
    required OperationType type,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    int? position,
    String? content,
  }) = _CollaborativeOperation;

  factory CollaborativeOperation.fromJson(Map<String, dynamic> json) =>
      _$CollaborativeOperationFromJson(json);
}

enum OperationType {
  @JsonValue('insert')
  insert,
  @JsonValue('delete') 
  delete,
  @JsonValue('retain')
  retain,
  @JsonValue('format')
  format,
  @JsonValue('cursor_move')
  cursorMove,
}

@freezed
class CursorPosition with _$CursorPosition {
  const factory CursorPosition({
    required String userId,
    required String userName,
    required int position,
    required int selection,
    required String color,
    required DateTime timestamp,
  }) = _CursorPosition;

  factory CursorPosition.fromJson(Map<String, dynamic> json) =>
      _$CursorPositionFromJson(json);
}