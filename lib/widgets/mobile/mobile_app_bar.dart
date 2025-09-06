import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class MobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showThemeToggle;
  final VoidCallback? onMenuPressed;

  const MobileAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showThemeToggle = true,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    
    return AppBar(
      title: Text(title),
      leading: leading ?? (onMenuPressed != null 
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: onMenuPressed,
              tooltip: 'Abrir menú',
            )
          : null),
      actions: [
        ...?actions,
        if (showThemeToggle)
          IconButton(
            icon: Icon(_getThemeIcon(currentTheme)),
            onPressed: () => _showThemeSelector(context),
            tooltip: 'Cambiar tema',
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Más opciones',
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search',
              child: ListTile(
                leading: Icon(Icons.search),
                title: Text('Buscar'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Ayuda'),
                dense: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MobileThemeSelector(),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'search':
        // Implement search
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'help':
        // Show help
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MobileThemeSelector extends ConsumerWidget {
  const MobileThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Elegir Tema',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          _buildThemeOption(
            context: context,
            ref: ref,
            title: 'Automático',
            subtitle: 'Sigue la configuración del sistema',
            icon: Icons.brightness_auto,
            themeMode: AppThemeMode.system,
            isSelected: currentTheme == AppThemeMode.system,
          ),
          
          _buildThemeOption(
            context: context,
            ref: ref,
            title: 'Claro',
            subtitle: 'Tema claro siempre activo',
            icon: Icons.light_mode,
            themeMode: AppThemeMode.light,
            isSelected: currentTheme == AppThemeMode.light,
          ),
          
          _buildThemeOption(
            context: context,
            ref: ref,
            title: 'Oscuro',
            subtitle: 'Tema oscuro siempre activo',
            icon: Icons.dark_mode,
            themeMode: AppThemeMode.dark,
            isSelected: currentTheme == AppThemeMode.dark,
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required AppThemeMode themeMode,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected 
        ? Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          )
        : null,
      onTap: () {
        ref.read(themeNotifierProvider.notifier).setThemeMode(themeMode);
        Navigator.pop(context);
      },
    );
  }
}