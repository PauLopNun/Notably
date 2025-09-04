import 'package:freezed_annotation/freezed_annotation.dart';
import 'block.dart';

part 'template.freezed.dart';
part 'template.g.dart';

@freezed
class PageTemplate with _$PageTemplate {
  const factory PageTemplate({
    required String id,
    required String name,
    String? description,
    required String category,
    String? icon,
    String? coverImage,
    required List<TemplateBlock> blocks,
    @Default([]) List<TemplateProperty> properties,
    @Default(false) bool isPublic,
    @Default(false) bool isOfficial,
    required String createdBy,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int usageCount,
    @Default([]) List<String> tags,
  }) = _PageTemplate;

  factory PageTemplate.fromJson(Map<String, dynamic> json) =>
      _$PageTemplateFromJson(json);

  factory PageTemplate.fromMap(Map<String, dynamic> map) {
    return PageTemplate(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'general',
      icon: map['icon'],
      coverImage: map['cover_image'],
      blocks: (map['blocks'] as List?)
          ?.map((b) => TemplateBlock.fromMap(b))
          .toList() ?? [],
      properties: (map['properties'] as List?)
          ?.map((p) => TemplateProperty.fromMap(p))
          .toList() ?? [],
      isPublic: map['is_public'] ?? false,
      isOfficial: map['is_official'] ?? false,
      createdBy: map['created_by'].toString(),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      usageCount: map['usage_count'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'cover_image': coverImage,
      'blocks': blocks.map((b) => b.toMap()).toList(),
      'properties': properties.map((p) => p.toMap()).toList(),
      'is_public': isPublic,
      'is_official': isOfficial,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'usage_count': usageCount,
      'tags': tags,
    };
  }
}

@freezed
class TemplateBlock with _$TemplateBlock {
  const factory TemplateBlock({
    required String id,
    String? parentBlockId,
    required BlockType type,
    @Default({}) Map<String, dynamic> content,
    @Default({}) Map<String, dynamic> properties,
    @Default(0) int position,
    @Default(false) bool isPlaceholder,
    String? placeholderText,
  }) = _TemplateBlock;

  factory TemplateBlock.fromJson(Map<String, dynamic> json) =>
      _$TemplateBlockFromJson(json);

  factory TemplateBlock.fromMap(Map<String, dynamic> map) {
    return TemplateBlock(
      id: map['id'].toString(),
      parentBlockId: map['parent_block_id']?.toString(),
      type: BlockType.fromString(map['type'] ?? 'paragraph'),
      content: Map<String, dynamic>.from(map['content'] ?? {}),
      properties: Map<String, dynamic>.from(map['properties'] ?? {}),
      position: map['position'] ?? 0,
      isPlaceholder: map['is_placeholder'] ?? false,
      placeholderText: map['placeholder_text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_block_id': parentBlockId,
      'type': type.value,
      'content': content,
      'properties': properties,
      'position': position,
      'is_placeholder': isPlaceholder,
      'placeholder_text': placeholderText,
    };
  }
}

@freezed
class TemplateProperty with _$TemplateProperty {
  const factory TemplateProperty({
    required String id,
    required String name,
    required TemplatePropertyType type,
    @Default({}) Map<String, dynamic> options,
    @Default(false) bool isRequired,
    String? defaultValue,
    String? description,
  }) = _TemplateProperty;

  factory TemplateProperty.fromJson(Map<String, dynamic> json) =>
      _$TemplatePropertyFromJson(json);

  factory TemplateProperty.fromMap(Map<String, dynamic> map) {
    return TemplateProperty(
      id: map['id'].toString(),
      name: map['name'] ?? '',
      type: TemplatePropertyType.fromString(map['type'] ?? 'text'),
      options: Map<String, dynamic>.from(map['options'] ?? {}),
      isRequired: map['is_required'] ?? false,
      defaultValue: map['default_value'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'options': options,
      'is_required': isRequired,
      'default_value': defaultValue,
      'description': description,
    };
  }
}

enum TemplatePropertyType {
  text('text'),
  number('number'),
  date('date'),
  select('select'),
  multiSelect('multi_select'),
  checkbox('checkbox'),
  url('url'),
  email('email'),
  person('person'),
  file('file');

  const TemplatePropertyType(this.value);
  final String value;

  static TemplatePropertyType fromString(String value) {
    return TemplatePropertyType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TemplatePropertyType.text,
    );
  }
}

enum TemplateCategory {
  academic('academic'),
  meeting('meeting'),
  project('project'),
  personal('personal'),
  research('research'),
  notes('notes'),
  planning('planning'),
  documentation('documentation');

  const TemplateCategory(this.value);
  final String value;

  static TemplateCategory fromString(String value) {
    return TemplateCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => TemplateCategory.notes,
    );
  }

