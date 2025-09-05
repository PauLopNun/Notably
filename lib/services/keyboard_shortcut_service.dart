import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class KeyboardShortcutService {
  // Singleton instance
  static final KeyboardShortcutService _instance = KeyboardShortcutService._internal();
  factory KeyboardShortcutService() => _instance;
  KeyboardShortcutService._internal();

  // Shortcuts registry
  final Map<LogicalKeySet, VoidCallback> _shortcuts = {};
  final Map<String, LogicalKeySet> _namedShortcuts = {};

  // Initialize keyboard shortcuts
  void initialize() {
    // Register default shortcuts
    _registerDefaultShortcuts();
  }

  void _registerDefaultShortcuts() {
    // Note shortcuts
    _namedShortcuts['new_note'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyN,
    );
    
    _namedShortcuts['save_note'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyS,
    );
    
    _namedShortcuts['search'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyF,
    );
    
    _namedShortcuts['global_search'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyF,
    );

    // Editor shortcuts
    _namedShortcuts['bold'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyB,
    );
    
    _namedShortcuts['italic'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyI,
    );
    
    _namedShortcuts['underline'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyU,
    );
    
    _namedShortcuts['undo'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyZ,
    );
    
    _namedShortcuts['redo'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyZ,
    );

    // Block shortcuts
    _namedShortcuts['heading_1'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.digit1,
    );
    
    _namedShortcuts['heading_2'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.digit2,
    );
    
    _namedShortcuts['heading_3'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.digit3,
    );
    
    _namedShortcuts['bullet_list'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.digit8,
    );
    
    _namedShortcuts['numbered_list'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.digit7,
    );
    
    _namedShortcuts['code_block'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyC,
    );
    
    _namedShortcuts['quote_block'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyQ,
    );

    // Navigation shortcuts
    _namedShortcuts['go_to_home'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyH,
    );
    
    _namedShortcuts['toggle_sidebar'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.backslash,
    );
    
    _namedShortcuts['command_palette'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyP,
    );

    // Theme shortcuts
    _namedShortcuts['toggle_theme'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyT,
    );

    // Export shortcuts
    _namedShortcuts['export'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyE,
    );
    
    _namedShortcuts['print'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.keyP,
    );

    // Workspace shortcuts
    _namedShortcuts['new_page'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.keyN,
    );
    
    _namedShortcuts['delete_page'] = LogicalKeySet(
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.delete,
    );

    // Quick access shortcuts (function keys)
    _namedShortcuts['help'] = LogicalKeySet(LogicalKeyboardKey.f1);
    _namedShortcuts['rename'] = LogicalKeySet(LogicalKeyboardKey.f2);
    _namedShortcuts['refresh'] = LogicalKeySet(LogicalKeyboardKey.f5);
    _namedShortcuts['fullscreen'] = LogicalKeySet(LogicalKeyboardKey.f11);
  }

  // Register a shortcut with callback
  void registerShortcut(String name, VoidCallback callback) {
    final keySet = _namedShortcuts[name];
    if (keySet != null) {
      _shortcuts[keySet] = callback;
    }
  }

  // Unregister a shortcut
  void unregisterShortcut(String name) {
    final keySet = _namedShortcuts[name];
    if (keySet != null) {
      _shortcuts.remove(keySet);
    }
  }

  // Get all registered shortcuts for help display
  Map<String, LogicalKeySet> get namedShortcuts => Map.from(_namedShortcuts);

  // Get shortcuts map for Focus widget
  Map<LogicalKeySet, VoidCallback> get shortcuts => Map.from(_shortcuts);

  // Format keyboard shortcut for display
  String formatShortcut(LogicalKeySet keySet) {
    final keys = keySet.keys.toList();
    final parts = <String>[];

    // Check for modifier keys
    if (keys.contains(LogicalKeyboardKey.control)) {
      parts.add(kIsWeb || defaultTargetPlatform == TargetPlatform.windows 
          ? 'Ctrl' : '⌘');
    }
    if (keys.contains(LogicalKeyboardKey.shift)) {
      parts.add('Shift');
    }
    if (keys.contains(LogicalKeyboardKey.alt)) {
      parts.add('Alt');
    }
    if (keys.contains(LogicalKeyboardKey.meta)) {
      parts.add('Meta');
    }

    // Add main key
    for (final key in keys) {
      if (!_isModifierKey(key)) {
        parts.add(_formatKey(key));
      }
    }

    return parts.join(' + ');
  }

  bool _isModifierKey(LogicalKeyboardKey key) {
    return key == LogicalKeyboardKey.control ||
           key == LogicalKeyboardKey.shift ||
           key == LogicalKeyboardKey.alt ||
           key == LogicalKeyboardKey.meta;
  }

  String _formatKey(LogicalKeyboardKey key) {
    // Special keys
    if (key == LogicalKeyboardKey.backslash) return '\\';
    if (key == LogicalKeyboardKey.delete) return 'Del';
    if (key == LogicalKeyboardKey.f1) return 'F1';
    if (key == LogicalKeyboardKey.f2) return 'F2';
    if (key == LogicalKeyboardKey.f5) return 'F5';
    if (key == LogicalKeyboardKey.f11) return 'F11';
    
    // Number keys
    if (key == LogicalKeyboardKey.digit1) return '1';
    if (key == LogicalKeyboardKey.digit2) return '2';
    if (key == LogicalKeyboardKey.digit3) return '3';
    if (key == LogicalKeyboardKey.digit7) return '7';
    if (key == LogicalKeyboardKey.digit8) return '8';
    
    // Letter keys
    final label = key.keyLabel.toUpperCase();
    return label.isNotEmpty ? label : key.toString();
  }

  // Get shortcut description for help system
  String getShortcutDescription(String name) {
    switch (name) {
      case 'new_note': return 'Crear nueva nota';
      case 'save_note': return 'Guardar nota actual';
      case 'search': return 'Buscar en nota actual';
      case 'global_search': return 'Búsqueda global';
      case 'bold': return 'Texto en negrita';
      case 'italic': return 'Texto en cursiva';
      case 'underline': return 'Subrayar texto';
      case 'undo': return 'Deshacer';
      case 'redo': return 'Rehacer';
      case 'heading_1': return 'Encabezado 1';
      case 'heading_2': return 'Encabezado 2';
      case 'heading_3': return 'Encabezado 3';
      case 'bullet_list': return 'Lista con viñetas';
      case 'numbered_list': return 'Lista numerada';
      case 'code_block': return 'Bloque de código';
      case 'quote_block': return 'Bloque de cita';
      case 'go_to_home': return 'Ir al inicio';
      case 'toggle_sidebar': return 'Mostrar/ocultar barra lateral';
      case 'command_palette': return 'Paleta de comandos';
      case 'toggle_theme': return 'Cambiar tema';
      case 'export': return 'Exportar';
      case 'print': return 'Imprimir';
      case 'new_page': return 'Nueva página';
      case 'delete_page': return 'Eliminar página';
      case 'help': return 'Mostrar ayuda';
      case 'rename': return 'Renombrar';
      case 'refresh': return 'Actualizar';
      case 'fullscreen': return 'Pantalla completa';
      default: return name;
    }
  }

  // Clear all shortcuts
  void clearShortcuts() {
    _shortcuts.clear();
  }

  // Check if a shortcut is registered
  bool hasShortcut(String name) {
    final keySet = _namedShortcuts[name];
    return keySet != null && _shortcuts.containsKey(keySet);
  }
}