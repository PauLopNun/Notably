import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/note.dart';
import '../services/collaboration_service.dart';

class CollaborationPanel extends StatefulWidget {
  final Note note;
  final VoidCallback onClose;

  const CollaborationPanel({
    super.key,
    required this.note,
    required this.onClose,
  });

  @override
  State<CollaborationPanel> createState() => _CollaborationPanelState();
}

class _CollaborationPanelState extends State<CollaborationPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  final CollaborationService _collaborationService = CollaborationService();
  
  bool _isInviting = false;
  List<Map<String, dynamic>> _collaborators = [];
  // TODO: Implement pending invitations
  // List<Map<String, dynamic>> _pendingInvitations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCollaborators();
    _loadPendingInvitations();
  }

  Future<void> _loadCollaborators() async {
    final collaborators = await _collaborationService.getCollaborators(widget.note.id);
    if (mounted) {
      setState(() => _collaborators = collaborators);
    }
  }

  Future<void> _loadPendingInvitations() async {
    final invitations = await _collaborationService.getPendingInvitations();
    if (mounted) {
      // TODO: Implement pending invitations state management
      // setState(() => _pendingInvitations = invitations);
    }
  }

  Future<void> _inviteCollaborator() async {
    if (_emailController.text.trim().isEmpty) return;

    setState(() => _isInviting = true);

    try {
      await _collaborationService.inviteCollaborator(
        widget.note.id,
        _emailController.text.trim(),
      );
      
      _emailController.clear();
      _showSnackBar('Invitation sent successfully!', isError: false);
      _loadCollaborators();
    } catch (e) {
      _showSnackBar('Error sending invitation: $e', isError: true);
    } finally {
      setState(() => _isInviting = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 380,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInviteTab(theme),
                _buildCollaboratorsTab(theme),
                _buildSettingsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.people_outline,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Collaborate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Invite others to edit together',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            tooltip: 'Close collaboration panel',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    ).animate().slideX(begin: 0.1, duration: 300.ms).fadeIn();
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Invite'),
          Tab(text: 'Members'),
          Tab(text: 'Settings'),
        ],
        labelStyle: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.bodySmall,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildInviteTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invite by email',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'People you invite will be able to edit this page',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Email input
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Enter email address',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              suffixIcon: _isInviting
                  ? Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send, size: 20),
                      onPressed: _inviteCollaborator,
                    ),
            ),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _inviteCollaborator(),
          ),
          const SizedBox(height: 24),

          // Quick share options
          Text(
            'Quick share',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildShareOption(
            theme,
            icon: Icons.link,
            title: 'Copy link',
            subtitle: 'Anyone with the link can view',
            onTap: _copyShareLink,
          ),
          const SizedBox(height: 8),
          
          _buildShareOption(
            theme,
            icon: Icons.public,
            title: 'Publish to web',
            subtitle: 'Make this page public on the web',
            onTap: _publishToWeb,
          ),
          const SizedBox(height: 8),
          
          _buildShareOption(
            theme,
            icon: Icons.qr_code,
            title: 'QR Code',
            subtitle: 'Generate QR code for easy sharing',
            onTap: _generateQRCode,
          ),
        ],
      ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(delay: 100.ms),
    );
  }

  Widget _buildCollaboratorsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_collaborators.isEmpty) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No collaborators yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Invite people to start collaborating',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
          ] else ...[
            Text(
              '${_collaborators.length} collaborator${_collaborators.length == 1 ? '' : 's'}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ..._collaborators.asMap().entries.map((entry) {
              final index = entry.key;
              final collaborator = entry.value;
              return _buildCollaboratorItem(theme, collaborator)
                  .animate(delay: (index * 100).ms)
                  .slideX(begin: -0.1, duration: 300.ms)
                  .fadeIn();
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Page permissions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildPermissionOption(
            theme,
            icon: Icons.edit,
            title: 'Can edit',
            subtitle: 'Collaborators can make changes',
            isSelected: true,
          ),
          const SizedBox(height: 8),
          
          _buildPermissionOption(
            theme,
            icon: Icons.visibility,
            title: 'Can view',
            subtitle: 'Collaborators can only view',
            isSelected: false,
          ),
          const SizedBox(height: 24),

          Text(
            'Advanced',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildAdvancedOption(
            theme,
            icon: Icons.history,
            title: 'Version history',
            subtitle: 'View all changes made to this page',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          
          _buildAdvancedOption(
            theme,
            icon: Icons.backup,
            title: 'Export backup',
            subtitle: 'Download a copy of this page',
            onTap: () {},
          ),
        ],
      ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(delay: 200.ms),
    );
  }

  Widget _buildShareOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollaboratorItem(ThemeData theme, Map<String, dynamic> collaborator) {
    final userProfile = collaborator['users'];
    final email = collaborator['email'] ?? userProfile?['email'] ?? 'Unknown';
    final fullName = email.split('@')[0]; // Use email prefix as name
    final role = collaborator['role'] ?? 'editor';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              fullName.substring(0, 1).toUpperCase(),
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  email,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: role == 'editor'
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                  : theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role == 'editor' ? 'Can edit' : role == 'admin' ? 'Admin' : 'Can view',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: role == 'editor' || role == 'admin'
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: 20,
              color: theme.colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _buildAdvancedOption(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _copyShareLink() {
    final link = 'https://notably.app/page/${widget.note.id}';
    Clipboard.setData(ClipboardData(text: link));
    _showSnackBar('Link copied to clipboard!', isError: false);
  }

  void _publishToWeb() {
    // Implementation for publishing to web
    _showSnackBar('Publishing to web...', isError: false);
  }

  void _generateQRCode() {
    // Implementation for QR code generation
    _showSnackBar('QR Code feature coming soon!', isError: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}