  String get displayName {
    switch (this) {
      case TemplateCategory.academic:
        return 'Académico';
      case TemplateCategory.meeting:
        return 'Reuniones';
      case TemplateCategory.project:
        return 'Proyectos';
      case TemplateCategory.personal:
        return 'Personal';
      case TemplateCategory.research:
        return 'Investigación';
      case TemplateCategory.notes:
        return 'Notas';
      case TemplateCategory.planning:
        return 'Planificación';
      case TemplateCategory.documentation:
        return 'Documentación';
    }
  }

  String get icon {
    switch (this) {
      case TemplateCategory.academic:
        return '🎓';
      case TemplateCategory.meeting:
        return '🤝';
      case TemplateCategory.project:
        return '📊';
      case TemplateCategory.personal:
        return '👤';
      case TemplateCategory.research:
        return '🔬';
      case TemplateCategory.notes:
        return '📝';
      case TemplateCategory.planning:
        return '📅';
      case TemplateCategory.documentation:
        return '📚';
    }
  }
}

// Pre-defined templates for different subjects
class SubjectTemplates {
  static List<PageTemplate> getAcademicTemplates() {
    return [
      _createMathNotesTemplate(),
      _createScienceLabReportTemplate(),
      _createHistoryEssayTemplate(),
      _createLiteratureAnalysisTemplate(),
      _createLanguageVocabularyTemplate(),
      _createProjectPlanningTemplate(),
    ];
  }

