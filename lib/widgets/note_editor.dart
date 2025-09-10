import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/realtime_collab_service.dart';

class NoteEditor extends ConsumerStatefulWidget {
  final Note? note;
  final VoidCallback onClose;

  const NoteEditor({
    super.key,
    this.note,
    required this.onClose,
  });

  @override
  ConsumerState<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends ConsumerState<NoteEditor> {
  late QuillController _quillController;
  final _titleController = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;
  RealtimeCollabService? _collab;
  StreamSubscription<dynamic>? _deltaSub;
  Timer? _debounce;
  String _selectedCategory = '📝 Notas';

  @override
  void initState() {
    super.initState();
    _quillController = widget.note != null
      ? QuillController(
          document: Document.fromJson(widget.note!.content.isNotEmpty
              ? widget.note!.content
              : []),
          selection: const TextSelection.collapsed(offset: 0),
        )
      : QuillController.basic();
    _titleController.text = widget.note?.title ?? '';
    
    // Listen for changes
    _titleController.addListener(_onContentChanged);
    _quillController.addListener(_onContentChanged);

    // Setup realtime collab only for existing notes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.note != null) {
        _collab = RealtimeCollabService();
        await _collab!.joinDocument(widget.note!.id);
        _deltaSub = _collab!.incomingContentStream.listen((content) {
          try {
            _quillController = QuillController(
              document: Document.fromJson(content),
              selection: const TextSelection.collapsed(offset: 0),
            );
            setState(() {});
          } catch (_) {}
        });
      }
    });
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
    // Debounced full-content sync
    if (_collab != null && widget.note != null) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _collab!.sendFullContent(_quillController.document.toDelta().toJson());
      });
    }
  }

  String _applyCategoryPrefix(String oldTitle, String newTitle) {
    final categories = ['📝', '📚', '💼', '🎯', '📋', '💡', '📖'];
    String cleaned = newTitle;
    for (final emoji in categories) {
      if (cleaned.startsWith('$emoji ')) {
        cleaned = cleaned.substring(2);
      }
    }
    final selectedEmoji = _selectedCategory.split(' ').first;
    return '$selectedEmoji $cleaned';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _deltaSub?.cancel();
    _collab?.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final title = _titleController.text.trim();
      final content = _quillController.document.toDelta().toJson();
      
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El título no puede estar vacío'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (widget.note == null) {
        // Creating new note
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuario no autenticado'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        final newNote = Note(
          id: '',
          userId: user.id,
          title: '${_selectedCategory.split(' ').first} ${title}',
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await ref.read(notesProvider.notifier).addNote(newNote);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Updating existing note
        final updatedNote = Note(
          id: widget.note!.id,
          userId: widget.note!.userId,
          title: _applyCategoryPrefix(widget.note!.title, title),
          content: content,
          createdAt: widget.note!.createdAt,
          updatedAt: DateTime.now(),
        );
        
        await ref.read(notesProvider.notifier).updateNoteObject(updatedNote);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nota actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      setState(() {
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header del editor
          _buildEditorHeader(),
          
          // Toolbar avanzada
          _buildAdvancedToolbar(),
          
          // Separador
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          
          // Área de contenido
          Expanded(
            child: _buildContentArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Botón de cerrar
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            tooltip: 'Cerrar editor',
          ),
          
          const SizedBox(width: 16),
          
          // Campo de título
          Expanded(
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Título de la nota',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),

          // Categoría
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: const [
                '📝 Notas', '📚 Apuntes', '💼 Trabajo', '🎯 Proyectos',
                '📋 Tareas', '💡 Ideas', '📖 Lecturas'
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _selectedCategory = v);
                _onContentChanged();
              },
            ),
          ),
          
          // Indicador de cambios
          if (_hasChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.orange[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sin guardar',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(width: 16),
          
          // placeholder para controles adicionales
          const SizedBox.shrink(),
          
          const SizedBox(width: 8),
          
          // Botón de guardar
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveNote,
            icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
            label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Formato de texto
            _buildToolbarSection([
              _buildToolbarButton(
                icon: Icons.format_bold,
                tooltip: 'Negrita',
                onPressed: () => _quillController.formatSelection(Attribute.bold),
              ),
              _buildToolbarButton(
                icon: Icons.format_italic,
                tooltip: 'Cursiva',
                onPressed: () => _quillController.formatSelection(Attribute.italic),
              ),
              _buildToolbarButton(
                icon: Icons.format_underline,
                tooltip: 'Subrayado',
                onPressed: () => _quillController.formatSelection(Attribute.underline),
              ),
              _buildToolbarButton(
                icon: Icons.strikethrough_s,
                tooltip: 'Tachado',
                onPressed: () => _quillController.formatSelection(Attribute.strikeThrough),
              ),
            ]),
            
            const VerticalDivider(width: 1, thickness: 1),
            
            // Encabezados
            _buildToolbarSection([
              _buildToolbarButton(
                icon: Icons.title,
                tooltip: 'Título 1',
                onPressed: () => _quillController.formatSelection(Attribute.h1),
              ),
              _buildToolbarButton(
                icon: Icons.text_fields,
                tooltip: 'Título 2',
                onPressed: () => _quillController.formatSelection(Attribute.h2),
              ),
              _buildToolbarButton(
                icon: Icons.text_format,
                tooltip: 'Título 3',
                onPressed: () => _quillController.formatSelection(Attribute.h3),
              ),
            ]),
            
            const VerticalDivider(width: 1, thickness: 1),
            
            // Listas
            _buildToolbarSection([
              _buildToolbarButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'Lista con viñetas',
                onPressed: () => _quillController.formatSelection(Attribute.ul),
              ),
              _buildToolbarButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Lista numerada',
                onPressed: () => _quillController.formatSelection(Attribute.ol),
              ),
            ]),
            
            const VerticalDivider(width: 1, thickness: 1),
            
            // Alineación
            _buildToolbarSection([
              _buildToolbarButton(
                icon: Icons.format_align_left,
                tooltip: 'Alinear izquierda',
                onPressed: () {
                  // Implementar alineación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de alineación próximamente')),
                  );
                },
              ),
              _buildToolbarButton(
                icon: Icons.format_align_center,
                tooltip: 'Centrar',
                onPressed: () {
                  // Implementar alineación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de alineación próximamente')),
                  );
                },
              ),
              _buildToolbarButton(
                icon: Icons.format_align_right,
                tooltip: 'Alinear derecha',
                onPressed: () {
                  // Implementar alineación
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de alineación próximamente')),
                  );
                },
              ),
            ]),
            
            const VerticalDivider(width: 1, thickness: 1),
            
            // Elementos especiales
            _buildToolbarSection([
              _buildToolbarButton(
                icon: Icons.format_quote,
                tooltip: 'Cita',
                onPressed: () => _quillController.formatSelection(Attribute.blockQuote),
              ),
              _buildToolbarButton(
                icon: Icons.code,
                tooltip: 'Código',
                onPressed: () => _quillController.formatSelection(Attribute.codeBlock),
              ),
              _buildToolbarButton(
                icon: Icons.link,
                tooltip: 'Enlace',
                onPressed: () {
                  // Implementar inserción de enlaces
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de enlaces próximamente')),
                  );
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey[700],
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        hoverColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: QuillEditor(
        controller: _quillController,
        focusNode: FocusNode(),
        scrollController: ScrollController(),
      ),
    );
  }
}
