import 'package:flutter/material.dart';
import '../models/workspace_member.dart';
import '../services/webrtc_service.dart';

class CollaborationToolbar extends StatelessWidget {
  final List<WorkspaceMember> activeUsers;
  final WebRtcConnectionState connectionState;
  final VoidCallback onInviteUser;

  const CollaborationToolbar({
    super.key,
    required this.activeUsers,
    required this.connectionState,
    required this.onInviteUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Connection status
          _buildConnectionStatus(context),

          const SizedBox(width: 16),

          // Active collaborators
          Expanded(
            child: _buildActiveCollaborators(context),
          ),

          // Actions
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    IconData icon;
    Color color;
    String status;

    switch (connectionState) {
      case WebRtcConnectionState.connected:
        icon = Icons.wifi;
        color = Colors.green;
        status = 'Conectado';
        break;
      case WebRtcConnectionState.connecting:
        icon = Icons.wifi_off;
        color = Colors.orange;
        status = 'Conectando...';
        break;
      case WebRtcConnectionState.disconnected:
        icon = Icons.wifi_off;
        color = Colors.grey;
        status = 'Desconectado';
        break;
      case WebRtcConnectionState.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        status = 'Error de conexión';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          status,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCollaborators(BuildContext context) {
    if (activeUsers.isEmpty) {
      return Text(
        'Solo tú',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      );
    }

    return Row(
      children: [
        Text(
          'Colaborando: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // User avatars
                ...activeUsers.take(5).map((user) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Tooltip(
                    message: '${user.name} (${user.role.displayName})',
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: _getUserColor(user.userId),
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                )),

                // More indicator
                if (activeUsers.length > 5)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+${activeUsers.length - 5}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Share/Invite button
        IconButton(
          onPressed: onInviteUser,
          icon: const Icon(Icons.person_add_outlined),
          tooltip: 'Invitar colaborador',
          visualDensity: VisualDensity.compact,
        ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Más opciones',
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'permissions',
              child: Row(
                children: [
                  Icon(Icons.security_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Gestionar permisos'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history, size: 18),
                  SizedBox(width: 8),
                  Text('Historial de cambios'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'comments',
              child: Row(
                children: [
                  Icon(Icons.comment_outlined, size: 18),
                  SizedBox(width: 8),
                  Text('Comentarios'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'leave',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Salir de colaboración', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, value),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'permissions':
        _showPermissionsDialog(context);
        break;
      case 'history':
        _showHistoryDialog(context);
        break;
      case 'comments':
        _showCommentsPanel(context);
        break;
      case 'leave':
        _showLeaveConfirmation(context);
        break;
    }
  }

  void _showPermissionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar permisos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Gestiona los permisos de los colaboradores:'),
            const SizedBox(height: 16),
            ...activeUsers.map((user) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _getUserColor(user.userId),
                child: Text(user.name[0].toUpperCase()),
              ),
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: DropdownButton<MemberRole>(
                value: user.role,
                items: MemberRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.displayName),
                  );
                }).toList(),
                onChanged: (role) {
                  // TODO: Implement role change
                },
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Historial de cambios'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Center(
            child: Text('Funcionalidad en desarrollo'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showCommentsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: const [
                    Center(
                      child: Text('No hay comentarios aún'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salir de colaboración'),
        content: const Text(
          '¿Estás seguro de que quieres salir de la sesión de colaboración? '
          'Podrás volver a unirte en cualquier momento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement leave collaboration
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  Color _getUserColor(String userId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];

    final index = userId.hashCode % colors.length;
    return colors[index.abs()];
  }
}