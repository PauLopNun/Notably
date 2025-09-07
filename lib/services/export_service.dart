import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/page.dart';
import '../models/block.dart';
import '../models/workspace.dart';
import 'page_service.dart';

// Export formats enum
enum ExportFormat {
  pdf,
  markdown,
  html,
  plainText,
  json,
}

// PDF themes
enum PdfTheme {
  professional,
  academic,
  minimal,
  creative,
}

// HTML themes  
enum HtmlTheme {
  clean,
  modern,
  classic,
}

final exportServiceProvider = Provider<ExportService>((ref) => 
  ExportService(ref.read(pageServiceProvider)));

class ExportService {
  final PageService _pageService;
  
  ExportService(this._pageService);

  // Export a single page
  Future<ExportResult> exportPage(NotionPage page, ExportOptions options) async {
    try {
      switch (options.format) {
        case ExportFormat.pdf:
          return await _exportToPDF(page, options);
        case ExportFormat.markdown:
          return await _exportToMarkdown(page, options);
        case ExportFormat.html:
          return await _exportToHTML(page, options);
        case ExportFormat.plainText:
          return await _exportToPlainText(page, options);
        case ExportFormat.json:
          return await _exportToJSON(page, options);
      }
    } catch (e) {
      return ExportResult.error('Error al exportar: ${e.toString()}');
    }
  }

  // Export entire workspace
  Future<ExportResult> exportWorkspace(Workspace workspace, List<NotionPage> pages, 
      ExportFormat format, {ExportOptions? options}) async {
    try {
      switch (format) {
        case ExportFormat.pdf:
          return await _exportWorkspaceToPDF(workspace, pages, options);
        case ExportFormat.markdown:
          return await _exportWorkspaceToMarkdown(workspace, pages, options!);
        case ExportFormat.html:
          return await _exportWorkspaceToHTML(workspace, pages, options!);
        default:
          throw Exception('Formato no soportado para workspace');
      }
    } catch (e) {
      return ExportResult.error('Error al exportar workspace: ${e.toString()}');
    }
  }

