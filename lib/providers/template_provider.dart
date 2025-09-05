import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/template.dart';
import '../models/page.dart';
import '../services/template_service.dart';
import '../services/workspace_service.dart';

// Template service provider
final templateServiceProvider = Provider<TemplateService>((ref) {
  final workspaceService = ref.read(workspaceServiceProvider);
  return TemplateService(workspaceService);
});

// All templates provider
final templatesProvider = FutureProvider<List<PageTemplate>>((ref) async {
  final templateService = ref.read(templateServiceProvider);
  return templateService.getAllTemplates();
});

// Templates by category provider
final templatesByCategoryProvider = FutureProvider.family<List<PageTemplate>, String>((ref, category) async {
  final templateService = ref.read(templateServiceProvider);
  return templateService.getTemplatesByCategory(category);
});

// Featured templates provider
final featuredTemplatesProvider = Provider<List<PageTemplate>>((ref) {
  final templateService = ref.read(templateServiceProvider);
  return templateService.getFeaturedTemplates();
});

// Popular templates provider
final popularTemplatesProvider = FutureProvider<List<PageTemplate>>((ref) async {
  final templateService = ref.read(templateServiceProvider);
  return templateService.getPopularTemplates();
});

// Recent templates provider
final recentTemplatesProvider = FutureProvider<List<PageTemplate>>((ref) async {
  final templateService = ref.read(templateServiceProvider);
  return templateService.getRecentTemplates();
});

// Template search provider
final templateSearchProvider = StateNotifierProvider<TemplateSearchNotifier, AsyncValue<List<PageTemplate>>>((ref) {
  return TemplateSearchNotifier(ref.read(templateServiceProvider));
});

class TemplateSearchNotifier extends StateNotifier<AsyncValue<List<PageTemplate>>> {
  final TemplateService _templateService;

  TemplateSearchNotifier(this._templateService) : super(const AsyncValue.data([]));

  Future<void> searchTemplates(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final results = await _templateService.searchTemplates(query);
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

// Template application state provider
final templateApplicationProvider = StateNotifierProvider<TemplateApplicationNotifier, TemplateApplicationState>((ref) {
  return TemplateApplicationNotifier(ref.read(templateServiceProvider));
});

class TemplateApplicationNotifier extends StateNotifier<TemplateApplicationState> {
  final TemplateService _templateService;

  TemplateApplicationNotifier(this._templateService) : super(const TemplateApplicationState.idle());

  Future<void> applyTemplate({
    required PageTemplate template,
    required String workspaceId,
    String? customTitle,
    String? parentId,
  }) async {
    state = const TemplateApplicationState.applying();
    
    try {
      final page = await _templateService.applyTemplate(
        template: template,
        workspaceId: workspaceId,
        customTitle: customTitle,
        parentId: parentId,
      );
      
      // Increment usage count
      await _templateService.incrementTemplateUsage(template.id);
      
      state = TemplateApplicationState.success(page);
    } catch (error, stackTrace) {
      state = TemplateApplicationState.error(error.toString());
    }
  }

  Future<void> createTemplateFromPage({
    required NotionPage page,
    required List<dynamic> blocks, // PageBlock list
    required String name,
    String? description,
    required String category,
    List<String> tags = const [],
  }) async {
    state = const TemplateApplicationState.applying();
    
    try {
      final template = await _templateService.createTemplateFromPage(
        page: page,
        blocks: blocks.cast(),
        name: name,
        description: description,
        category: category,
        tags: tags,
      );
      
      state = TemplateApplicationState.templateCreated(template);
    } catch (error, stackTrace) {
      state = TemplateApplicationState.error(error.toString());
    }
  }

  void reset() {
    state = const TemplateApplicationState.idle();
  }
}

// Template application state
abstract class TemplateApplicationState {
  const TemplateApplicationState();

  const factory TemplateApplicationState.idle() = _Idle;
  const factory TemplateApplicationState.applying() = _Applying;
  const factory TemplateApplicationState.success(NotionPage page) = _Success;
  const factory TemplateApplicationState.templateCreated(PageTemplate template) = _TemplateCreated;
  const factory TemplateApplicationState.error(String message) = _Error;
}

class _Idle extends TemplateApplicationState {
  const _Idle();
}

class _Applying extends TemplateApplicationState {
  const _Applying();
}

class _Success extends TemplateApplicationState {
  final NotionPage page;
  const _Success(this.page);
}

class _TemplateCreated extends TemplateApplicationState {
  final PageTemplate template;
  const _TemplateCreated(this.template);
}

class _Error extends TemplateApplicationState {
  final String message;
  const _Error(this.message);
}

// Template categories provider
final templateCategoriesProvider = Provider<List<TemplateCategory>>((ref) {
  return TemplateCategory.values;
});

// Selected template provider (for preview/details)
final selectedTemplateProvider = StateProvider<PageTemplate?>((ref) => null);