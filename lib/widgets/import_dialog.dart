import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import '../services/import_service.dart';
import '../providers/page_provider.dart';

class ImportDialog extends ConsumerStatefulWidget {
  final Workspace workspace;

  const ImportDialog({
    super.key,
    required this.workspace,
  });

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  ImportFormat? _selectedFormat;
  bool _autoDetectFormat = true;
  bool _preserveFormatting = true;
  bool _skipEmptyBlocks = true;
  bool _createNewWorkspace = false;
  bool _isImporting = false;
  ImportResult? _lastResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.upload_rounded, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text('Import to ${widget.workspace.name}'),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_lastResult != null) ...[
              _buildResultCard(theme),
              const SizedBox(height: 16),
            ],
            
            _buildSection(
              'Import Format',
              _buildFormatSelector(theme),
            ),
            
            const SizedBox(height: 20),
            
            _buildSection(
              'Import Options',
              _buildOptionsSelector(theme),
            ),
            
            const SizedBox(height: 20),
            
            _buildSupportedFormatsInfo(theme),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isImporting ? null : () => _performImport(context),
          icon: _isImporting 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(_isImporting ? 'Importing...' : 'Choose Files'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final result = _lastResult!;
    final isSuccess = result.isSuccess;
    
    return Card(
      color: isSuccess 
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isSuccess ? 'Import Successful' : 'Import Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? Colors.green : theme.colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isSuccess) ...[
              Text('Imported ${result.importedCount} pages successfully'),
              if (result.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Warnings: ${result.warnings.length}',
                  style: TextStyle(color: Colors.orange[700]),
                ),
                for (final warning in result.warnings.take(3))
                  Text(
                    '• $warning',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                    ),
                  ),
                if (result.warnings.length > 3)
                  Text(
                    '... and ${result.warnings.length - 3} more',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ] else ...[
              Text(result.error ?? 'Unknown error occurred'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormatSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Auto-detect format'),
          subtitle: const Text('Detect format from file extension'),
          value: _autoDetectFormat,
          onChanged: (value) => setState(() => _autoDetectFormat = value ?? true),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        if (!_autoDetectFormat) ...[
          const SizedBox(height: 8),
          const Text('Force format:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ImportFormat.values.map((format) {
              return FilterChip(
                selected: _selectedFormat == format,
                label: Text(_getFormatDisplayName(format)),
                avatar: Icon(_getFormatIcon(format), size: 16),
                onSelected: (selected) {
                  setState(() => _selectedFormat = selected ? format : null);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsSelector(ThemeData theme) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Preserve formatting'),
          subtitle: const Text('Keep original text styling when possible'),
          value: _preserveFormatting,
          onChanged: (value) => setState(() => _preserveFormatting = value ?? true),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        CheckboxListTile(
          title: const Text('Skip empty blocks'),
          subtitle: const Text('Ignore empty lines and blocks'),
          value: _skipEmptyBlocks,
          onChanged: (value) => setState(() => _skipEmptyBlocks = value ?? true),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        CheckboxListTile(
          title: const Text('Create new workspace'),
          subtitle: const Text('Import into a new workspace instead'),
          value: _createNewWorkspace,
          onChanged: (value) => setState(() => _createNewWorkspace = value ?? false),
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildSupportedFormatsInfo(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Supported Formats',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '• Markdown (.md, .markdown)\n'
              '• HTML (.html, .htm)\n'
              '• Plain Text (.txt)\n'
              '• JSON (.json)\n'
              '• Notion exports\n'
              '• Obsidian notes',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performImport(BuildContext context) async {
    setState(() {
      _isImporting = true;
      _lastResult = null;
    });

    try {
      final importService = ref.read(importServiceProvider);
      
      final result = await importService.importFromFile(
        workspaceId: widget.workspace.id,
        format: _autoDetectFormat ? null : _selectedFormat,
      );

      setState(() => _lastResult = result);

      if (result.isSuccess) {
        // Refresh the pages list
        ref.invalidate(workspacePagesProvider(widget.workspace.id));
        
        if (context.mounted && result.importedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully imported ${result.importedCount} pages'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Auto-close dialog after successful import
          await Future.delayed(const Duration(seconds: 2));
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      }

    } catch (e) {
      setState(() => _lastResult = ImportResult.error('Import error: ${e.toString()}'));
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  String _getFormatDisplayName(ImportFormat format) {
    switch (format) {
      case ImportFormat.markdown:
        return 'Markdown';
      case ImportFormat.html:
        return 'HTML';
      case ImportFormat.plainText:
        return 'Plain Text';
      case ImportFormat.json:
        return 'JSON';
      case ImportFormat.notion:
        return 'Notion';
      case ImportFormat.obsidian:
        return 'Obsidian';
      case ImportFormat.docx:
        return 'Word';
    }
  }

  IconData _getFormatIcon(ImportFormat format) {
    switch (format) {
      case ImportFormat.markdown:
        return Icons.text_snippet;
      case ImportFormat.html:
        return Icons.web;
      case ImportFormat.plainText:
        return Icons.notes;
      case ImportFormat.json:
        return Icons.data_object;
      case ImportFormat.notion:
        return Icons.article;
      case ImportFormat.obsidian:
        return Icons.auto_awesome;
      case ImportFormat.docx:
        return Icons.description;
    }
  }
}