import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/workspace.dart';
import 'page_service.dart';
import 'workspace_service.dart';

// Import formats enum
enum ImportFormat {
  markdown,
  html,
  plainText,
  json,
  notion,
  obsidian,
  docx,
}

// Import result class
class ImportResult {
  final bool isSuccess;
  final String? error;
  final List<NotionPage>? pages;
  final Workspace? workspace;
  final int importedCount;
  final List<String> warnings;

  ImportResult.success({
    this.pages,
    this.workspace,
    this.importedCount = 0,
    this.warnings = const [],
  }) : isSuccess = true, error = null;

  ImportResult.error(this.error)
    : isSuccess = false, pages = null, workspace = null, 
      importedCount = 0, warnings = const [];
}

// Import Service Provider
final importServiceProvider = Provider<ImportService>((ref) => ImportService(
  ref.read(pageServiceProvider),
  ref.read(workspaceServiceProvider),
));

class ImportService {
  final PageService _pageService;
  final WorkspaceService _workspaceService;
  final Uuid _uuid = const Uuid();

  ImportService(this._pageService, this._workspaceService);

  // Main import method
  Future<ImportResult> importFromFile({
    required String workspaceId,
    ImportFormat? format,
  }) async {
    try {
      // Open file picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(),
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.error('No files selected');
      }

      List<NotionPage> allPages = [];
      List<String> allWarnings = [];

      for (final file in result.files) {
        if (file.path == null) continue;

        final fileFormat = format ?? _detectFormat(file.path!);
        final importResult = await _importFile(
          file.path!,
          fileFormat,
          workspaceId,
        );

        if (importResult.isSuccess) {
          allPages.addAll(importResult.pages ?? []);
          allWarnings.addAll(importResult.warnings);
        } else {
          allWarnings.add('Failed to import ${file.name}: ${importResult.error}');
        }
      }

      return ImportResult.success(
        pages: allPages,
        importedCount: allPages.length,
        warnings: allWarnings,
      );

    } catch (e) {
      return ImportResult.error('Import failed: ${e.toString()}');
    }
  }

  // Import from URL (for web content)
  Future<ImportResult> importFromUrl({
    required String url,
    required String workspaceId,
    ImportFormat format = ImportFormat.html,
  }) async {
    try {
      // This would require HTTP client implementation
      // For now, return not implemented
      return ImportResult.error('URL import not yet implemented');
    } catch (e) {
      return ImportResult.error('URL import failed: ${e.toString()}');
    }
  }

  // Import entire workspace from backup
  Future<ImportResult> importWorkspaceBackup(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Validate backup format
      if (data['format'] != 'notably_workspace_backup') {
        return ImportResult.error('Invalid backup format');
      }

      final workspaceData = data['workspace'] as Map<String, dynamic>;
      final pagesData = data['pages'] as List<dynamic>;

      // Create workspace
      final workspace = await _workspaceService.createWorkspace(
        name: workspaceData['name'],
        icon: workspaceData['icon'],
        description: workspaceData['description'],
      );

      List<NotionPage> importedPages = [];
      for (final pageData in pagesData) {
        try {
          final page = NotionPage.fromJson(pageData as Map<String, dynamic>);
          final importedPage = await _pageService.createPage(
            workspaceId: workspace.id,
            title: page.title,
            icon: page.icon,
          );
          
          // Add blocks to the page
          for (final block in page.blocks) {
            await _pageService.createBlock(
          pageId: importedPage.id,
          type: block.type,
          content: block.content,
          position: block.position,
        );
          }
          
          importedPages.add(importedPage);
        } catch (e) {
          // Continue with other pages if one fails
        }
      }

      return ImportResult.success(
        workspace: workspace,
        pages: importedPages,
        importedCount: importedPages.length,
      );

    } catch (e) {
      return ImportResult.error('Workspace import failed: ${e.toString()}');
    }
  }

  // Private methods

  Future<ImportResult> _importFile(
    String filePath,
    ImportFormat format,
    String workspaceId,
  ) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final fileName = file.uri.pathSegments.last;
      final baseName = fileName.substring(0, fileName.lastIndexOf('.'));

      switch (format) {
        case ImportFormat.markdown:
          return await _importMarkdown(content, baseName, workspaceId);
        case ImportFormat.html:
          return await _importHtml(content, baseName, workspaceId);
        case ImportFormat.plainText:
          return await _importPlainText(content, baseName, workspaceId);
        case ImportFormat.json:
          return await _importJson(content, baseName, workspaceId);
        case ImportFormat.notion:
          return await _importNotionExport(content, baseName, workspaceId);
        case ImportFormat.obsidian:
          return await _importObsidian(content, baseName, workspaceId);
        default:
          return ImportResult.error('Unsupported format: $format');
      }
    } catch (e) {
      return ImportResult.error('File import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importMarkdown(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      final blocks = <PageBlock>[];
      final lines = content.split('\n');
      int position = 0;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        PageBlock? block;

        // Headers
        if (trimmed.startsWith('# ')) {
          block = _createBlock(BlockType.heading1, trimmed.substring(2), position);
        } else if (trimmed.startsWith('## ')) {
          block = _createBlock(BlockType.heading2, trimmed.substring(3), position);
        } else if (trimmed.startsWith('### ')) {
          block = _createBlock(BlockType.heading3, trimmed.substring(4), position);
        }
        // Quotes
        else if (trimmed.startsWith('> ')) {
          block = _createBlock(BlockType.quote, trimmed.substring(2), position);
        }
        // Lists
        else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          if (trimmed.startsWith('- [') && trimmed.contains(']')) {
            // Todo item
            final checked = trimmed.contains('- [x]') || trimmed.contains('- [X]');
            final text = trimmed.substring(trimmed.indexOf(']') + 1).trim();
            block = PageBlock(
              id: _uuid.v4(),
              pageId: '', // Will be set when adding to page
              type: BlockType.todo,
              content: {'text': text, 'checked': checked},
              position: position,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          } else {
            block = _createBlock(BlockType.bulletedList, trimmed.substring(2), position);
          }
        }
        // Numbered lists
        else if (RegExp(r'^\d+\.\s').hasMatch(trimmed)) {
          final text = trimmed.substring(trimmed.indexOf('.') + 1).trim();
          block = _createBlock(BlockType.numberedList, text, position);
        }
        // Code blocks
        else if (trimmed.startsWith('```')) {
          // Handle code blocks (simplified)
          block = _createBlock(BlockType.code, trimmed, position);
        }
        // Horizontal rules
        else if (trimmed == '---' || trimmed == '***') {
          block = PageBlock(
            id: _uuid.v4(),
            pageId: '', // Will be set when adding to page
            type: BlockType.divider,
            content: {},
            position: position,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
        // Regular paragraphs
        else {
          block = _createBlock(BlockType.paragraph, trimmed, position);
        }

        if (block case PageBlock validBlock) {
          blocks.add(validBlock);
          position++;
        }
      }

      final page = await _pageService.createPage(
        workspaceId: workspaceId,
        title: fileName,
      );
      
      // Add blocks to the page
      for (final block in blocks) {
        await _pageService.createBlock(
          pageId: page.id,
          type: block.type,
          content: block.content,
          position: block.position,
        );
      }

      return ImportResult.success(
        pages: [page],
        importedCount: 1,
      );

    } catch (e) {
      return ImportResult.error('Markdown import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importHtml(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      // Simple HTML parsing (in production, use html package)
      final blocks = <PageBlock>[];
      int position = 0;

      // Extract title
      final titleMatch = RegExp(r'<title>(.*?)</title>', caseSensitive: false).firstMatch(content);
      final title = titleMatch?.group(1) ?? fileName;

      // Simple regex-based parsing for common elements
      final patterns = {
        r'<h1[^>]*>(.*?)</h1>': BlockType.heading1,
        r'<h2[^>]*>(.*?)</h2>': BlockType.heading2,
        r'<h3[^>]*>(.*?)</h3>': BlockType.heading3,
        r'<p[^>]*>(.*?)</p>': BlockType.paragraph,
        r'<blockquote[^>]*>(.*?)</blockquote>': BlockType.quote,
        r'<li[^>]*>(.*?)</li>': BlockType.bulletedList,
      };

      for (final entry in patterns.entries) {
        final matches = RegExp(entry.key, caseSensitive: false, dotAll: true).allMatches(content);
        for (final match in matches) {
          final text = _stripHtmlTags(match.group(1) ?? '');
          if (text.isNotEmpty) {
            blocks.add(_createBlock(entry.value, text, position));
            position++;
          }
        }
      }

      // Sort blocks by their appearance in the original HTML
      // (This is simplified; in production, preserve order better)
      blocks.sort((a, b) => a.position.compareTo(b.position));

      final page = await _pageService.createPage(
        workspaceId: workspaceId,
        title: title,
      );

      return ImportResult.success(
        pages: [page],
        importedCount: 1,
      );

    } catch (e) {
      return ImportResult.error('HTML import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importPlainText(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      final blocks = <PageBlock>[];
      final lines = content.split('\n');
      int position = 0;

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        final block = _createBlock(BlockType.paragraph, trimmed, position);
        blocks.add(block);
        position++;
      }

      final page = await _pageService.createPage(
        workspaceId: workspaceId,
        title: fileName,
      );
      
      // Add blocks to the page
      for (final block in blocks) {
        await _pageService.createBlock(
          pageId: page.id,
          type: block.type,
          content: block.content,
          position: block.position,
        );
      }

      return ImportResult.success(
        pages: [page],
        importedCount: 1,
      );

    } catch (e) {
      return ImportResult.error('Plain text import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importJson(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;

      // Check if it's a Notably export
      if (data['format'] == 'notably_json') {
        final pageData = data['page'] as Map<String, dynamic>;
        final page = NotionPage.fromJson(pageData);
        
        final importedPage = await _pageService.createPage(
          workspaceId: workspaceId,
          title: page.title,
          icon: page.icon,
        );
        
        // Add blocks to the page
        for (final block in page.blocks) {
          await _pageService.createBlock(
          pageId: importedPage.id,
          type: block.type,
          content: block.content,
          position: block.position,
        );
        }

        return ImportResult.success(
          pages: [importedPage],
          importedCount: 1,
        );
      }

      // Generic JSON import (create a page with JSON content)
      final page = await _pageService.createPage(
        workspaceId: workspaceId,
        title: fileName,
      );
      
      // Add JSON content as a code block
      await _pageService.createBlock(
        pageId: page.id,
        type: BlockType.code,
        content: {
          'text': jsonEncode(data),
          'language': 'json',
        },
        position: 0,
      );

      return ImportResult.success(
        pages: [page],
        importedCount: 1,
        warnings: ['Imported as raw JSON'],
      );

    } catch (e) {
      return ImportResult.error('JSON import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importNotionExport(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      // Notion exports are typically in specific formats
      // This is a simplified implementation
      return await _importMarkdown(content, fileName, workspaceId);
    } catch (e) {
      return ImportResult.error('Notion import failed: ${e.toString()}');
    }
  }

  Future<ImportResult> _importObsidian(
    String content,
    String fileName,
    String workspaceId,
  ) async {
    try {
      // Obsidian uses enhanced markdown with [[wiki links]]
      // Convert wiki links to regular text for now
      final processedContent = content.replaceAllMapped(
        RegExp(r'\[\[([^\]]+)\]\]'),
        (match) => match.group(1) ?? '',
      );

      return await _importMarkdown(processedContent, fileName, workspaceId);
    } catch (e) {
      return ImportResult.error('Obsidian import failed: ${e.toString()}');
    }
  }

  // Utility methods

  PageBlock _createBlock(
    BlockType type,
    String text,
    int position, [
    Map<String, dynamic>? additionalContent,
  ]) {
    final content = <String, dynamic>{'text': text};
    content.addAll(additionalContent ?? {});

    return PageBlock(
      id: _uuid.v4(),
      pageId: '', // Will be set when adding to page
      type: type,
      content: content,
      position: position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ImportFormat _detectFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'md':
      case 'markdown':
        return ImportFormat.markdown;
      case 'html':
      case 'htm':
        return ImportFormat.html;
      case 'txt':
        return ImportFormat.plainText;
      case 'json':
        return ImportFormat.json;
      case 'docx':
        return ImportFormat.docx;
      default:
        return ImportFormat.plainText;
    }
  }

  List<String> _getAllowedExtensions() {
    return ['md', 'markdown', 'html', 'htm', 'txt', 'json'];
  }

  String _stripHtmlTags(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#x27;', "'")
        .trim();
  }
}

// Import Options class for future extensibility
class ImportOptions {
  final bool preserveFormatting;
  final bool createWorkspace;
  final String? targetWorkspaceId;
  final bool mergePages;
  final bool skipEmptyBlocks;

  const ImportOptions({
    this.preserveFormatting = true,
    this.createWorkspace = false,
    this.targetWorkspaceId,
    this.mergePages = false,
    this.skipEmptyBlocks = true,
  });
}