  // PDF Export Implementation
  Future<ExportResult> _exportToPDF(NotionPage page, ExportOptions? options) async {
    final pdf = pw.Document();
    final theme = options?.pdfTheme ?? PdfThemeData.academic();

    // Add page content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildPDFHeader(page, theme),
        footer: (context) => _buildPDFFooter(context, theme),
        build: (context) => _buildPDFContent(page, theme),
      ),
    );

    // Save to bytes
    final bytes = await pdf.save();
    
    // Create temporary file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(page.title)}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.pdf,
      size: bytes.length,
    );
  }

  // Markdown Export Implementation
  Future<ExportResult> _exportToMarkdown(NotionPage page, ExportOptions? options) async {
    final buffer = StringBuffer();
    
    // Add page title
    buffer.writeln('# ${page.title}');
    buffer.writeln();
    
    // Add metadata if requested
    if (options?.includeMetadata == true) {
      buffer.writeln('---');
      buffer.writeln('title: ${page.title}');
      buffer.writeln('created: ${page.createdAt.toIso8601String()}');
      buffer.writeln('updated: ${page.updatedAt.toIso8601String()}');
      if (page.icon != null) buffer.writeln('icon: ${page.icon}');
      buffer.writeln('---');
      buffer.writeln();
    }

    // Convert blocks to markdown
    for (final block in page.blocks) {
      buffer.writeln(_blockToMarkdown(block));
    }

    final content = buffer.toString();
    
    // Save to file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(page.title)}.md';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.markdown,
      size: content.length,
      content: content,
    );
  }

  // HTML Export Implementation
  Future<ExportResult> _exportToHTML(NotionPage page, ExportOptions? options) async {
    final theme = options?.htmlTheme ?? HtmlThemeData.clean();
    final buffer = StringBuffer();
    
    // HTML structure
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="es">');
    buffer.writeln('<head>');
    buffer.writeln('    <meta charset="UTF-8">');
    buffer.writeln('    <meta name="viewport" content="width=device-width, initial-scale=1.0">');
    buffer.writeln('    <title>${page.title}</title>');
    buffer.writeln('    <style>${theme.css}</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('    <div class="container">');
    
    // Page header
    if (page.icon != null) {
      buffer.writeln('        <div class="page-icon">${page.icon}</div>');
    }
    buffer.writeln('        <h1 class="page-title">${page.title}</h1>');
    
    // Page content
    buffer.writeln('        <div class="content">');
    for (final block in page.blocks) {
      buffer.writeln('            ${_blockToHTML(block)}');
    }
    buffer.writeln('        </div>');
    
    // Footer
    if (options?.includeMetadata == true) {
      buffer.writeln('        <div class="metadata">');
      buffer.writeln('            <p><small>Creado: ${_formatDate(page.createdAt)}</small></p>');
      buffer.writeln('            <p><small>Actualizado: ${_formatDate(page.updatedAt)}</small></p>');
      buffer.writeln('            <p><small>Exportado desde Notably</small></p>');
      buffer.writeln('        </div>');
    }
    
    buffer.writeln('    </div>');
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    final content = buffer.toString();
    
    // Save to file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(page.title)}.html';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.html,
      size: content.length,
      content: content,
    );
  }

  // Plain Text Export Implementation
  Future<ExportResult> _exportToPlainText(NotionPage page, ExportOptions? options) async {
    final buffer = StringBuffer();
    
    // Page title
    buffer.writeln(page.title.toUpperCase());
    buffer.writeln('=' * page.title.length);
    buffer.writeln();
    
    // Convert blocks to plain text
    for (final block in page.blocks) {
      buffer.writeln(_blockToPlainText(block));
      buffer.writeln();
    }

    final content = buffer.toString();
    
    // Save to file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(page.title)}.txt';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.plainText,
      size: content.length,
      content: content,
    );
  }

  // JSON Export Implementation
  Future<ExportResult> _exportToJSON(NotionPage page, ExportOptions? options) async {
    final data = {
      'page': page.toJson(),
      'exported_at': DateTime.now().toIso8601String(),
      'version': '1.0',
      'format': 'notably_json',
    };

    final content = _prettyPrintJson(data);
    
    // Save to file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(page.title)}.json';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsString(content);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.json,
      size: content.length,
      content: content,
    );
  }

  // Workspace PDF Export
  Future<ExportResult> _exportWorkspaceToPDF(Workspace workspace, List<NotionPage> pages, 
      ExportOptions? options) async {
    final pdf = pw.Document();
    final theme = options?.pdfTheme ?? PdfThemeData.academic();

    // Add cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildWorkspaceCover(workspace, pages, theme),
      ),
    );

    // Add table of contents
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => _buildTableOfContents(pages, theme),
      ),
    );

    // Add each page
    for (final page in pages) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          header: (context) => _buildPDFHeader(page, theme),
          footer: (context) => _buildPDFFooter(context, theme),
          build: (context) => _buildPDFContent(page, theme),
        ),
      );
    }

    // Save to bytes
    final bytes = await pdf.save();
    
    // Create temporary file
    final tempDir = await getTemporaryDirectory();
    final fileName = '${_sanitizeFileName(workspace.name)}_complete.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes);

    return ExportResult.success(
      filePath: file.path,
      fileName: fileName,
      format: ExportFormat.pdf,
      size: bytes.length,
    );
  }

  // Share exported file
  Future<void> shareFile(ExportResult result) async {
    if (result.isSuccess && result.filePath != null) {
      await Share.shareXFiles([XFile(result.filePath!)]);
    }
  }

  // Print PDF directly
  Future<void> printPDF(NotionPage page, {ExportOptions? options}) async {
    final result = await _exportToPDF(page, options);
    if (result.isSuccess && result.filePath != null) {
      final file = File(result.filePath!);
      final bytes = await file.readAsBytes();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    }
  }

  // Helper methods for PDF content generation
  pw.Widget _buildPDFHeader(NotionPage page, PdfThemeData theme) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            page.title,
            style: theme.headerStyle,
          ),
          if (page.icon != null)
            pw.Text(
              page.icon!,
              style: const pw.TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildPDFFooter(pw.Context context, PdfThemeData theme) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Exportado desde Notably',
            style: theme.footerStyle,
          ),
          pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: theme.footerStyle,
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildPDFContent(NotionPage page, PdfThemeData theme) {
    final widgets = <pw.Widget>[];
    
    // Page title
    widgets.add(
      pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (page.icon != null)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(
                  page.icon!,
                  style: const pw.TextStyle(fontSize: 32),
                ),
              ),
            pw.Text(
              page.title,
              style: theme.titleStyle,
            ),
          ],
        ),
      ),
    );

    // Convert blocks to PDF widgets
    for (final block in page.blocks) {
      widgets.add(_blockToPDFWidget(block, theme));
      widgets.add(pw.SizedBox(height: 10));
    }

    return widgets;
  }

  pw.Widget _buildWorkspaceCover(Workspace workspace, List<NotionPage> pages, PdfThemeData theme) {
    return pw.Center(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            workspace.icon,
            style: const pw.TextStyle(fontSize: 64),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            workspace.name,
            style: theme.titleStyle.copyWith(fontSize: 32),
          ),
          if (workspace.description != null)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                workspace.description!,
                style: theme.subtitleStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
          pw.SizedBox(height: 40),
          pw.Text(
            '${pages.length} páginas',
            style: theme.bodyStyle,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Exportado: ${_formatDate(DateTime.now())}',
            style: theme.captionStyle,
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildTableOfContents(List<NotionPage> pages, PdfThemeData theme) {
    final widgets = <pw.Widget>[
      pw.Text(
        'Índice',
        style: theme.headingStyle,
      ),
      pw.SizedBox(height: 20),
    ];

    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            children: [
              if (page.icon != null) ...[
                pw.Text(page.icon!),
                pw.SizedBox(width: 8),
              ],
              pw.Expanded(
                child: pw.Text(
                  page.title,
                  style: theme.bodyStyle,
                ),
              ),
              pw.Text(
                (i + 3).toString(), // Account for cover and TOC pages
                style: theme.bodyStyle,
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  // Block conversion methods
  pw.Widget _blockToPDFWidget(PageBlock block, PdfThemeData theme) {
    switch (block.type) {
      case BlockType.heading1:
        return pw.Text(
          block.content['text'] ?? '',
          style: theme.heading1Style,
        );
      case BlockType.heading2:
        return pw.Text(
          block.content['text'] ?? '',
          style: theme.heading2Style,
        );
      case BlockType.heading3:
        return pw.Text(
          block.content['text'] ?? '',
          style: theme.heading3Style,
        );
      case BlockType.paragraph:
        return pw.Text(
          block.content['text'] ?? '',
          style: theme.bodyStyle,
        );
      case BlockType.quote:
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(width: 4, color: theme.accentColor),
            ),
            color: theme.quoteBgColor,
          ),
          child: pw.Text(
            block.content['text'] ?? '',
            style: theme.quoteStyle,
          ),
        );
      case BlockType.bulletedList:
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: theme.bodyStyle),
            pw.Expanded(
              child: pw.Text(
                block.content['text'] ?? '',
                style: theme.bodyStyle,
              ),
            ),
          ],
        );
      case BlockType.numberedList:
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${block.position + 1}. ', style: theme.bodyStyle),
            pw.Expanded(
              child: pw.Text(
                block.content['text'] ?? '',
                style: theme.bodyStyle,
              ),
            ),
          ],
        );
      case BlockType.todo:
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              block.content['checked'] == true ? '☑ ' : '☐ ',
              style: theme.bodyStyle,
            ),
            pw.Expanded(
              child: pw.Text(
                block.content['text'] ?? '',
                style: theme.bodyStyle,
              ),
            ),
          ],
        );
      case BlockType.code:
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 8),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: theme.codeBgColor,
            border: pw.Border.all(color: theme.borderColor),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            block.content['code'] ?? block.content['text'] ?? '',
            style: theme.codeStyle,
          ),
        );
      case BlockType.divider:
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 16),
          height: 1,
          decoration: pw.BoxDecoration(
            color: theme.borderColor,
          ),
        );
      default:
        return pw.Text(
          block.content['text'] ?? '',
          style: theme.bodyStyle,
        );
    }
  }

  String _blockToMarkdown(PageBlock block) {
    switch (block.type) {
      case BlockType.heading1:
        return '# ${block.content['text'] ?? ''}';
      case BlockType.heading2:
        return '## ${block.content['text'] ?? ''}';
      case BlockType.heading3:
        return '### ${block.content['text'] ?? ''}';
      case BlockType.paragraph:
        return block.content['text'] ?? '';
      case BlockType.quote:
        return '> ${block.content['text'] ?? ''}';
      case BlockType.bulletedList:
        return '- ${block.content['text'] ?? ''}';
      case BlockType.numberedList:
        return '${block.position + 1}. ${block.content['text'] ?? ''}';
      case BlockType.todo:
        final checked = block.content['checked'] == true ? 'x' : ' ';
        return '- [$checked] ${block.content['text'] ?? ''}';
      case BlockType.code:
        final language = block.content['language'] ?? '';
        final code = block.content['code'] ?? block.content['text'] ?? '';
        return '```$language\n$code\n```';
      case BlockType.divider:
        return '---';
      default:
        return block.content['text'] ?? '';
    }
  }

  String _blockToHTML(PageBlock block) {
    switch (block.type) {
      case BlockType.heading1:
        return '<h1>${_escapeHtml(block.content['text'] ?? '')}</h1>';
      case BlockType.heading2:
        return '<h2>${_escapeHtml(block.content['text'] ?? '')}</h2>';
      case BlockType.heading3:
        return '<h3>${_escapeHtml(block.content['text'] ?? '')}</h3>';
      case BlockType.paragraph:
        return '<p>${_escapeHtml(block.content['text'] ?? '')}</p>';
      case BlockType.quote:
        return '<blockquote>${_escapeHtml(block.content['text'] ?? '')}</blockquote>';
      case BlockType.bulletedList:
        return '<li>${_escapeHtml(block.content['text'] ?? '')}</li>';
      case BlockType.numberedList:
        return '<li>${_escapeHtml(block.content['text'] ?? '')}</li>';
      case BlockType.todo:
        final checked = block.content['checked'] == true ? 'checked' : '';
        return '<label><input type="checkbox" $checked disabled> ${_escapeHtml(block.content['text'] ?? '')}</label>';
      case BlockType.code:
        final code = block.content['code'] ?? block.content['text'] ?? '';
        return '<pre><code>${_escapeHtml(code)}</code></pre>';
      case BlockType.divider:
        return '<hr>';
      default:
        return '<p>${_escapeHtml(block.content['text'] ?? '')}</p>';
    }
  }

  String _blockToPlainText(PageBlock block) {
    final text = block.content['text'] ?? '';
    
    switch (block.type) {
      case BlockType.heading1:
        return '$text\n${'=' * text.length}';
      case BlockType.heading2:
        return '$text\n${'-' * text.length}';
      case BlockType.heading3:
        return '### $text';
      case BlockType.quote:
        return '❝ $text ❞';
      case BlockType.bulletedList:
        return '• $text';
      case BlockType.numberedList:
        return '${block.position + 1}. $text';
      case BlockType.todo:
        final checkbox = block.content['checked'] == true ? '[✓]' : '[  ]';
        return '$checkbox $text';
      case BlockType.code:
        final code = block.content['code'] ?? text;
        return 'CODE:\n$code\n';
      case BlockType.divider:
        return '\n${'─' * 50}\n';
      default:
        return text;
    }
  }

  // Utility methods
  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').trim();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  String _prettyPrintJson(Map<String, dynamic> json) {
    // Simple JSON pretty printing
    return json.toString(); // In real implementation, use proper JSON encoding
  }

  Future<ExportResult> _exportWorkspaceToMarkdown(Workspace workspace, List<NotionPage> pages, ExportOptions options) async {
    try {
      final buffer = StringBuffer();
      
      // Workspace header
      buffer.writeln('# ${workspace.name}');
      buffer.writeln();
      
      if (workspace.description?.isNotEmpty ?? false) {
        buffer.writeln('${workspace.description}');
        buffer.writeln();
      }
      
      if (options.includeMetadata) {
        buffer.writeln('---');
        buffer.writeln('**Workspace ID:** ${workspace.id}');
        buffer.writeln('**Created:** ${_formatDate(workspace.createdAt)}');
        buffer.writeln('**Last updated:** ${_formatDate(workspace.updatedAt)}');
        buffer.writeln('**Pages:** ${pages.length}');
        buffer.writeln('---');
        buffer.writeln();
      }
      
      // Export each page
      for (final page in pages) {
        buffer.writeln('## ${page.title}');
        buffer.writeln();
        
        if (options.includeMetadata) {
          buffer.writeln('*Created: ${_formatDate(page.createdAt)} | Updated: ${_formatDate(page.updatedAt)}*');
          buffer.writeln();
        }
        
        // Get page blocks and convert them
        try {
          final blocks = await _pageService.getPageBlocks(page.id);
          for (final block in blocks) {
            final markdown = _blockToMarkdown(block);
            if (markdown.isNotEmpty) {
              buffer.writeln(markdown);
              buffer.writeln();
            }
          }
        } catch (e) {
          buffer.writeln('*Error loading page content: $e*');
        }
        
        buffer.writeln('---');
        buffer.writeln();
      }
      
      final content = buffer.toString();
      final fileName = '${workspace.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_workspace.md';
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(content);
      
      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        format: ExportFormat.markdown,
        size: await file.length(),
        content: content,
      );
    } catch (e) {
      return ExportResult.error('Error exporting workspace to Markdown: ${e.toString()}');
    }
  }

  Future<ExportResult> _exportWorkspaceToHTML(Workspace workspace, List<NotionPage> pages, ExportOptions options) async {
    try {
      final theme = options.htmlTheme ?? HtmlThemeData.clean();
      final buffer = StringBuffer();
      
      // HTML header
      buffer.writeln('<!DOCTYPE html>');
      buffer.writeln('<html lang="es">');
      buffer.writeln('<head>');
      buffer.writeln('<meta charset="UTF-8">');
      buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
      buffer.writeln('<title>${workspace.name}</title>');
      buffer.writeln('<style>');
      buffer.writeln(theme.css);
      buffer.writeln('</style>');
      buffer.writeln('</head>');
      buffer.writeln('<body>');
      
      // Workspace header
      buffer.writeln('<header>');
      buffer.writeln('<h1>${_escapeHtml(workspace.name)}</h1>');
      
      if (workspace.description?.isNotEmpty ?? false) {
        buffer.writeln('<p class="description">${_escapeHtml(workspace.description!)}</p>');
      }
      
      if (options.includeMetadata) {
        buffer.writeln('<div class="metadata">');
        buffer.writeln('<p><strong>Workspace ID:</strong> ${workspace.id}</p>');
        buffer.writeln('<p><strong>Created:</strong> ${_formatDate(workspace.createdAt)}</p>');
        buffer.writeln('<p><strong>Last updated:</strong> ${_formatDate(workspace.updatedAt)}</p>');
        buffer.writeln('<p><strong>Pages:</strong> ${pages.length}</p>');
        buffer.writeln('</div>');
      }
      
      buffer.writeln('</header>');
      
      // Table of contents
      buffer.writeln('<nav class="toc">');
      buffer.writeln('<h2>Table of Contents</h2>');
      buffer.writeln('<ul>');
      for (final page in pages) {
        final pageId = page.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        buffer.writeln('<li><a href="#page_$pageId">${_escapeHtml(page.title)}</a></li>');
      }
      buffer.writeln('</ul>');
      buffer.writeln('</nav>');
      
      // Export each page
      buffer.writeln('<main>');
      for (final page in pages) {
        final pageId = page.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        buffer.writeln('<section id="page_$pageId" class="page">');
        buffer.writeln('<h2>${_escapeHtml(page.title)}</h2>');
        
        if (options.includeMetadata) {
          buffer.writeln('<div class="page-metadata">');
          buffer.writeln('<p><em>Created: ${_formatDate(page.createdAt)} | Updated: ${_formatDate(page.updatedAt)}</em></p>');
          buffer.writeln('</div>');
        }
        
        // Get page blocks and convert them
        try {
          final blocks = await _pageService.getPageBlocks(page.id);
          for (final block in blocks) {
            final html = _blockToHTML(block);
            if (html.isNotEmpty) {
              buffer.writeln(html);
            }
          }
        } catch (e) {
          buffer.writeln('<p class="error"><em>Error loading page content: ${_escapeHtml(e.toString())}</em></p>');
        }
        
        buffer.writeln('</section>');
      }
      buffer.writeln('</main>');
      
      // HTML footer
      buffer.writeln('<footer>');
      buffer.writeln('<p>Generated by Notably on ${_formatDate(DateTime.now())}</p>');
      buffer.writeln('</footer>');
      buffer.writeln('</body>');
      buffer.writeln('</html>');
      
      final content = buffer.toString();
      final fileName = '${workspace.name.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')}_workspace.html';
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(content);
      
      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        format: ExportFormat.html,
        size: await file.length(),
        content: content,
      );
    } catch (e) {
      return ExportResult.error('Error exporting workspace to HTML: ${e.toString()}');
    }
  }
}

