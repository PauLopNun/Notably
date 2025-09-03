import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/enhanced_realtime_service.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/comment.dart';

final realtimeServiceProvider = Provider<EnhancedRealtimeService>((ref) => EnhancedRealtimeService());

final collaborationProvider = StateNotifierProvider<CollaborationNotifier, CollaborationState>((ref) {
  return CollaborationNotifier(ref.read(realtimeServiceProvider));
});

class CollaborationState {
  final List<UserPresence> activeUsers;
  final Map<String, DateTime> lastSeen;
  final bool isConnected;
  final String? currentPageId;

  const CollaborationState({
    this.activeUsers = const [],
    this.lastSeen = const {},
    this.isConnected = false,
    this.currentPageId,
  });

  CollaborationState copyWith({
    List<UserPresence>? activeUsers,
    Map<String, DateTime>? lastSeen,
    bool? isConnected,
    String? currentPageId,
  }) {
    return CollaborationState(
      activeUsers: activeUsers ?? this.activeUsers,
      lastSeen: lastSeen ?? this.lastSeen,
      isConnected: isConnected ?? this.isConnected,
      currentPageId: currentPageId ?? this.currentPageId,
    );
  }
}

class CollaborationNotifier extends StateNotifier<CollaborationState> {
  final EnhancedRealtimeService _realtimeService;

  CollaborationNotifier(this._realtimeService) : super(const CollaborationState()) {
    _initializeStreams();
  }

  void _initializeStreams() {
    // Listen to user presence updates
    _realtimeService.userPresence.listen((users) {
      state = state.copyWith(
        activeUsers: users,
        lastSeen: {
          for (final user in users)
            if (user.lastSeen != null)
              user.userId: user.lastSeen!
        },
      );
    });
  }

  Future<void> joinPage({required String pageId, required String workspaceId}) async {
    try {
      await _realtimeService.joinPage(pageId: pageId, workspaceId: workspaceId);
      state = state.copyWith(
        isConnected: true,
        currentPageId: pageId,
      );
    } catch (e) {
      state = state.copyWith(isConnected: false);
      rethrow;
    }
  }

  Future<void> leavePage() async {
    await _realtimeService.leave();
    state = state.copyWith(
      isConnected: false,
      currentPageId: null,
      activeUsers: [],
      lastSeen: {},
    );
  }

  Future<void> broadcastBlockUpdate(PageBlock block) async {
    if (state.isConnected) {
      await _realtimeService.broadcastBlockUpdate(block);
    }
  }

  Future<void> broadcastCursorPosition({
    required String blockId,
    required int position,
  }) async {
    if (state.isConnected) {
      await _realtimeService.broadcastCursorPosition(
        blockId: blockId,
        position: position,
      );
    }
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }
}

// Stream providers for real-time updates
final pageUpdatesStreamProvider = StreamProvider<NotionPage>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return realtimeService.pageUpdates;
});

final blockUpdatesStreamProvider = StreamProvider<PageBlock>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return realtimeService.blockUpdates;
});

final blockDeletedStreamProvider = StreamProvider<String>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return realtimeService.blockDeleted;
});

final commentsStreamProvider = StreamProvider<Comment>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return realtimeService.comments;
});

final userPresenceStreamProvider = StreamProvider<List<UserPresence>>((ref) {
  final realtimeService = ref.read(realtimeServiceProvider);
  return realtimeService.userPresence;
});