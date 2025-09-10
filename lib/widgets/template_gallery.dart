import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/template.dart';

class TemplateGallery extends StatefulWidget {
  final Function(NotionTemplate) onTemplateSelected;

  const TemplateGallery({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  State<TemplateGallery> createState() => _TemplateGalleryState();
}

class _TemplateGalleryState extends State<TemplateGallery> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Personal',
    'Business',
    'Education',
    'Planning',
    'Creative',
  ];

  final List<NotionTemplate> _templates = [
    NotionTemplate(
      id: '1',
      name: 'Daily Journal',
      description: 'Track your daily thoughts and activities',
      category: 'Personal',
      icon: '📔',
      previewImage: 'assets/templates/journal.png',
      blocks: [
        {'type': 'heading1', 'content': 'Daily Journal - [Today\'s Date]'},
        {'type': 'heading2', 'content': '🌅 Morning Thoughts'},
        {'type': 'paragraph', 'content': 'How are you feeling today?'},
        {'type': 'heading2', 'content': '✅ Today\'s Goals'},
        {'type': 'todo', 'content': 'Add your daily goals here'},
        {'type': 'heading2', 'content': '🌙 Evening Reflection'},
        {'type': 'paragraph', 'content': 'What went well today?'},
      ],
    ),
    NotionTemplate(
      id: '2',
      name: 'Meeting Notes',
      description: 'Structured template for meeting documentation',
      category: 'Business',
      icon: '📝',
      previewImage: 'assets/templates/meeting.png',
      blocks: [
        {'type': 'heading1', 'content': 'Meeting Notes'},
        {'type': 'paragraph', 'content': '**Date:** [Insert Date]'},
        {'type': 'paragraph', 'content': '**Attendees:** [List attendees]'},
        {'type': 'heading2', 'content': '📋 Agenda'},
        {'type': 'bulleted-list', 'content': 'Agenda item 1'},
        {'type': 'heading2', 'content': '🗣️ Discussion Points'},
        {'type': 'paragraph', 'content': 'Key discussion points...'},
        {'type': 'heading2', 'content': '✅ Action Items'},
        {'type': 'todo', 'content': 'Action item with assignee'},
      ],
    ),
    NotionTemplate(
      id: '3',
      name: 'Project Proposal',
      description: 'Comprehensive project proposal template',
      category: 'Business',
      icon: '🚀',
      previewImage: 'assets/templates/proposal.png',
      blocks: [
        {'type': 'heading1', 'content': 'Project Proposal'},
        {'type': 'heading2', 'content': '📖 Executive Summary'},
        {'type': 'paragraph', 'content': 'Brief overview of the project...'},
        {'type': 'heading2', 'content': '🎯 Objectives'},
        {'type': 'bulleted-list', 'content': 'Primary objective'},
        {'type': 'heading2', 'content': '📊 Timeline & Milestones'},
        {'type': 'paragraph', 'content': 'Project timeline...'},
        {'type': 'heading2', 'content': '💰 Budget'},
        {'type': 'paragraph', 'content': 'Budget breakdown...'},
      ],
    ),
    NotionTemplate(
      id: '4',
      name: 'Class Notes',
      description: 'Organized template for academic note-taking',
      category: 'Education',
      icon: '🎓',
      previewImage: 'assets/templates/class.png',
      blocks: [
        {'type': 'heading1', 'content': 'Class Notes - [Subject]'},
        {'type': 'paragraph', 'content': '**Date:** [Date]'},
        {'type': 'paragraph', 'content': '**Topic:** [Lesson Topic]'},
        {'type': 'heading2', 'content': '📚 Key Concepts'},
        {'type': 'bulleted-list', 'content': 'Important concept 1'},
        {'type': 'heading2', 'content': '📝 Notes'},
        {'type': 'paragraph', 'content': 'Detailed notes...'},
        {'type': 'heading2', 'content': '❓ Questions'},
        {'type': 'paragraph', 'content': 'Questions to ask...'},
      ],
    ),
    NotionTemplate(
      id: '5',
      name: 'Weekly Planner',
      description: 'Plan your week with goals and tasks',
      category: 'Planning',
      icon: '📅',
      previewImage: 'assets/templates/weekly.png',
      blocks: [
        {'type': 'heading1', 'content': 'Weekly Planner - Week of [Date]'},
        {'type': 'heading2', 'content': '🎯 This Week\'s Priorities'},
        {'type': 'todo', 'content': 'Priority 1'},
        {'type': 'heading2', 'content': '📝 Daily Breakdown'},
        {'type': 'heading3', 'content': 'Monday'},
        {'type': 'todo', 'content': 'Monday task'},
        {'type': 'heading3', 'content': 'Tuesday'},
        {'type': 'todo', 'content': 'Tuesday task'},
      ],
    ),
    NotionTemplate(
      id: '6',
      name: 'Creative Brief',
      description: 'Template for creative projects and campaigns',
      category: 'Creative',
      icon: '🎨',
      previewImage: 'assets/templates/creative.png',
      blocks: [
        {'type': 'heading1', 'content': 'Creative Brief'},
        {'type': 'heading2', 'content': '📋 Project Overview'},
        {'type': 'paragraph', 'content': 'Project description...'},
        {'type': 'heading2', 'content': '🎯 Target Audience'},
        {'type': 'paragraph', 'content': 'Define target audience...'},
        {'type': 'heading2', 'content': '💡 Key Messages'},
        {'type': 'bulleted-list', 'content': 'Message 1'},
        {'type': 'heading2', 'content': '🎨 Visual Direction'},
        {'type': 'paragraph', 'content': 'Visual style guide...'},
      ],
    ),
  ];

  List<NotionTemplate> get _filteredTemplates {
    if (_selectedCategory == 'All') return _templates;
    return _templates.where((template) => template.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 600,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(theme),
          _buildCategoryTabs(theme),
          Expanded(
            child: _buildTemplateGrid(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.dashboard_customize,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Template Gallery',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Choose a template to get started quickly',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    ).animate().slideY(begin: -0.1, duration: 300.ms).fadeIn();
  }

  Widget _buildCategoryTabs(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = category == _selectedCategory;

            return Padding(
              padding: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
              child: Material(
                type: MaterialType.transparency,
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = category);
                  },
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ).animate(delay: (index * 50).ms).slideX(
                begin: -0.1,
                duration: 200.ms,
              ).fadeIn(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTemplateGrid(ThemeData theme) {
    final filteredTemplates = _filteredTemplates;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTemplates.length,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        return _buildTemplateCard(theme, template, index);
      },
    );
  }

  Widget _buildTemplateCard(ThemeData theme, NotionTemplate template, int index) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onTemplateSelected(template);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Preview/Icon
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Text(
                  template.icon ?? '',
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),

            // Template Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            template.category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).scale(
      begin: const Offset(0.9, 0.9),
      duration: 300.ms,
      curve: Curves.easeOut,
    ).fadeIn();
  }
}