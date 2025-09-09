import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WorkspaceSelector extends StatefulWidget {
  const WorkspaceSelector({super.key});

  @override
  State<WorkspaceSelector> createState() => _WorkspaceSelectorState();
}

class _WorkspaceSelectorState extends State<WorkspaceSelector> {
  bool _isExpanded = false;
  final List<Workspace> _workspaces = [
    Workspace(
      id: '1',
      name: 'Notably Workspace',
      icon: '🏢',
      isPersonal: true,
    ),
    Workspace(
      id: '2',
      name: 'Personal Projects',
      icon: '🚀',
      isPersonal: true,
    ),
    Workspace(
      id: '3',
      name: 'Team Collaboration',
      icon: '👥',
      isPersonal: false,
      members: 5,
    ),
  ];

  Workspace get _currentWorkspace => _workspaces[0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = Supabase.instance.client.auth.currentUser;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Workspace Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _currentWorkspace.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Workspace Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentWorkspace.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user?.email ?? 'Guest User',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Expand/Collapse Icon
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Workspace Dropdown
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: _isExpanded ? 200 : 0,
          child: _isExpanded
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      // Current workspaces list
                      ..._workspaces.asMap().entries.map((entry) {
                        final index = entry.key;
                        final workspace = entry.value;
                        final isSelected = workspace.id == _currentWorkspace.id;
                        
                        return _buildWorkspaceItem(
                          theme,
                          workspace,
                          isSelected,
                          index,
                        );
                      }),
                      
                      // Divider
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      
                      // Actions
                      _buildActionItem(
                        theme,
                        icon: Icons.add,
                        title: 'Create workspace',
                        onTap: _createWorkspace,
                      ),
                      _buildActionItem(
                        theme,
                        icon: Icons.group_add,
                        title: 'Join workspace',
                        onTap: _joinWorkspace,
                      ),
                      _buildActionItem(
                        theme,
                        icon: Icons.settings,
                        title: 'Settings & members',
                        onTap: _openSettings,
                      ),
                      
                      const SizedBox(height: 4),
                    ],
                    ),
                  ),
                ).animate().slideY(
                  begin: -0.1,
                  duration: 250.ms,
                  curve: Curves.easeOut,
                ).fadeIn(duration: 200.ms)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildWorkspaceItem(
    ThemeData theme,
    Workspace workspace,
    bool isSelected,
    int index,
  ) {
    return InkWell(
      onTap: () => _selectWorkspace(workspace),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            // Workspace Icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  workspace.icon,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Workspace Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          workspace.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!workspace.isPersonal && workspace.members != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${workspace.members}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        workspace.isPersonal ? Icons.person : Icons.people,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        workspace.isPersonal ? 'Personal' : 'Team',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Selected Indicator
            if (isSelected) ...[
              Icon(
                Icons.check,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    ).animate(delay: (index * 50).ms).slideX(
      begin: -0.1,
      duration: 200.ms,
    ).fadeIn();
  }

  Widget _buildActionItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectWorkspace(Workspace workspace) {
    setState(() => _isExpanded = false);
    // TODO: Implement workspace switching logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${workspace.name}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _createWorkspace() {
    setState(() => _isExpanded = false);
    _showCreateWorkspaceDialog();
  }

  void _joinWorkspace() {
    setState(() => _isExpanded = false);
    _showJoinWorkspaceDialog();
  }

  void _openSettings() {
    setState(() => _isExpanded = false);
    Navigator.of(context).pushNamed('/settings');
  }

  void _showCreateWorkspaceDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Workspace name',
                hintText: 'e.g. Marketing Team',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can invite team members after creating',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createNewWorkspace(nameController.text);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showJoinWorkspaceDialog() {
    final inviteController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join workspace'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: inviteController,
              decoration: const InputDecoration(
                labelText: 'Invitation link or code',
                hintText: 'Paste your invitation link here',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.link, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Get an invitation from a workspace member',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _joinWorkspaceWithCode(inviteController.text);
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _createNewWorkspace(String name) {
    if (name.trim().isEmpty) return;
    
    // TODO: Implement workspace creation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Created workspace "$name"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _joinWorkspaceWithCode(String code) {
    if (code.trim().isEmpty) return;
    
    // TODO: Implement workspace joining
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining workspace...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class Workspace {
  final String id;
  final String name;
  final String icon;
  final bool isPersonal;
  final int? members;

  Workspace({
    required this.id,
    required this.name,
    required this.icon,
    required this.isPersonal,
    this.members,
  });
}