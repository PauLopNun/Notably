import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late QuillController _quillController;
  final _titleController = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;

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
  }

  void _onContentChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _saveNote(WidgetRef ref) async {
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
          title: title,
          content: content,
          createdAt: DateTime.now(),
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
          title: title,
          content: content,
          createdAt: widget.note!.createdAt,
        );
        
        await ref.read(notesProvider.notifier).updateNote(updatedNote);
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

      if (context.mounted) {
        Navigator.of(context).pop();
      }
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

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Descartar cambios?'),
          content: const Text('Tienes cambios sin guardar. ¿Quieres descartarlos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Descartar'),
            ),
          ],
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6FA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              title: Text(
                widget.note == null ? 'Nueva nota' : 'Editar nota',
                style: const TextStyle(
                  color: Color(0xFF22223B), 
                  fontWeight: FontWeight.bold
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF22223B)),
              actions: [
                if (_hasChanges)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Sin guardar',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                IconButton(
                  icon: _isSaving 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save, color: Color(0xFF4A4E69)),
                  tooltip: 'Guardar',
                  onPressed: _isSaving ? null : () => _saveNote(ref),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22223B),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Título de la nota',
                          hintStyle: TextStyle(
                            color: Color(0xFF9A8C98),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF2E9E4)),
                    
                    // Simple toolbar with basic formatting
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          topRight: Radius.circular(0),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.bold),
                            tooltip: 'Negrita',
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.italic),
                            tooltip: 'Cursiva',
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_underline, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.underline),
                            tooltip: 'Subrayado',
                          ),
                          const VerticalDivider(width: 1),
                          IconButton(
                            icon: const Icon(Icons.format_list_bulleted, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.ul),
                            tooltip: 'Lista',
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_list_numbered, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.ol),
                            tooltip: 'Lista numerada',
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_quote, size: 20),
                            onPressed: () => _quillController.formatSelection(Attribute.blockQuote),
                            tooltip: 'Cita',
                          ),
                        ],
                      ),
                    ),
                    
                    // Quill editor
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: QuillEditor(
                          controller: _quillController,
                          focusNode: FocusNode(),
                          scrollController: ScrollController(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
