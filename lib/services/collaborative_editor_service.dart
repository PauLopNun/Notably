import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/collaborative_operation.dart';

final collaborativeEditorServiceProvider = Provider<CollaborativeEditorService>((ref) {
  return CollaborativeEditorService();
});

class CollaborativeEditorService {
  final _supabase = Supabase.instance.client;
  WebSocketChannel? _webSocketChannel;
  String? _currentDocumentId;
  
  // Streams para comunicación en tiempo real
  final StreamController<CollaborativeOperation> _operationsController = 
      StreamController<CollaborativeOperation>.broadcast();
  final StreamController<List<CursorPosition>> _cursorsController = 
      StreamController<List<CursorPosition>>.broadcast();
  final StreamController<List<String>> _collaboratorsController = 
      StreamController<List<String>>.broadcast();

  // Estado local
  final List<CollaborativeOperation> _pendingOperations = [];
  final List<CollaborativeOperation> _acknowledgedOperations = [];
  final Map<String, CursorPosition> _activeCursors = {};
  
  // Getters para streams
  Stream<CollaborativeOperation> get operationsStream => _operationsController.stream;
  Stream<List<CursorPosition>> get cursorsStream => _cursorsController.stream;
  Stream<List<String>> get collaboratorsStream => _collaboratorsController.stream;

  // Colores para cursores de colaboradores
  final List<String> _cursorColors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', 
    '#FECA57', '#FF9FF3', '#54A0FF', '#5F27CD'
  ];

  Future<void> joinDocument(String documentId) async {
    if (_currentDocumentId == documentId && _webSocketChannel != null) {
      return; // Ya conectado a este documento
    }
    
    await leaveDocument();
    _currentDocumentId = documentId;
    
    try {
      // Establecer conexión WebSocket con Supabase Realtime
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      
      await _connectToRealtimeChannel(documentId, user);
      
    } catch (e) {
      debugPrint('Error joining document: $e');
      rethrow;
    }
  }

  Future<void> _connectToRealtimeChannel(String documentId, User user) async {
    try {
      // Suscribirse al canal de tiempo real de Supabase
      final channel = _supabase.channel('document_$documentId');
      
      channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'collaborative_operations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'document_id',
            value: documentId,
          ),
          callback: (payload) {
            _handleRemoteOperation(payload);
          },
        )
        .subscribe();

      // También escuchar cursores en tiempo real usando cambios en la base de datos
      channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'user_presence',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'document_id',
            value: documentId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              _handleCursorUpdate(payload.newRecord);
            }
          },
        );

      // Notificar presencia inicial
      await _supabase.rpc('update_user_presence', params: {
        'p_document_id': documentId,
        'p_cursor_position': 0,
        'p_cursor_selection': 0,
      });

    } catch (e) {
      debugPrint('Error connecting to realtime: $e');
      rethrow;
    }
  }

  void _handleRemoteOperation(PostgresChangePayload payload) {
    try {
      final operation = CollaborativeOperation.fromJson(payload.newRecord);
      
      // No procesar nuestras propias operaciones
      final currentUserId = _supabase.auth.currentUser?.id;
      if (operation.userId == currentUserId) return;
      
      _operationsController.add(operation);
      
    } catch (e) {
      debugPrint('Error handling remote operation: $e');
    }
  }

  void _handleCursorUpdate(Map<String, dynamic> payload) {
    try {
      final cursor = CursorPosition(
        userId: payload['user_id'] ?? '',
        userName: payload['user_name'] ?? 'Usuario',
        position: payload['cursor_position'] ?? 0,
        selection: payload['cursor_selection'] ?? 0,
        color: _getCursorColor(payload['user_id'] ?? ''),
        timestamp: DateTime.parse(payload['last_seen'] ?? DateTime.now().toIso8601String()),
      );
      
      // No mostrar nuestro propio cursor
      final currentUserId = _supabase.auth.currentUser?.id;
      if (cursor.userId == currentUserId) return;
      
      _activeCursors[cursor.userId] = cursor;
      _cursorsController.add(_activeCursors.values.toList());
      
    } catch (e) {
      debugPrint('Error handling cursor update: $e');
    }
  }

  Future<void> sendOperation(CollaborativeOperation operation) async {
    try {
      // Guardar operación en base de datos
      await _supabase
        .from('collaborative_operations')
        .insert(operation.toJson());
      
      // Agregar a operaciones pendientes
      _pendingOperations.add(operation);
      
    } catch (e) {
      debugPrint('Error sending operation: $e');
      rethrow;
    }
  }

  Future<void> sendCursorUpdate(int position, int selection) async {
    if (_currentDocumentId == null) return;
    
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      
      // Broadcast cursor position via database insert
      // Note: For simplicity, we're using database operations instead of WebRTC
      await _supabase
        .rpc('update_user_presence', params: {
          'p_document_id': _currentDocumentId,
          'p_cursor_position': position,
          'p_cursor_selection': selection,
        });
        
    } catch (e) {
      debugPrint('Error sending cursor update: $e');
    }
  }

  String _getCursorColor(String userId) {
    final hash = userId.hashCode.abs();
    return _cursorColors[hash % _cursorColors.length];
  }

  // Transformación operacional para resolver conflictos
  CollaborativeOperation transformOperation(
    CollaborativeOperation op1,
    CollaborativeOperation op2,
  ) {
    // Implementación básica de transformación operacional
    if (op1.type == OperationType.insert && op2.type == OperationType.insert) {
      if (op1.position! <= op2.position!) {
        return op2.copyWith(position: op2.position! + (op1.content?.length ?? 0));
      }
    }
    
    if (op1.type == OperationType.delete && op2.type == OperationType.insert) {
      if (op1.position! < op2.position!) {
        return op2.copyWith(position: op2.position! - (op1.content?.length ?? 0));
      }
    }
    
    return op2;
  }

  Future<List<CollaborativeOperation>> getDocumentHistory(String documentId) async {
    try {
      final response = await _supabase
        .from('collaborative_operations')
        .select()
        .eq('document_id', documentId)
        .order('timestamp', ascending: true);
      
      return response
        .map<CollaborativeOperation>((json) => CollaborativeOperation.fromJson(json))
        .toList();
        
    } catch (e) {
      debugPrint('Error getting document history: $e');
      return [];
    }
  }

  Future<void> inviteCollaborator(String documentId, String email) async {
    try {
      await _supabase
        .from('document_collaborators')
        .insert({
          'document_id': documentId,
          'email': email,
          'invited_at': DateTime.now().toIso8601String(),
          'invited_by': _supabase.auth.currentUser?.id,
        });
        
    } catch (e) {
      debugPrint('Error inviting collaborator: $e');
      rethrow;
    }
  }

  Future<void> leaveDocument() async {
    if (_currentDocumentId != null) {
      try {
        await _supabase
          .channel('document_$_currentDocumentId')
          .unsubscribe();
      } catch (e) {
        debugPrint('Error leaving document: $e');
      }
    }
    
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
    _currentDocumentId = null;
    _activeCursors.clear();
    _pendingOperations.clear();
    _acknowledgedOperations.clear();
  }

  void dispose() {
    leaveDocument();
    _operationsController.close();
    _cursorsController.close();
    _collaboratorsController.close();
  }
}