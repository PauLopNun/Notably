import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileBottomNavigation extends ConsumerStatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MobileBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  ConsumerState<MobileBottomNavigation> createState() => _MobileBottomNavigationState();
}

class _MobileBottomNavigationState extends ConsumerState<MobileBottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: widget.currentIndex,
      onDestinationSelected: widget.onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.folder_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'Espacios',
        ),
        NavigationDestination(
          icon: Icon(Icons.note_outlined),
          selectedIcon: Icon(Icons.note),
          label: 'Notas',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
      ],
    );
  }
}

// Mobile-optimized floating action button with speed dial
class MobileFAB extends ConsumerStatefulWidget {
  const MobileFAB({super.key});

  @override
  ConsumerState<MobileFAB> createState() => _MobileFABState();
}

class _MobileFABState extends ConsumerState<MobileFAB> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Backdrop
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withAlpha(100),
            ),
          ),
        
        // Speed dial buttons
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_animation.value > 0.0) ...[
                  Transform.scale(
                    scale: _animation.value,
                    child: _buildSpeedDialButton(
                      icon: Icons.note_add,
                      label: 'Nueva Nota',
                      onPressed: () {
                        _toggle();
                        _createNote();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Transform.scale(
                    scale: _animation.value,
                    child: _buildSpeedDialButton(
                      icon: Icons.description,
                      label: 'Nueva Página',
                      onPressed: () {
                        _toggle();
                        _createPage();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Transform.scale(
                    scale: _animation.value,
                    child: _buildSpeedDialButton(
                      icon: Icons.folder,
                      label: 'Nuevo Espacio',
                      onPressed: () {
                        _toggle();
                        _createWorkspace();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Main FAB
                FloatingActionButton(
                  onPressed: _toggle,
                  child: AnimatedRotation(
                    turns: _animation.value * 0.125, // 45 degrees
                    child: Icon(_isOpen ? Icons.close : Icons.add),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSpeedDialButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ],
    );
  }

  void _createNote() {
    // Navigate to create note
    Navigator.pushNamed(context, '/editor');
  }

  void _createPage() {
    // Navigate to create page
    // Navigator.pushNamed(context, '/page-editor');
  }

  void _createWorkspace() {
    // Show create workspace dialog
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const CreateWorkspaceBottomSheet(),
    );
  }
}

// Bottom sheet for creating workspace on mobile
class CreateWorkspaceBottomSheet extends StatefulWidget {
  const CreateWorkspaceBottomSheet({super.key});

  @override
  State<CreateWorkspaceBottomSheet> createState() => _CreateWorkspaceBottomSheetState();
}

class _CreateWorkspaceBottomSheetState extends State<CreateWorkspaceBottomSheet> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedIcon = '📁';

  final List<String> _icons = [
    '📁', '📚', '💼', '🎨', '🔬', '📊', '💻', '🎵', 
    '🏠', '🎯', '💡', '🚀', '⚡', '🔥', '💎', '🌟'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'Nuevo Espacio de Trabajo',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre del espacio',
                hintText: 'Ej: Mi Proyecto',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                hintText: 'Breve descripción...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Icon selection
            Text(
              'Ícono',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = icon;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected 
                        ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                        : null,
                    ),
                    child: Center(
                      child: Text(
                        icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _nameController.text.isNotEmpty ? _createWorkspace : null,
                    child: const Text('Crear'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _createWorkspace() {
    // Create workspace logic here
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Espacio "${_nameController.text}" creado'),
      ),
    );
  }
}