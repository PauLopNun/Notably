import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../models/note.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late quill.QuillController _quillController;
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quillController = widget.note != null
      ? quill.QuillController(
          document: quill.Document.fromJson(widget.note!.content.isNotEmpty
              ? widget.note!.content
              : []),
          selection: const TextSelection.collapsed(offset: 0),
        )
      : quill.QuillController.basic();
    _titleController.text = widget.note?.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.note == null ? 'Nueva nota' : 'Editar nota'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () async {
                  final title = _titleController.text.trim();
                  final content = _quillController.document.toDelta().toJson();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('El título no puede estar vacío')),
                    );
                    return;
                  }
                  if (widget.note == null) {
                    // Crear nueva nota
                    final newNote = Note(
                      id: '', // Supabase asigna el id
                      userId: '', // Se asigna en el servicio
                      title: title,
                      content: content,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(notesProvider.notifier).addNote(newNote);
                  } else {
                    // Actualizar nota existente
                    final updatedNote = Note(
                      id: widget.note!.id,
                      userId: widget.note!.userId,
                      title: title,
                      content: content,
                      createdAt: widget.note!.createdAt,
                    );
                    await ref.read(notesProvider.notifier).updateNote(updatedNote);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título de la nota',
                  ),
                ),
                const SizedBox(height: 12),
                // Barra de herramientas eliminada para compatibilidad
                const SizedBox(height: 12),
                Expanded(
                  child: quill.QuillEditor(
                    focusNode: FocusNode(),
                    scrollController: ScrollController(),
                    configurations: quill.QuillEditorConfigurations(
                      readOnly: false,
                      expands: true,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
