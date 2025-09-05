import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/page.dart';
import '../services/page_service.dart';

class FavoritesNotifier extends StateNotifier<AsyncValue<List<NotionPage>>> {
  FavoritesNotifier(this._pageService) : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  final PageService _pageService;
  static const String _favoritesKey = 'favorite_pages';

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      
      if (favoriteIds.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final favoritePages = <NotionPage>[];
      for (final pageId in favoriteIds) {
        try {
          final page = await _pageService.getPage(pageId);
          if (page != null) {
            favoritePages.add(page);
          }
        } catch (e) {
          // Page might have been deleted, remove from favorites
          await _removeFavoriteId(pageId);
        }
      }

      state = AsyncValue.data(favoritePages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addToFavorites(NotionPage page) async {
    final currentState = state;
    if (currentState is! AsyncData<List<NotionPage>>) return;

    final currentFavorites = currentState.value;
    if (currentFavorites.any((p) => p.id == page.id)) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
      favoriteIds.add(page.id);
      await prefs.setStringList(_favoritesKey, favoriteIds);

      state = AsyncValue.data([...currentFavorites, page]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeFromFavorites(String pageId) async {
    final currentState = state;
    if (currentState is! AsyncData<List<NotionPage>>) return;

    try {
      await _removeFavoriteId(pageId);
      
      final currentFavorites = currentState.value;
      final updatedFavorites = currentFavorites.where((p) => p.id != pageId).toList();
      state = AsyncValue.data(updatedFavorites);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> _removeFavoriteId(String pageId) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList(_favoritesKey) ?? [];
    favoriteIds.remove(pageId);
    await prefs.setStringList(_favoritesKey, favoriteIds);
  }

  bool isFavorite(String pageId) {
    final currentState = state;
    if (currentState is! AsyncData<List<NotionPage>>) return false;
    return currentState.value.any((p) => p.id == pageId);
  }

  Future<void> toggleFavorite(NotionPage page) async {
    if (isFavorite(page.id)) {
      await removeFromFavorites(page.id);
    } else {
      await addToFavorites(page);
    }
  }

  Future<void> refresh() async {
    await _loadFavorites();
  }
}

class RecentPagesNotifier extends StateNotifier<AsyncValue<List<NotionPage>>> {
  RecentPagesNotifier(this._pageService) : super(const AsyncValue.loading()) {
    _loadRecentPages();
  }

  final PageService _pageService;
  static const String _recentPagesKey = 'recent_pages';
  static const int _maxRecentPages = 20;

  Future<void> _loadRecentPages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentData = prefs.getStringList(_recentPagesKey) ?? [];
      
      if (recentData.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }

      final recentPages = <NotionPage>[];
      final validData = <String>[];
      
      for (final dataString in recentData) {
        try {
          final parts = dataString.split('|');
          if (parts.length != 2) continue;
          
          final pageId = parts[0];
          final timestamp = int.tryParse(parts[1]);
          if (timestamp == null) continue;
          
          final page = await _pageService.getPage(pageId);
          if (page != null) {
            recentPages.add(page);
            validData.add(dataString);
          }
        } catch (e) {
          // Page might have been deleted, skip it
        }
      }

      // Update stored data to remove invalid entries
      if (validData.length != recentData.length) {
        await prefs.setStringList(_recentPagesKey, validData);
      }

      // Sort by timestamp (most recent first)
      recentPages.sort((a, b) {
        final aData = validData.firstWhere((d) => d.startsWith(a.id));
        final bData = validData.firstWhere((d) => d.startsWith(b.id));
        final aTimestamp = int.parse(aData.split('|')[1]);
        final bTimestamp = int.parse(bData.split('|')[1]);
        return bTimestamp.compareTo(aTimestamp);
      });

      state = AsyncValue.data(recentPages);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addRecentPage(NotionPage page) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentData = prefs.getStringList(_recentPagesKey) ?? [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newEntry = '${page.id}|$timestamp';

      // Remove existing entry for this page
      recentData.removeWhere((entry) => entry.startsWith('${page.id}|'));
      
      // Add new entry at the beginning
      recentData.insert(0, newEntry);
      
      // Limit the number of recent pages
      if (recentData.length > _maxRecentPages) {
        recentData.removeRange(_maxRecentPages, recentData.length);
      }

      await prefs.setStringList(_recentPagesKey, recentData);
      await _loadRecentPages(); // Reload to update the state
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeRecentPage(String pageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentData = prefs.getStringList(_recentPagesKey) ?? [];
      recentData.removeWhere((entry) => entry.startsWith('$pageId|'));
      await prefs.setStringList(_recentPagesKey, recentData);
      await _loadRecentPages();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearRecentPages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentPagesKey);
      state = const AsyncValue.data([]);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadRecentPages();
  }
}

// Providers
final pageServiceProvider = Provider<PageService>((ref) => PageService());

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<NotionPage>>>(
  (ref) => FavoritesNotifier(ref.read(pageServiceProvider)),
);

final recentPagesProvider = StateNotifierProvider<RecentPagesNotifier, AsyncValue<List<NotionPage>>>(
  (ref) => RecentPagesNotifier(ref.read(pageServiceProvider)),
);

// Helper providers
final isFavoriteProvider = Provider.family<bool, String>((ref, pageId) {
  final favoritesAsync = ref.watch(favoritesProvider);
  return favoritesAsync.when(
    data: (favorites) => favorites.any((page) => page.id == pageId),
    loading: () => false,
    error: (_, __) => false,
  );
});