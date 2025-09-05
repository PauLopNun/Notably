import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/keyboard_shortcut_service.dart';

// Singleton provider for keyboard shortcut service
final keyboardShortcutServiceProvider = Provider<KeyboardShortcutService>((ref) {
  final service = KeyboardShortcutService();
  service.initialize();
  return service;
});

// Provider for shortcuts state
final shortcutsProvider = StateNotifierProvider<ShortcutsNotifier, Map<String, bool>>((ref) {
  return ShortcutsNotifier(ref.read(keyboardShortcutServiceProvider));
});

class ShortcutsNotifier extends StateNotifier<Map<String, bool>> {
  final KeyboardShortcutService _shortcutService;

  ShortcutsNotifier(this._shortcutService) : super({});

  void registerShortcut(String name, Function() callback) {
    _shortcutService.registerShortcut(name, callback);
    state = {...state, name: true};
  }

  void unregisterShortcut(String name) {
    _shortcutService.unregisterShortcut(name);
    state = {...state, name: false};
  }

  bool isShortcutRegistered(String name) {
    return _shortcutService.hasShortcut(name);
  }

  void clearShortcuts() {
    _shortcutService.clearShortcuts();
    state = {};
  }
}