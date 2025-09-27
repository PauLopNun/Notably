import 'package:equatable/equatable.dart';

enum OperationType { insert, delete, retain, format }

class CollaborativeOperation extends Equatable {
  final String id;
  final OperationType type;
  final int position;
  final String? text;
  final int? length;
  final Map<String, dynamic>? attributes;
  final String authorId;
  final String authorName;
  final DateTime timestamp;
  final String documentId;

  const CollaborativeOperation({
    required this.id,
    required this.type,
    required this.position,
    this.text,
    this.length,
    this.attributes,
    required this.authorId,
    required this.authorName,
    required this.timestamp,
    required this.documentId,
  });

  CollaborativeOperation copyWith({
    String? id,
    OperationType? type,
    int? position,
    String? text,
    int? length,
    Map<String, dynamic>? attributes,
    String? authorId,
    String? authorName,
    DateTime? timestamp,
    String? documentId,
  }) {
    return CollaborativeOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      text: text ?? this.text,
      length: length ?? this.length,
      attributes: attributes ?? this.attributes,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      timestamp: timestamp ?? this.timestamp,
      documentId: documentId ?? this.documentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'position': position,
      'text': text,
      'length': length,
      'attributes': attributes,
      'author_id': authorId,
      'author_name': authorName,
      'timestamp': timestamp.toIso8601String(),
      'document_id': documentId,
    };
  }

  factory CollaborativeOperation.fromJson(Map<String, dynamic> json) {
    return CollaborativeOperation(
      id: json['id'] as String,
      type: OperationType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => OperationType.retain,
      ),
      position: json['position'] as int,
      text: json['text'] as String?,
      length: json['length'] as int?,
      attributes: json['attributes'] as Map<String, dynamic>?,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      documentId: json['document_id'] as String,
    );
  }

  // Transform operation against another operation (Operational Transformation)
  CollaborativeOperation? transform(CollaborativeOperation other) {
    if (position <= other.position) {
      return this;
    }

    switch (other.type) {
      case OperationType.insert:
        return copyWith(position: position + (other.text?.length ?? 0));
      case OperationType.delete:
        final deleteLength = other.length ?? 0;
        if (position >= other.position + deleteLength) {
          return copyWith(position: position - deleteLength);
        } else if (position > other.position) {
          return copyWith(position: other.position);
        }
        return this;
      case OperationType.retain:
      case OperationType.format:
        return this;
    }
  }

  @override
  List<Object?> get props => [
        id,
        type,
        position,
        text,
        length,
        attributes,
        authorId,
        authorName,
        timestamp,
        documentId,
      ];
}

// Factory methods for common operations
extension CollaborativeOperationFactory on CollaborativeOperation {
  static CollaborativeOperation insert({
    required String text,
    required int position,
    required String authorId,
    required String authorName,
    required String documentId,
    Map<String, dynamic>? attributes,
  }) {
    return CollaborativeOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.insert,
      position: position,
      text: text,
      attributes: attributes,
      authorId: authorId,
      authorName: authorName,
      timestamp: DateTime.now(),
      documentId: documentId,
    );
  }

  static CollaborativeOperation delete({
    required int position,
    required int length,
    required String authorId,
    required String authorName,
    required String documentId,
  }) {
    return CollaborativeOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.delete,
      position: position,
      length: length,
      authorId: authorId,
      authorName: authorName,
      timestamp: DateTime.now(),
      documentId: documentId,
    );
  }

  static CollaborativeOperation format({
    required int position,
    required int length,
    required Map<String, dynamic> attributes,
    required String authorId,
    required String authorName,
    required String documentId,
  }) {
    return CollaborativeOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: OperationType.format,
      position: position,
      length: length,
      attributes: attributes,
      authorId: authorId,
      authorName: authorName,
      timestamp: DateTime.now(),
      documentId: documentId,
    );
  }
}