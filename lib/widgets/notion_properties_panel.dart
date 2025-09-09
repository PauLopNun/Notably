import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';

class NotionPropertiesPanel extends StatefulWidget {
  final Note note;
  final VoidCallback onClose;

  const NotionPropertiesPanel({
    super.key,
    required this.note,
    required this.onClose,
  });

  @override
  State<NotionPropertiesPanel> createState() => _NotionPropertiesPanelState();
}

class _NotionPropertiesPanelState extends State<NotionPropertiesPanel> {
  late String _selectedTag;
  final List<String> _availableTags = [
    'Work', 'Personal', 'Ideas', 'Project', 'Meeting', 'Research',
    'Todo', 'Archive', 'Important', 'Draft'
  ];
  
  final List<String> _availableColors = [
    'Default', 'Blue', 'Green', 'Red', 'Yellow', 'Purple', 'Pink', 'Orange'
  ];

  @override
  void initState() {
    super.initState();
    _selectedTag = 'Work';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(theme),
                  const SizedBox(height: 24),
                  _buildProperties(theme),
                  const SizedBox(height: 24),
                  _buildMetadata(theme),
                  const SizedBox(height: 24),
                  _buildActions(theme),
                ],
              ),
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
          bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Page Properties',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onClose,
            tooltip: 'Close properties',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme) {
    final contentText = _getContentText(widget.note.content);
    final wordCount = contentText.split(' ').where((word) => word.isNotEmpty).length;
    final charCount = contentText.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Basic Information'),
        const SizedBox(height: 12),
        
        _buildInfoRow(theme, 'Title', widget.note.title.isEmpty ? 'Untitled' : widget.note.title),
        _buildInfoRow(theme, 'Word Count', '$wordCount words'),
        _buildInfoRow(theme, 'Character Count', '$charCount characters'),
        _buildInfoRow(theme, 'Reading Time', '${(wordCount / 200).ceil()} min read'),
      ],
    );
  }

  Widget _buildProperties(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Properties'),
        const SizedBox(height: 12),
        
        // Tags
        _buildPropertyRow(
          theme,
          'Tags',
          DropdownButtonFormField<String>(
            value: _selectedTag,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              isDense: true,
            ),
            items: _availableTags.map((tag) {
              return DropdownMenuItem(
                value: tag,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getTagColor(theme, tag),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(tag, style: theme.textTheme.bodyMedium),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedTag = value);
              }
            },
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Priority
        _buildPropertyRow(
          theme,
          'Priority',
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildPriorityChip(theme, 'Low', Colors.green, isSelected: false),
              _buildPriorityChip(theme, 'Medium', Colors.orange, isSelected: true),
              _buildPriorityChip(theme, 'High', Colors.red, isSelected: false),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Status
        _buildPropertyRow(
          theme,
          'Status',
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Active', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadata(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Metadata'),
        const SizedBox(height: 12),
        
        _buildInfoRow(theme, 'Created', _formatDateTime(widget.note.createdAt)),
        _buildInfoRow(theme, 'Last Modified', _formatDateTime(widget.note.updatedAt)),
        _buildInfoRow(theme, 'Note ID', widget.note.id),
        _buildInfoRow(theme, 'Owner', widget.note.userId),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Actions'),
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _copyNoteId,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy Note ID'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showShareDialog,
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share Note'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _duplicateNote,
            icon: const Icon(Icons.copy_all, size: 16),
            label: const Text('Duplicate Note'),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
            label: const Text('Delete Note', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              alignment: Alignment.centerLeft,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(ThemeData theme, String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildPriorityChip(ThemeData theme, String label, Color color, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        // Handle priority selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : theme.colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getTagColor(ThemeData theme, String tag) {
    final colors = {
      'Work': Colors.blue,
      'Personal': Colors.green,
      'Ideas': Colors.purple,
      'Project': Colors.orange,
      'Meeting': Colors.red,
      'Research': Colors.teal,
      'Todo': Colors.amber,
      'Archive': Colors.grey,
      'Important': Colors.red,
      'Draft': Colors.grey,
    };
    return colors[tag] ?? theme.colorScheme.primary;
  }

  String _getContentText(List<dynamic> content) {
    if (content.isEmpty) return '';
    try {
      final buffer = StringBuffer();
      for (final op in content) {
        if (op is Map && op.containsKey('insert')) {
          buffer.write(op['insert'].toString());
        }
      }
      return buffer.toString();
    } catch (e) {
      return content.toString();
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _copyNoteId() {
    Clipboard.setData(ClipboardData(text: widget.note.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note ID copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Note'),
        content: const Text('Share functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _duplicateNote() {
    // Implement note duplication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note duplication would be implemented here'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${widget.note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}