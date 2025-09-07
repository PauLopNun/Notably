import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workspace.dart';
import '../models/page.dart';
import '../services/export_service.dart';
import '../providers/page_provider.dart';

class BulkExportDialog extends ConsumerStatefulWidget {
  final Workspace workspace;

  const BulkExportDialog({
    super.key,
    required this.workspace,
  });

  @override
  ConsumerState<BulkExportDialog> createState() => _BulkExportDialogState();
}

class _BulkExportDialogState extends ConsumerState<BulkExportDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;
  bool _includeMetadata = true;
  bool _includeImages = true;
  bool _compressImages = false;
  PdfTheme _selectedPdfTheme = PdfTheme.academic;
  HtmlTheme _selectedHtmlTheme = HtmlTheme.clean;
  final Set<String> _selectedPageIds = <String>{};
  bool _selectAll = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // Initially select all pages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPages();
    });
  }

  void _loadPages() async {
    final pages = await ref.read(pageServiceProvider).getWorkspacePages(widget.workspace.id);
    setState(() {
      _selectedPageIds.addAll(pages.map((p) => p.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageAsync = ref.watch(workspacePagesProvider(widget.workspace.id));

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download_rounded, color: theme.primaryColor),
          const SizedBox(width: 12),
          Text('Bulk Export - ${widget.workspace.name}'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 600,
        child: pageAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading pages: $error'),
              ],
            ),
          ),
          data: (pages) => _buildExportContent(context, theme, pages),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isExporting || _selectedPageIds.isEmpty 
              ? null 
              : () => _performBulkExport(context),
          icon: _isExporting 
              ? const SizedBox(
                  width: 16, 
                  height: 16, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(_isExporting ? 'Exporting...' : 'Export ${_selectedPageIds.length} pages'),
        ),
      ],
    );
  }

  Widget _buildExportContent(BuildContext context, ThemeData theme, List<NotionPage> pages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Format Selection
        _buildSection(
          'Export Format',
          _buildFormatSelector(theme),
        ),
        
        const SizedBox(height: 24),
        
        // Options based on format
        _buildSection(
          'Export Options',
          _buildOptionsSelector(theme),
        ),
        
        const SizedBox(height: 24),
        
        // Page Selection
        _buildSection(
          'Select Pages',
          _buildPageSelector(theme, pages),
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

  Widget _buildFormatSelector(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ExportFormat.values.map((format) {
        final isSelected = _selectedFormat == format;
        return FilterChip(
          selected: isSelected,
          label: Text(_getFormatDisplayName(format)),
          avatar: Icon(_getFormatIcon(format), size: 16),
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedFormat = format);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildOptionsSelector(ThemeData theme) {
    return Column(
      children: [
        // Common options
        CheckboxListTile(
          title: const Text('Include metadata'),
          subtitle: const Text('Created/updated dates, page info'),
          value: _includeMetadata,
          onChanged: (value) => setState(() => _includeMetadata = value == true),
          dense: true,
        ),
        
        CheckboxListTile(
          title: const Text('Include images'),
          subtitle: const Text('Export embedded images'),
          value: _includeImages,
          onChanged: (value) => setState(() => _includeImages = value ?? true),
          dense: true,
        ),

        if (_includeImages)
          CheckboxListTile(
            title: const Text('Compress images'),
            subtitle: const Text('Reduce file size'),
            value: _compressImages,
            onChanged: (value) => setState(() => _compressImages = value ?? false),
            dense: true,
          ),

        // Format-specific options
        if (_selectedFormat == ExportFormat.pdf) ...[
          const SizedBox(height: 8),
          const Text('PDF Theme:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PdfTheme.values.map((theme) {
              return ChoiceChip(
                label: Text(_getPdfThemeDisplayName(theme)),
                selected: _selectedPdfTheme == theme,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedPdfTheme = theme);
                },
              );
            }).toList(),
          ),
        ],

        if (_selectedFormat == ExportFormat.html) ...[
          const SizedBox(height: 8),
          const Text('HTML Theme:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: HtmlTheme.values.map((theme) {
              return ChoiceChip(
                label: Text(_getHtmlThemeDisplayName(theme)),
                selected: _selectedHtmlTheme == theme,
                onSelected: (selected) {
                  if (selected) setState(() => _selectedHtmlTheme = theme);
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPageSelector(ThemeData theme, List<NotionPage> pages) {
    return Column(
      children: [
        // Select all toggle
        CheckboxListTile(
          title: const Text('Select All'),
          value: _selectAll,
          onChanged: (value) {
            setState(() {
              _selectAll = value ?? false;
              if (_selectAll) {
                _selectedPageIds.addAll(pages.map((p) => p.id));
              } else {
                _selectedPageIds.clear();
              }
            });
          },
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        const Divider(),
        
        // Pages list
        Expanded(
          child: ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final isSelected = _selectedPageIds.contains(page.id);
              
              return CheckboxListTile(
                title: Text(page.title.isEmpty ? 'Untitled' : page.title),
                subtitle: Text(
                  'Created: ${_formatDate(page.createdAt)} • ${page.blocks.length} blocks',
                  style: theme.textTheme.bodySmall,
                ),
                secondary: page.icon != null 
                    ? Text(page.icon!, style: const TextStyle(fontSize: 20))
                    : const Icon(Icons.description),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedPageIds.add(page.id);
                    } else {
                      _selectedPageIds.remove(page.id);
                    }
                    _selectAll = _selectedPageIds.length == pages.length;
                  });
                },
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _performBulkExport(BuildContext context) async {
    setState(() => _isExporting = true);

    try {
      final exportService = ref.read(exportServiceProvider);
      final pageService = ref.read(pageServiceProvider);
      
      // Get selected pages
      final selectedPages = <NotionPage>[];
      for (final pageId in _selectedPageIds) {
        try {
          final page = await pageService.getPage(pageId);
          selectedPages.add(page);
        } catch (e) {
          // Skip pages that can't be loaded
        }
      }

      if (selectedPages.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No pages available for export')),
          );
        }
        return;
      }

      // Create export options
      final options = ExportOptions(
        format: _selectedFormat,
        includeMetadata: _includeMetadata,
        includeImages: _includeImages,
        compressImages: _compressImages,
        pdfTheme: _selectedFormat == ExportFormat.pdf ? _getPdfThemeData() : null,
        htmlTheme: _selectedFormat == ExportFormat.html ? _getHtmlThemeData() : null,
      );

      // Perform bulk export
      final result = await exportService.exportWorkspace(
        widget.workspace,
        selectedPages,
        _selectedFormat,
        options: options,
      );

      if (result.isSuccess) {
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully exported ${selectedPages.length} pages'),
              action: SnackBarAction(
                label: 'Share',
                onPressed: () => exportService.shareFile(result),
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export failed: ${result.error}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _getFormatDisplayName(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.markdown:
        return 'Markdown';
      case ExportFormat.html:
        return 'HTML';
      case ExportFormat.plainText:
        return 'Plain Text';
      case ExportFormat.json:
        return 'JSON';
    }
  }

  IconData _getFormatIcon(ExportFormat format) {
    switch (format) {
      case ExportFormat.pdf:
        return Icons.picture_as_pdf;
      case ExportFormat.markdown:
        return Icons.text_snippet;
      case ExportFormat.html:
        return Icons.web;
      case ExportFormat.plainText:
        return Icons.notes;
      case ExportFormat.json:
        return Icons.data_object;
    }
  }

  String _getPdfThemeDisplayName(PdfTheme theme) {
    switch (theme) {
      case PdfTheme.professional:
        return 'Professional';
      case PdfTheme.academic:
        return 'Academic';
      case PdfTheme.minimal:
        return 'Minimal';
      case PdfTheme.creative:
        return 'Creative';
    }
  }

  String _getHtmlThemeDisplayName(HtmlTheme theme) {
    switch (theme) {
      case HtmlTheme.clean:
        return 'Clean';
      case HtmlTheme.modern:
        return 'Modern';
      case HtmlTheme.classic:
        return 'Classic';
    }
  }

  PdfThemeData? _getPdfThemeData() {
    switch (_selectedPdfTheme) {
      case PdfTheme.academic:
        return PdfThemeData.academic();
      default:
        return PdfThemeData.academic();
    }
  }

  HtmlThemeData? _getHtmlThemeData() {
    switch (_selectedHtmlTheme) {
      case HtmlTheme.clean:
        return HtmlThemeData.clean();
      default:
        return HtmlThemeData.clean();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}