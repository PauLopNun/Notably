import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/offline_service.dart';

// Singleton provider for offline service
final offlineServiceProvider = Provider<OfflineService>((ref) {
  return OfflineService();
});

// Provider for connectivity status
final connectivityProvider = StreamProvider<bool>((ref) {
  final offlineService = ref.read(offlineServiceProvider);
  
  // Create a stream that emits connectivity status
  return Stream.periodic(const Duration(seconds: 1))
      .map((_) => offlineService.isOnline);
});

// Provider for cache statistics
final cacheStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final offlineService = ref.read(offlineServiceProvider);
  return offlineService.getCacheStats();
});

// Provider to initialize offline service
final offlineInitializationProvider = FutureProvider<void>((ref) async {
  final offlineService = ref.read(offlineServiceProvider);
  await offlineService.initialize();
});