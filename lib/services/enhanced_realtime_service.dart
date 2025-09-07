import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/comment.dart';

class EnhancedRealtimeService {
  final SupabaseClient _client = Supabase.instance.client;

  // Page collaboration
  RealtimeChannel? _pageChannel;
  
  // Streams for different types of updates
  final _pageUpdatesController = StreamController<NotionPage>.broadcast();
  final _blockUpdatesController = StreamController<PageBlock>.broadcast();
  final _blockDeletedController = StreamController<String>.broadcast();
  final _commentsController = StreamController<Comment>.broadcast();
  final _userPresenceController = StreamController<List<UserPresence>>.broadcast();
  
  // Public streams
  Stream<NotionPage> get pageUpdates => _pageUpdatesController.stream;
  Stream<PageBlock> get blockUpdates => _blockUpdatesController.stream;
  Stream<String> get blockDeleted => _blockDeletedController.stream;
  Stream<Comment> get comments => _commentsController.stream;
  Stream<List<UserPresence>> get userPresence => _userPresenceController.stream;
  
  // User presence tracking
  final Map<String, UserPresence> _activeUsers = {};
  Timer? _presenceTimer;

  Future<void> joinPage({required String pageId, required String workspaceId}) async {
    await leave();
    
    // Create channel for this page
    _pageChannel = _client.channel('page:$pageId');

    // Listen for page updates
    _pageChannel!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'pages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq, 
        column: 'id', 
        value: pageId
      ),
      callback: (payload) => _handlePageUpdate(payload),
    );

    // Listen for block changes
    _pageChannel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'page_blocks',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq, 
        column: 'page_id', 
        value: pageId
      ),
      callback: (payload) => _handleBlockChange(payload),
    );

    // Listen for comments
    _pageChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'comments',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq, 
        column: 'page_id', 
        value: pageId
      ),
      callback: (payload) => _handleNewComment(payload),
    );

    // Handle user presence
    _pageChannel!.onPresenceSync((presences) => _handlePresenceSync(presences));
    _pageChannel!.onPresenceJoin((joins) => _handlePresenceJoin(joins));
    _pageChannel!.onPresenceLeave((leaves) => _handlePresenceLeave(leaves));

    _pageChannel!.subscribe();
    
    // Start presence tracking
    await _trackPresence();
  }

  // Send operations to other collaborators
  Future<void> broadcastBlockUpdate(PageBlock block) async {
    if (_pageChannel == null) return;
    
    try {
      await _pageChannel!.sendBroadcastMessage(
        event: 'block_update',
        payload: {
          'block': block.toJson(),
          'user_id': _client.auth.currentUser?.id,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('broadcastBlockUpdate error: $e');
      }
    }
  }
  
  Future<void> broadcastCursorPosition({
    required String blockId,
    required int position,
  }) async {
    if (_pageChannel == null) return;
    
    try {
      await _pageChannel!.sendBroadcastMessage(
        event: 'cursor_update',
        payload: {
          'block_id': blockId,
          'position': position,
          'user_id': _client.auth.currentUser?.id,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('broadcastCursorPosition error: $e');
      }
    }
  }

  Future<void> leave() async {
    try {
      _presenceTimer?.cancel();
      await _pageChannel?.unsubscribe();
    } catch (_) {}
    _pageChannel = null;
    _activeUsers.clear();
  }

  void dispose() {
    leave();
    _pageUpdatesController.close();
    _blockUpdatesController.close();
    _blockDeletedController.close();
    _commentsController.close();
    _userPresenceController.close();
  }
  
  // Private methods for handling real-time updates
  void _handlePageUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      final page = NotionPage.fromMap(newRecord);
      _pageUpdatesController.add(page);
        } catch (e) {
      if (kDebugMode) {
        print('_handlePageUpdate error: $e');
      }
    }
  }
  
  void _handleBlockChange(PostgresChangePayload payload) {
    try {
      if (payload.eventType == PostgresChangeEvent.delete) {
        final oldRecord = payload.oldRecord;
        _blockDeletedController.add(oldRecord['id']);
            } else {
        final newRecord = payload.newRecord;
        final block = PageBlock.fromMap(newRecord);
        _blockUpdatesController.add(block);
            }
    } catch (e) {
      if (kDebugMode) {
        print('_handleBlockChange error: $e');
      }
    }
  }
  
  void _handleNewComment(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      final comment = Comment.fromMap(newRecord);
      _commentsController.add(comment);
        } catch (e) {
      if (kDebugMode) {
        print('_handleNewComment error: $e');
      }
    }
  }
  
  void _handlePresenceSync(RealtimePresenceSyncPayload presences) {
    _activeUsers.clear();
    // Handle based on the actual payload structure from newer Supabase versions
    try {
      final presenceMap = presences as Map<String, dynamic>;
      presenceMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            final userPresence = UserPresence.fromMap(value);
            _activeUsers[key] = userPresence;
          } catch (e) {
            if (kDebugMode) print('Error parsing user presence: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error handling presence sync: $e');
    }
    _userPresenceController.add(_activeUsers.values.toList());
  }
  
  void _handlePresenceJoin(RealtimePresenceJoinPayload joins) {
    try {
      final joinMap = joins as Map<String, dynamic>;
      joinMap.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            final userPresence = UserPresence.fromMap(value);
            _activeUsers[key] = userPresence;
          } catch (e) {
            if (kDebugMode) print('Error parsing join presence: $e');
          }
        }
      });
    } catch (e) {
      if (kDebugMode) print('Error handling presence join: $e');
    }
    _userPresenceController.add(_activeUsers.values.toList());
  }
  
  void _handlePresenceLeave(RealtimePresenceLeavePayload leaves) {
    try {
      final leaveMap = leaves as Map<String, dynamic>;
      leaveMap.forEach((key, value) {
        _activeUsers.remove(key);
      });
    } catch (e) {
      if (kDebugMode) print('Error handling presence leave: $e');
    }
    _userPresenceController.add(_activeUsers.values.toList());
  }
  
  Future<void> _trackPresence() async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    
    // Send initial presence
    await _pageChannel?.track({
      'user_id': user.id,
      'email': user.email,
      'joined_at': DateTime.now().toIso8601String(),
      'cursor_position': null,
      'active_block': null,
    });
    
    // Send periodic heartbeat
    _presenceTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _pageChannel?.track({
        'user_id': user.id,
        'email': user.email,
        'last_seen': DateTime.now().toIso8601String(),
      });
    });
  }
}

// User presence model
class UserPresence {
  final String userId;
  final String? email;
  final DateTime? joinedAt;
  final DateTime? lastSeen;
  final String? activeBlock;
  final int? cursorPosition;
  
  UserPresence({
    required this.userId,
    this.email,
    this.joinedAt,
    this.lastSeen,
    this.activeBlock,
    this.cursorPosition,
  });
  
  factory UserPresence.fromMap(Map<String, dynamic> map) {
    return UserPresence(
      userId: map['user_id'] ?? '',
      email: map['email'],
      joinedAt: map['joined_at'] != null ? DateTime.parse(map['joined_at']) : null,
      lastSeen: map['last_seen'] != null ? DateTime.parse(map['last_seen']) : null,
      activeBlock: map['active_block'],
      cursorPosition: map['cursor_position'],
    );
  }
  
  bool get isActive {
    if (lastSeen == null) return joinedAt != null;
    return DateTime.now().difference(lastSeen!).inMinutes < 5;
  }
  
  String get displayName {
    if (email != null) {
      return email!.split('@').first;
    }
    return userId.substring(0, 8);
  }
}