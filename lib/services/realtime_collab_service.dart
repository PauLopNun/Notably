import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeCollabService {
  final SupabaseClient _client = Supabase.instance.client;

  RealtimeChannel? _channel;
  String? _docId;
  final _incomingContentController = StreamController<List<dynamic>>.broadcast();
  Stream<List<dynamic>> get incomingContentStream => _incomingContentController.stream;

  Future<void> joinDocument(String documentId) async {
    await leave();
    _docId = documentId;
    _channel = _client.channel('public:notes');

    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'notes',
      filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: documentId),
      callback: (payload) {
        try {
          final record = payload.newRecord;
          if (record['content'] != null) {
            final contentRaw = record['content'];
            final List<dynamic> content = contentRaw is String ? jsonDecode(contentRaw) : (contentRaw as List<dynamic>);
            _incomingContentController.add(content);
          }
        } catch (e) {
          if (kDebugMode) {
            print('onPostgresChanges parse error: $e');
          }
        }
      },
    );

    _channel!.subscribe();
  }

  Future<void> sendFullContent(List<dynamic> content) async {
    final id = _docId;
    if (id == null) return;
    try {
      await _client
          .from('notes')
          .update({'content': jsonEncode(content), 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('sendFullContent error: $e');
      }
    }
  }

  Future<void> leave() async {
    try {
      await _channel?.unsubscribe();
    } catch (_) {}
    _channel = null;
    _docId = null;
  }

  void dispose() async {
    try {
      await leave();

      if (!_incomingContentController.isClosed) {
        await _incomingContentController.close();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing realtime collaboration service: $e');
      }
    }
  }
}


