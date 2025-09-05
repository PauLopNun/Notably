import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/note.dart';
import '../models/page.dart';
import '../models/workspace.dart';

class OfflineService {
  static const String _notesKey = 'offline_notes';
  static const String _pagesKey = 'offline_pages';
  static const String _workspacesKey = 'offline_workspaces';
  static const String _pendingChangesKey = 'pending_changes';
  
  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  
  // Cache for quick access
  final Map<String, Note> _notesCache = {};
  final Map<String, NotionPage> _pagesCache = {};
  final Map<String, Workspace> _workspacesCache = {};
  final List<PendingChange> _pendingChanges = [];

  // Singleton instance
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal() {
    _initializeConnectivity();
  }

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  void _initializeConnectivity() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;
      
      if (wasOffline && _isOnline) {
        // Connection restored - sync pending changes
        _syncPendingChanges();
      }
    });

    // Check initial connectivity
    _connectivity.checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
    });
  }

  // Initialize offline storage
  Future<void> initialize() async {
    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Load notes
      final notesJson = prefs.getString(_notesKey);
      if (notesJson != null) {
        final notesList = jsonDecode(notesJson) as List<dynamic>;
        for (final noteData in notesList) {
          final note = Note.fromJson(noteData);
          _notesCache[note.id] = note;
        }
      }

      // Load pages
      final pagesJson = prefs.getString(_pagesKey);
      if (pagesJson != null) {
        final pagesList = jsonDecode(pagesJson) as List<dynamic>;
        for (final pageData in pagesList) {
          final page = NotionPage.fromJson(pageData);
          _pagesCache[page.id] = page;
        }
      }

      // Load workspaces
      final workspacesJson = prefs.getString(_workspacesKey);
      if (workspacesJson != null) {
        final workspacesList = jsonDecode(workspacesJson) as List<dynamic>;
        for (final workspaceData in workspacesList) {
          final workspace = Workspace.fromJson(workspaceData);
          _workspacesCache[workspace.id] = workspace;
        }
      }

      // Load pending changes
      final pendingJson = prefs.getString(_pendingChangesKey);
      if (pendingJson != null) {
        final pendingList = jsonDecode(pendingJson) as List<dynamic>;
        _pendingChanges.clear();
        _pendingChanges.addAll(
          pendingList.map((data) => PendingChange.fromJson(data)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading offline data: $e');
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      // Save notes
      final notesList = _notesCache.values.map((note) => note.toJson()).toList();
      await prefs.setString(_notesKey, jsonEncode(notesList));

      // Save pages
      final pagesList = _pagesCache.values.map((page) => page.toJson()).toList();
      await prefs.setString(_pagesKey, jsonEncode(pagesList));

      // Save workspaces
      final workspacesList = _workspacesCache.values.map((ws) => ws.toJson()).toList();
      await prefs.setString(_workspacesKey, jsonEncode(workspacesList));

      // Save pending changes
      final pendingList = _pendingChanges.map((change) => change.toJson()).toList();
      await prefs.setString(_pendingChangesKey, jsonEncode(pendingList));
    } catch (e) {
      debugPrint('Error saving offline data: $e');
    }
  }

  // Note operations
  Future<void> cacheNote(Note note) async {
    _notesCache[note.id] = note;
    await _saveToStorage();
  }

  Future<void> cacheNotes(List<Note> notes) async {
    for (final note in notes) {
      _notesCache[note.id] = note;
    }
    await _saveToStorage();
  }

  Future<Note?> getCachedNote(String id) async {
    return _notesCache[id];
  }

  Future<List<Note>> getAllCachedNotes() async {
    return _notesCache.values.toList();
  }

  Future<void> removeNote(String id) async {
    _notesCache.remove(id);
    await _saveToStorage();
    
    if (isOffline) {
      _addPendingChange(PendingChange(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ChangeType.delete,
        entityType: EntityType.note,
        entityId: id,
        timestamp: DateTime.now(),
      ));
    }
  }

  // Page operations
  Future<void> cachePage(NotionPage page) async {
    _pagesCache[page.id] = page;
    await _saveToStorage();
  }

  Future<void> cachePages(List<NotionPage> pages) async {
    for (final page in pages) {
      _pagesCache[page.id] = page;
    }
    await _saveToStorage();
  }

  Future<NotionPage?> getCachedPage(String id) async {
    return _pagesCache[id];
  }

  Future<List<NotionPage>> getCachedPagesForWorkspace(String workspaceId) async {
    return _pagesCache.values
        .where((page) => page.workspaceId == workspaceId)
        .toList();
  }

  // Workspace operations
  Future<void> cacheWorkspace(Workspace workspace) async {
    _workspacesCache[workspace.id] = workspace;
    await _saveToStorage();
  }

  Future<void> cacheWorkspaces(List<Workspace> workspaces) async {
    for (final workspace in workspaces) {
      _workspacesCache[workspace.id] = workspace;
    }
    await _saveToStorage();
  }

  Future<List<Workspace>> getAllCachedWorkspaces() async {
    return _workspacesCache.values.toList();
  }

  // Offline change tracking
  Future<void> recordOfflineChange({
    required String entityId,
    required EntityType entityType,
    required ChangeType changeType,
    Map<String, dynamic>? data,
  }) async {
    if (isOffline) {
      final change = PendingChange(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: changeType,
        entityType: entityType,
        entityId: entityId,
        data: data,
        timestamp: DateTime.now(),
      );
      
      _addPendingChange(change);
      await _saveToStorage();
    }
  }

  void _addPendingChange(PendingChange change) {
    // Remove any existing changes for the same entity to avoid duplicates
    _pendingChanges.removeWhere((existing) => 
        existing.entityType == change.entityType &&
        existing.entityId == change.entityId);
    
    _pendingChanges.add(change);
  }

  Future<void> _syncPendingChanges() async {
    if (_pendingChanges.isEmpty) return;

    debugPrint('Syncing ${_pendingChanges.length} pending changes...');
    
    // Sort changes by timestamp to maintain order
    _pendingChanges.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final failedChanges = <PendingChange>[];
    
    for (final change in _pendingChanges) {
      try {
        await _applySingleChange(change);
        debugPrint('Successfully synced change: ${change.type} ${change.entityType} ${change.entityId}');
      } catch (e) {
        debugPrint('Failed to sync change: $e');
        failedChanges.add(change);
      }
    }
    
    // Keep only failed changes
    _pendingChanges.clear();
    _pendingChanges.addAll(failedChanges);
    
    await _saveToStorage();
    
    if (failedChanges.isEmpty) {
      debugPrint('All pending changes synced successfully');
    } else {
      debugPrint('${failedChanges.length} changes failed to sync');
    }
  }

  Future<void> _applySingleChange(PendingChange change) async {
    // This would integrate with your actual API service
    // For now, we'll just simulate the operation
    switch (change.entityType) {
      case EntityType.note:
        await _syncNoteChange(change);
        break;
      case EntityType.page:
        await _syncPageChange(change);
        break;
      case EntityType.workspace:
        await _syncWorkspaceChange(change);
        break;
    }
  }

  Future<void> _syncNoteChange(PendingChange change) async {
    // Integrate with NoteService here
    // Example implementation would call the appropriate API
    switch (change.type) {
      case ChangeType.create:
      case ChangeType.update:
        // Update note on server
        break;
      case ChangeType.delete:
        // Delete note on server
        break;
    }
  }

  Future<void> _syncPageChange(PendingChange change) async {
    // Integrate with PageService here
  }

  Future<void> _syncWorkspaceChange(PendingChange change) async {
    // Integrate with WorkspaceService here
  }

  // Search functionality for offline mode
  Future<List<Note>> searchCachedNotes(String query) async {
    if (query.isEmpty) return getAllCachedNotes();
    
    final lowercaseQuery = query.toLowerCase();
    return _notesCache.values.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
             note.content.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<NotionPage>> searchCachedPages(String query) async {
    if (query.isEmpty) return _pagesCache.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _pagesCache.values.where((page) {
      return page.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Clear all cached data
  Future<void> clearCache() async {
    _notesCache.clear();
    _pagesCache.clear();
    _workspacesCache.clear();
    _pendingChanges.clear();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notesKey);
    await prefs.remove(_pagesKey);
    await prefs.remove(_workspacesKey);
    await prefs.remove(_pendingChangesKey);
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'notes_count': _notesCache.length,
      'pages_count': _pagesCache.length,
      'workspaces_count': _workspacesCache.length,
      'pending_changes': _pendingChanges.length,
      'is_online': _isOnline,
    };
  }
}

// Data models for pending changes
enum ChangeType { create, update, delete }
enum EntityType { note, page, workspace }

class PendingChange {
  final String id;
  final ChangeType type;
  final EntityType entityType;
  final String entityId;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  const PendingChange({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    this.data,
    required this.timestamp,
  });

  factory PendingChange.fromJson(Map<String, dynamic> json) {
    return PendingChange(
      id: json['id'] as String,
      type: ChangeType.values.firstWhere((e) => e.name == json['type']),
      entityType: EntityType.values.firstWhere((e) => e.name == json['entityType']),
      entityId: json['entityId'] as String,
      data: json['data'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'entityType': entityType.name,
      'entityId': entityId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}