// Export result class
class ExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final ExportFormat? format;
  final int? size;
  final String? content;
  final String? error;

  ExportResult.success({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.size,
    this.content,
  }) : isSuccess = true, error = null;

  ExportResult.error(this.error) 
    : isSuccess = false, filePath = null, fileName = null, 
      format = null, size = null, content = null;
}

// Export options class
class ExportOptions {
  final ExportFormat format;
  final bool includeMetadata;
  final bool includeImages;
  final PdfThemeData? pdfTheme;
  final HtmlThemeData? htmlTheme;
  final bool compressImages;

  const ExportOptions({
    required this.format,
    this.includeMetadata = true,
    this.pdfTheme,
    this.htmlTheme,
    this.includeImages = true,
    this.compressImages = false,
  });
}

// PDF Theme class
class PdfThemeData {
  final pw.TextStyle titleStyle;
  final pw.TextStyle subtitleStyle;
  final pw.TextStyle headingStyle;
  final pw.TextStyle heading1Style;
  final pw.TextStyle heading2Style;
  final pw.TextStyle heading3Style;
  final pw.TextStyle bodyStyle;
  final pw.TextStyle quoteStyle;
  final pw.TextStyle codeStyle;
  final pw.TextStyle captionStyle;
  final pw.TextStyle headerStyle;
  final pw.TextStyle footerStyle;
  final PdfColor accentColor;
  final PdfColor quoteBgColor;
  final PdfColor codeBgColor;
  final PdfColor borderColor;

