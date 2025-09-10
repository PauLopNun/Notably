class NotionTemplate {
  final String id;
  final String name;
  final String? description;
  final String category;
  final String? icon;
  final String previewImage;
  final List<Map<String, dynamic>> blocks;
  final bool isOfficial;
  final List<String> tags;

  NotionTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.icon,
    required this.previewImage,
    required this.blocks,
    this.isOfficial = false,
    this.tags = const [],
  });

  NotionTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? icon,
    String? previewImage,
    List<Map<String, dynamic>>? blocks,
    bool? isOfficial,
    List<String>? tags,
  }) {
    return NotionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      previewImage: previewImage ?? this.previewImage,
      blocks: blocks ?? this.blocks,
      isOfficial: isOfficial ?? this.isOfficial,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'previewImage': previewImage,
      'blocks': blocks,
      'isOfficial': isOfficial,
      'tags': tags,
    };
  }

  factory NotionTemplate.fromJson(Map<String, dynamic> json) {
    return NotionTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      category: json['category'] ?? '',
      icon: json['icon'],
      previewImage: json['previewImage'] ?? '',
      blocks: List<Map<String, dynamic>>.from(json['blocks'] ?? []),
      isOfficial: json['isOfficial'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// Template categories enum for better type safety
enum TemplateCategory {
  all,
  personal,
  business,
  education,
  planning,
  creative,
}

extension TemplateCategoryExtension on TemplateCategory {
  static TemplateCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return TemplateCategory.all;
      case 'personal':
        return TemplateCategory.personal;
      case 'business':
        return TemplateCategory.business;
      case 'education':
        return TemplateCategory.education;
      case 'planning':
        return TemplateCategory.planning;
      case 'creative':
        return TemplateCategory.creative;
      default:
        return TemplateCategory.all;
    }
  }

  String get displayName {
    switch (this) {
      case TemplateCategory.all:
        return 'All';
      case TemplateCategory.personal:
        return 'Personal';
      case TemplateCategory.business:
        return 'Business';
      case TemplateCategory.education:
        return 'Education';
      case TemplateCategory.planning:
        return 'Planning';
      case TemplateCategory.creative:
        return 'Creative';
    }
  }
}

// PageTemplate alias for NotionTemplate for backward compatibility
typedef PageTemplate = NotionTemplate;

// Subject templates for education category
class SubjectTemplates {
  static List<NotionTemplate> getAcademicTemplates() => [
    NotionTemplate(
      id: 'math_template',
      name: 'Mathematics Notes',
      description: 'Template for math class notes with equations',
      category: 'education',
      icon: '📐',
      previewImage: '',
      blocks: [
        {'type': 'heading', 'text': 'Mathematics - Topic'},
        {'type': 'text', 'text': 'Date: '},
        {'type': 'text', 'text': 'Key Concepts:'},
        {'type': 'bullet_list', 'items': ['Concept 1', 'Concept 2']},
        {'type': 'text', 'text': 'Examples:'},
        {'type': 'text', 'text': 'Practice Problems:'},
      ],
      isOfficial: true,
      tags: ['math', 'equations', 'academic'],
    ),
    NotionTemplate(
      id: 'science_template',
      name: 'Science Lab Report',
      description: 'Template for science lab reports',
      category: 'education',
      icon: '🔬',
      previewImage: '',
      blocks: [
        {'type': 'heading', 'text': 'Lab Report - '},
        {'type': 'text', 'text': 'Date: '},
        {'type': 'text', 'text': 'Objective:'},
        {'type': 'text', 'text': 'Materials:'},
        {'type': 'text', 'text': 'Procedure:'},
        {'type': 'text', 'text': 'Results:'},
        {'type': 'text', 'text': 'Conclusion:'},
      ],
      isOfficial: true,
      tags: ['science', 'lab', 'report'],
    ),
    NotionTemplate(
      id: 'history_template',
      name: 'History Notes',
      description: 'Template for history class notes',
      category: 'education',
      icon: '📚',
      previewImage: '',
      blocks: [
        {'type': 'heading', 'text': 'History - '},
        {'type': 'text', 'text': 'Date: '},
        {'type': 'text', 'text': 'Period/Era: '},
        {'type': 'text', 'text': 'Key Events:'},
        {'type': 'bullet_list', 'items': ['Event 1', 'Event 2']},
        {'type': 'text', 'text': 'Important Figures:'},
        {'type': 'text', 'text': 'Summary:'},
      ],
      isOfficial: true,
      tags: ['history', 'events', 'academic'],
    ),
  ];

  static List<NotionTemplate> get all => [
    ...getAcademicTemplates(),
  ];
}