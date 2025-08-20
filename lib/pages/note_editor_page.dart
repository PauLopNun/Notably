import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            title: Text(
              widget.note == null ? 'Nueva nota' : 'Editar nota',
              style: const TextStyle(color: Color(0xFF22223B), fontWeight: FontWeight.bold),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF22223B)),
            actions: [
              IconButton(
                icon: const Icon(Icons.save, color: Color(0xFF4A4E69)),
                tooltip: 'Guardar',
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
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Usuario no autenticado')),
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
                  } else {
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Título de la nota',
                        hintStyle: TextStyle(color: Color(0xFF9A8C98)),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2E9E4)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: quill.QuillEditor(
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
        );
      },
    );
  }
}