  const PdfThemeData({
    required this.titleStyle,
    required this.subtitleStyle,
    required this.headingStyle,
    required this.heading1Style,
    required this.heading2Style,
    required this.heading3Style,
    required this.bodyStyle,
    required this.quoteStyle,
    required this.codeStyle,
    required this.captionStyle,
    required this.headerStyle,
    required this.footerStyle,
    required this.accentColor,
    required this.quoteBgColor,
    required this.codeBgColor,
    required this.borderColor,
  });

  factory PdfThemeData.academic() {
    return PdfThemeData(
      titleStyle: pw.TextStyle(
        fontSize: 28,
        fontWeight: pw.FontWeight.bold,
      ),
      subtitleStyle: pw.TextStyle(
        fontSize: 16,
        fontStyle: pw.FontStyle.italic,
      ),
      headingStyle: pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
      ),
      heading1Style: pw.TextStyle(
        fontSize: 24,
        fontWeight: pw.FontWeight.bold,
      ),
      heading2Style: pw.TextStyle(
        fontSize: 20,
        fontWeight: pw.FontWeight.bold,
      ),
      heading3Style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
      ),
      bodyStyle: const pw.TextStyle(
        fontSize: 12,
        lineSpacing: 1.4,
      ),
      quoteStyle: pw.TextStyle(
        fontSize: 12,
        fontStyle: pw.FontStyle.italic,
      ),
      codeStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      captionStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      headerStyle: const pw.TextStyle(
        fontSize: 10,
      ),
      footerStyle: const pw.TextStyle(
        fontSize: 8,
      ),
      accentColor: PdfColors.blue,
      quoteBgColor: PdfColors.grey100,
      codeBgColor: PdfColors.grey50,
      borderColor: PdfColors.grey300,
    );
  }
}

