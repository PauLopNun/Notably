import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/keyboard_shortcut_provider.dart';

class KeyboardShortcutsHelp extends ConsumerWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutService = ref.read(keyboardShortcutServiceProvider);
    
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Atajos de Teclado',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Acelera tu flujo de trabajo con estos atajos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'Notas',
                      Icons.note_outlined,
                      [
                        'new_note',
                        'save_note',
                        'search',
                        'global_search',
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'Editor de Texto',
                      Icons.edit_outlined,
                      [
                        'bold',
                        'italic',
                        'underline',
                        'undo',
                        'redo',
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'Bloques',
                      Icons.view_agenda_outlined,
                      [
                        'heading_1',
                        'heading_2',
                        'heading_3',
                        'bullet_list',
                        'numbered_list',
                        'code_block',
                        'quote_block',
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'Navegación',
                      Icons.navigation_outlined,
                      [
                        'go_to_home',
                        'toggle_sidebar',
                        'command_palette',
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'Páginas',
                      Icons.description_outlined,
                      [
                        'new_page',
                        'delete_page',
                        'export',
                        'print',
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildShortcutCategory(
                      context,
                      shortcutService,
                      'General',
                      Icons.settings_outlined,
                      [
                        'toggle_theme',
                        'help',
                        'rename',
                        'refresh',
                        'fullscreen',
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los atajos están disponibles en toda la aplicación cuando el contexto lo permite',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutCategory(
    BuildContext context,
    dynamic shortcutService,
    String title,
    IconData icon,
    List<String> shortcuts,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...shortcuts.map((shortcutName) {
              final keySet = shortcutService.namedShortcuts[shortcutName];
              if (keySet == null) return const SizedBox.shrink();
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        shortcutService.getShortcutDescription(shortcutName),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        shortcutService.formatShortcut(keySet),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Command palette widget for quick actions
class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shortcutService = ref.read(keyboardShortcutServiceProvider);
    final filteredCommands = _getFilteredCommands(shortcutService);

    return Dialog(
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search field
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withAlpha(100),
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Buscar comandos...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),

            // Commands list
            Expanded(
              child: ListView.builder(
                itemCount: filteredCommands.length,
                itemBuilder: (context, index) {
                  final command = filteredCommands[index];
                  return ListTile(
                    leading: Icon(command['icon'] as IconData),
                    title: Text(command['title'] as String),
                    subtitle: command['subtitle'] != null 
                        ? Text(command['subtitle'] as String)
                        : null,
                    trailing: command['shortcut'] != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              command['shortcut'] as String,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.of(context).pop();
                      (command['action'] as VoidCallback?)?.call();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredCommands(dynamic shortcutService) {
    final allCommands = [
      {
        'title': 'Nueva Nota',
        'subtitle': 'Crear una nueva nota',
        'icon': Icons.note_add,
        'shortcut': shortcutService.formatShortcut(shortcutService.namedShortcuts['new_note']),
        'action': () {/* Add action */},
      },
      {
        'title': 'Buscar',
        'subtitle': 'Buscar en la nota actual',
        'icon': Icons.search,
        'shortcut': shortcutService.formatShortcut(shortcutService.namedShortcuts['search']),
        'action': () {/* Add action */},
      },
      {
        'title': 'Cambiar Tema',
        'subtitle': 'Alternar entre tema claro y oscuro',
        'icon': Icons.palette,
        'shortcut': shortcutService.formatShortcut(shortcutService.namedShortcuts['toggle_theme']),
        'action': () {/* Add action */},
      },
      {
        'title': 'Ayuda',
        'subtitle': 'Mostrar atajos de teclado',
        'icon': Icons.help_outline,
        'shortcut': shortcutService.formatShortcut(shortcutService.namedShortcuts['help']),
        'action': () {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            builder: (context) => const KeyboardShortcutsHelp(),
          );
        },
      },
    ];

    if (_searchQuery.isEmpty) {
      return allCommands;
    }

    return allCommands.where((command) {
      return (command['title'] as String).toLowerCase().contains(_searchQuery) ||
             (command['subtitle'] as String).toLowerCase().contains(_searchQuery);
    }).toList();
  }
}