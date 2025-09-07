import '../models/template.dart';
import '../models/block.dart';
import '../models/page.dart';
import 'page_service.dart';

class TemplateService {
  final PageService _pageService;

  TemplateService(this._pageService);

  /// Get all available templates
  Future<List<PageTemplate>> getAllTemplates() async {
    // For now, return the predefined templates
    // In a real app, this would fetch from database
    return SubjectTemplates.getAcademicTemplates();
  }

  /// Get templates by category
  Future<List<PageTemplate>> getTemplatesByCategory(String category) async {
    final allTemplates = await getAllTemplates();
    if (category == 'all') return allTemplates;
    return allTemplates.where((template) => template.category == category).toList();
  }

  /// Search templates by query
  Future<List<PageTemplate>> searchTemplates(String query) async {
    final allTemplates = await getAllTemplates();
    final lowerQuery = query.toLowerCase();
    
    return allTemplates.where((template) {
      return template.name.toLowerCase().contains(lowerQuery) ||
             (template.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             template.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  /// Apply a template to create a new page
  Future<NotionPage> applyTemplate({
    required PageTemplate template,
    required String workspaceId,
    String? customTitle,
    String? parentId,
  }) async {
    // Create the new page
    final page = await _pageService.createPage(
      workspaceId: workspaceId,
      parentId: parentId,
      title: customTitle ?? template.name,
      icon: template.icon,
    );

    // Convert template blocks to actual page blocks
    final blocks = _convertTemplateBlocks(template.blocks, page.id);
    
    // Create all blocks
    for (final block in blocks) {
      await _pageService.createBlock(
        pageId: page.id,
        parentBlockId: block.parentBlockId,
        type: block.type,
        content: block.content,
        position: block.position,
        properties: block.properties,
      );
    }

    return page;
  }

  /// Convert template blocks to page blocks
  List<PageBlock> _convertTemplateBlocks(List<TemplateBlock> templateBlocks, String pageId) {
    return templateBlocks.map((templateBlock) {
      return PageBlock(
        id: _generateBlockId(),
        pageId: pageId,
        parentBlockId: templateBlock.parentBlockId,
        type: templateBlock.type,
        content: Map<String, dynamic>.from(templateBlock.content),
        properties: Map<String, dynamic>.from(templateBlock.properties),
        position: templateBlock.position,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  /// Create a custom template from an existing page
  Future<PageTemplate> createTemplateFromPage({
    required NotionPage page,
    required List<PageBlock> blocks,
    required String name,
    String? description,
    required String category,
    List<String> tags = const [],
  }) async {
    final templateBlocks = blocks.map((block) {
      return TemplateBlock(
        id: block.id,
        parentBlockId: block.parentBlockId,
        type: block.type,
        content: Map<String, dynamic>.from(block.content),
        properties: Map<String, dynamic>.from(block.properties),
        position: block.position,
        isPlaceholder: _isPlaceholderContent(block.content),
        placeholderText: _getPlaceholderText(block.content),
      );
    }).toList();

    return PageTemplate(
      id: _generateTemplateId(),
      name: name,
      description: description,
      category: category,
      icon: page.icon,
      blocks: templateBlocks,
      createdBy: 'user', // Would be actual user ID in real app
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      tags: tags,
    );
  }

  /// Get featured templates for quick access
  List<PageTemplate> getFeaturedTemplates() {
    final allTemplates = SubjectTemplates.getAcademicTemplates();
    // Return most popular/useful templates
    return allTemplates.where((template) => 
      ['math_notes_template', 'science_lab_template', 'project_planning_template']
        .contains(template.id)
    ).toList();
  }

  /// Get templates by usage count (most popular)
  Future<List<PageTemplate>> getPopularTemplates({int limit = 6}) async {
    final allTemplates = await getAllTemplates();
    allTemplates.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return allTemplates.take(limit).toList();
  }

  /// Get recent templates used by the user
  Future<List<PageTemplate>> getRecentTemplates({int limit = 5}) async {
    // In a real app, this would track user usage
    // For now, return a subset of templates
    final allTemplates = await getAllTemplates();
    return allTemplates.take(limit).toList();
  }

  /// Check if content contains placeholder text
  bool _isPlaceholderContent(Map<String, dynamic> content) {
    final text = content['text']?.toString() ?? '';
    return text.contains('[') && text.contains(']') ||
           text.contains('...') ||
           text.toLowerCase().contains('ejemplo') ||
           text.toLowerCase().contains('placeholder') ||
           text.toLowerCase().contains('escribe');
  }

  /// Generate placeholder text for content
  String? _getPlaceholderText(Map<String, dynamic> content) {
    final text = content['text']?.toString() ?? '';
    if (_isPlaceholderContent(content)) {
      return 'Edita este contenido';
    }
    return null;
  }

  /// Generate unique block ID
  String _generateBlockId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           '_' + 
           (DateTime.now().microsecond % 1000).toString();
  }

  /// Generate unique template ID
  String _generateTemplateId() {
    return 'custom_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Validate template data
  bool validateTemplate(PageTemplate template) {
    if (template.name.isEmpty) return false;
    if (template.blocks.isEmpty) return false;
    if (template.category.isEmpty) return false;
    return true;
  }

  /// Get template preview (first few blocks for display)
  List<TemplateBlock> getTemplatePreview(PageTemplate template, {int maxBlocks = 3}) {
    return template.blocks.take(maxBlocks).toList();
  }

  /// Update template usage count
  Future<void> incrementTemplateUsage(String templateId) async {
    // In a real app, this would update the database
    // For now, just log the usage
    print('Template $templateId was used');
  }
}