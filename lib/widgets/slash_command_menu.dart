import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SlashCommandMenu extends StatefulWidget {
  final Function(String) onCommandSelected;
  final VoidCallback onCancel;
  final Offset position;

  const SlashCommandMenu({
    super.key,
    required this.onCommandSelected,
    required this.onCancel,
    required this.position,
  });

  @override
  State<SlashCommandMenu> createState() => _SlashCommandMenuState();
}

class _SlashCommandMenuState extends State<SlashCommandMenu> {
  final List<SlashCommand> _commands = [
    SlashCommand(
      name: 'Heading 1',
      description: 'Big section heading',
      icon: Icons.format_size,
      command: 'h1',
    ),
    SlashCommand(
      name: 'Heading 2',
      description: 'Medium section heading',
      icon: Icons.format_size,
      command: 'h2',
    ),
    SlashCommand(
      name: 'Heading 3',
      description: 'Small section heading',
      icon: Icons.format_size,
      command: 'h3',
    ),
    SlashCommand(
      name: 'Paragraph',
      description: 'Plain text',
      icon: Icons.subject,
      command: 'paragraph',
    ),
    SlashCommand(
      name: 'Bulleted list',
      description: 'Create a simple bulleted list',
      icon: Icons.format_list_bulleted,
      command: 'bulleted-list',
    ),
    SlashCommand(
      name: 'Numbered list',
      description: 'Create a list with numbering',
      icon: Icons.format_list_numbered,
      command: 'numbered-list',
    ),
    SlashCommand(
      name: 'To-do list',
      description: 'Track tasks with a to-do list',
      icon: Icons.check_box_outlined,
      command: 'todo-list',
    ),
    SlashCommand(
      name: 'Quote',
      description: 'Capture a quote',
      icon: Icons.format_quote,
      command: 'quote',
    ),
    SlashCommand(
      name: 'Divider',
      description: 'Visually divide blocks',
      icon: Icons.horizontal_rule,
      command: 'divider',
    ),
    SlashCommand(
      name: 'Code',
      description: 'Capture a code snippet',
      icon: Icons.code,
      command: 'code',
    ),
    SlashCommand(
      name: 'Callout',
      description: 'Make writing stand out',
      icon: Icons.info_outline,
      command: 'callout',
    ),
    SlashCommand(
      name: 'Table',
      description: 'Add a table',
      icon: Icons.table_chart,
      command: 'table',
    ),
  ];

  final String _searchQuery = '';
  int _selectedIndex = 0;

  List<SlashCommand> get _filteredCommands {
    if (_searchQuery.isEmpty) return _commands;
    return _commands.where((command) {
      return command.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             command.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCommands = _filteredCommands;

    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
        shadowColor: theme.shadowColor.withValues(alpha: 0.2),
        child: Container(
          width: 320,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add a block',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              // Commands list
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filteredCommands.length,
                  itemBuilder: (context, index) {
                    final command = filteredCommands[index];
                    final isSelected = index == _selectedIndex;

                    return InkWell(
                      onTap: () => widget.onCommandSelected(command.command),
                      onHover: (hovering) {
                        if (hovering) {
                          setState(() => _selectedIndex = index);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        color: isSelected
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                            : null,
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                command.icon,
                                size: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    command.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    command.description,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected) ...[
                              Icon(
                                Icons.keyboard_return,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ).animate(delay: (index * 20).ms).slideX(
                      begin: -0.1,
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ).fadeIn(duration: 200.ms);
                  },
                ),
              ),

              // Footer hint
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Type to filter, ↑↓ to navigate, ↵ to select',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(
        begin: const Offset(0.9, 0.9),
        duration: 150.ms,
        curve: Curves.easeOut,
      ).fadeIn(duration: 150.ms),
    );
  }
}

class SlashCommand {
  final String name;
  final String description;
  final IconData icon;
  final String command;

  SlashCommand({
    required this.name,
    required this.description,
    required this.icon,
    required this.command,
  });
}