  static PageTemplate _createMathNotesTemplate() {
    return PageTemplate(
      id: 'math_notes_template',
      name: 'Notas de Matemáticas',
      description: 'Template para tomar notas de clases de matemáticas con secciones para teoremas, ejemplos y ejercicios',
      category: 'academic',
      icon: '🔢',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': 'Tema: [Nombre del tema]'},
          isPlaceholder: true,
          placeholderText: 'Escribe el tema de la clase',
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.heading2,
          content: {'text': 'Conceptos Clave'},
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.bulletedList,
          content: {'text': 'Concepto 1'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.heading2,
          content: {'text': 'Fórmulas y Teoremas'},
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.code,
          content: {'code': 'Escribe las fórmulas aquí', 'language': 'latex'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.heading2,
          content: {'text': 'Ejemplos'},
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.paragraph,
          content: {'text': 'Ejemplo 1: '},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.heading2,
          content: {'text': 'Ejercicios'},
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.todo,
          content: {'text': 'Ejercicio 1', 'checked': false},
          isPlaceholder: true,
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['matemáticas', 'académico', 'notas'],
    );
  }

  static PageTemplate _createScienceLabReportTemplate() {
    return PageTemplate(
      id: 'science_lab_template',
      name: 'Reporte de Laboratorio',
      description: 'Template para reportes de experimentos científicos',
      category: 'academic',
      icon: '🔬',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': 'Experimento: [Nombre]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.heading2,
          content: {'text': 'Objetivo'},
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.paragraph,
          content: {'text': 'Describir el objetivo del experimento...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.heading2,
          content: {'text': 'Hipótesis'},
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.paragraph,
          content: {'text': 'Mi hipótesis es que...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.heading2,
          content: {'text': 'Materiales'},
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.bulletedList,
          content: {'text': 'Material 1'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.heading2,
          content: {'text': 'Procedimiento'},
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.numberedList,
          content: {'text': 'Paso 1'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '10',
          type: BlockType.heading2,
          content: {'text': 'Resultados'},
        ),
        TemplateBlock(
          id: '11',
          type: BlockType.paragraph,
          content: {'text': 'Los resultados obtenidos fueron...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '12',
          type: BlockType.heading2,
          content: {'text': 'Conclusiones'},
        ),
        TemplateBlock(
          id: '13',
          type: BlockType.paragraph,
          content: {'text': 'En conclusión...'},
          isPlaceholder: true,
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['ciencias', 'laboratorio', 'experimento'],
    );
  }

  static PageTemplate _createHistoryEssayTemplate() {
    return PageTemplate(
      id: 'history_essay_template',
      name: 'Ensayo de Historia',
      description: 'Template para ensayos de historia con estructura académica',
      category: 'academic',
      icon: '📜',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': '[Título del Ensayo]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.heading2,
          content: {'text': 'Introducción'},
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.paragraph,
          content: {'text': 'La introducción debe presentar el tema y la tesis...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.heading2,
          content: {'text': 'Desarrollo'},
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.heading3,
          content: {'text': 'Punto 1: [Argumento principal]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.paragraph,
          content: {'text': 'Desarrollar el primer argumento...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.heading3,
          content: {'text': 'Punto 2: [Segundo argumento]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.paragraph,
          content: {'text': 'Desarrollar el segundo argumento...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.heading2,
          content: {'text': 'Conclusión'},
        ),
        TemplateBlock(
          id: '10',
          type: BlockType.paragraph,
          content: {'text': 'En conclusión, este ensayo ha demostrado que...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '11',
          type: BlockType.heading2,
          content: {'text': 'Bibliografía'},
        ),
        TemplateBlock(
          id: '12',
          type: BlockType.bulletedList,
          content: {'text': 'Fuente 1'},
          isPlaceholder: true,
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['historia', 'ensayo', 'académico'],
    );
  }

  static PageTemplate _createLiteratureAnalysisTemplate() {
    return PageTemplate(
      id: 'literature_analysis_template',
      name: 'Análisis Literario',
      description: 'Template para análisis de obras literarias',
      category: 'academic',
      icon: '📚',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': 'Análisis de: [Título de la obra]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.paragraph,
          content: {'text': 'Autor: [Nombre del autor]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.heading2,
          content: {'text': 'Contexto Histórico'},
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.paragraph,
          content: {'text': 'La obra fue escrita en el contexto de...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.heading2,
          content: {'text': 'Personajes Principales'},
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.bulletedList,
          content: {'text': 'Personaje 1: [Descripción]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.heading2,
          content: {'text': 'Temas Principales'},
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.bulletedList,
          content: {'text': 'Tema 1: [Explicación]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.heading2,
          content: {'text': 'Recursos Literarios'},
        ),
        TemplateBlock(
          id: '10',
          type: BlockType.bulletedList,
          content: {'text': 'Recurso 1: [Ejemplo]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '11',
          type: BlockType.heading2,
          content: {'text': 'Conclusiones'},
        ),
        TemplateBlock(
          id: '12',
          type: BlockType.paragraph,
          content: {'text': 'Mi análisis concluye que...'},
          isPlaceholder: true,
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['literatura', 'análisis', 'académico'],
    );
  }

  static PageTemplate _createLanguageVocabularyTemplate() {
    return PageTemplate(
      id: 'language_vocabulary_template',
      name: 'Vocabulario de Idiomas',
      description: 'Template para aprender vocabulario de idiomas extranjeros',
      category: 'academic',
      icon: '🗣️',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': 'Vocabulario: [Tema/Unidad]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.paragraph,
          content: {'text': 'Idioma: [Nombre del idioma]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.heading2,
          content: {'text': 'Palabras Nuevas'},
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.bulletedList,
          content: {'text': '[Palabra] - [Traducción] - [Ejemplo de uso]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.heading2,
          content: {'text': 'Frases Útiles'},
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.bulletedList,
          content: {'text': '[Frase] - [Traducción] - [Contexto]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.heading2,
          content: {'text': 'Gramática'},
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.paragraph,
          content: {'text': 'Reglas gramaticales importantes...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.heading2,
          content: {'text': 'Ejercicios'},
        ),
        TemplateBlock(
          id: '10',
          type: BlockType.todo,
          content: {'text': 'Practicar conjugación', 'checked': false},
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['idiomas', 'vocabulario', 'aprendizaje'],
    );
  }

  static PageTemplate _createProjectPlanningTemplate() {
    return PageTemplate(
      id: 'project_planning_template',
      name: 'Planificación de Proyecto',
      description: 'Template para planificar proyectos académicos o personales',
      category: 'planning',
      icon: '📋',
      blocks: [
        TemplateBlock(
          id: '1',
          type: BlockType.heading1,
          content: {'text': 'Proyecto: [Nombre del proyecto]'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '2',
          type: BlockType.heading2,
          content: {'text': 'Descripción'},
        ),
        TemplateBlock(
          id: '3',
          type: BlockType.paragraph,
          content: {'text': 'Este proyecto consiste en...'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '4',
          type: BlockType.heading2,
          content: {'text': 'Objetivos'},
        ),
        TemplateBlock(
          id: '5',
          type: BlockType.bulletedList,
          content: {'text': 'Objetivo 1'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '6',
          type: BlockType.heading2,
          content: {'text': 'Cronograma'},
        ),
        TemplateBlock(
          id: '7',
          type: BlockType.todo,
          content: {'text': 'Tarea 1 - Fecha límite: [fecha]', 'checked': false},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '8',
          type: BlockType.heading2,
          content: {'text': 'Recursos Necesarios'},
        ),
        TemplateBlock(
          id: '9',
          type: BlockType.bulletedList,
          content: {'text': 'Recurso 1'},
          isPlaceholder: true,
        ),
        TemplateBlock(
          id: '10',
          type: BlockType.heading2,
          content: {'text': 'Notas y Observaciones'},
        ),
        TemplateBlock(
          id: '11',
          type: BlockType.paragraph,
          content: {'text': 'Notas adicionales...'},
          isPlaceholder: true,
        ),
      ],
      createdBy: 'system',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOfficial: true,
      tags: ['planificación', 'proyecto', 'organización'],
    );
  }
}