// HTML Theme class
class HtmlThemeData {
  final String css;

  const HtmlThemeData({required this.css});

  factory HtmlThemeData.clean() {
    return HtmlThemeData(
      css: '''
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          line-height: 1.6;
          max-width: 800px;
          margin: 0 auto;
          padding: 2rem;
          color: #333;
        }
        .container {
          background: white;
        }
        .page-icon {
          font-size: 2rem;
          margin-bottom: 1rem;
        }
        .page-title {
          color: #1a202c;
          margin-bottom: 2rem;
          border-bottom: 2px solid #e2e8f0;
          padding-bottom: 1rem;
        }
        .content {
          margin-bottom: 3rem;
        }
        h1, h2, h3 {
          color: #2d3748;
          margin-top: 2rem;
          margin-bottom: 1rem;
        }
        blockquote {
          border-left: 4px solid #4299e1;
          background: #f7fafc;
          padding: 1rem;
          margin: 1rem 0;
          font-style: italic;
        }
        pre {
          background: #f7fafc;
          border: 1px solid #e2e8f0;
          border-radius: 0.375rem;
          padding: 1rem;
          overflow-x: auto;
        }
        code {
          background: #f1f5f9;
          padding: 0.125rem 0.25rem;
          border-radius: 0.25rem;
          font-size: 0.875em;
        }
        hr {
          border: none;
          border-top: 1px solid #e2e8f0;
          margin: 2rem 0;
        }
        ul, ol {
          padding-left: 1.5rem;
        }
        li {
          margin-bottom: 0.5rem;
        }
        .metadata {
          border-top: 1px solid #e2e8f0;
          padding-top: 2rem;
          margin-top: 3rem;
          color: #718096;
        }
        input[type="checkbox"] {
          margin-right: 0.5rem;
        }
      ''',
    );
  }
}