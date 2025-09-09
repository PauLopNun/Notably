import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NotionBlockEditor extends StatefulWidget {
  final QuillController controller;
  final VoidCallback? onChanged;

  const NotionBlockEditor({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  State<NotionBlockEditor> createState() => _NotionBlockEditorState();
}

class _NotionBlockEditorState extends State<NotionBlockEditor> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleContentChange);
  }

  void _handleContentChange() {
    if (widget.onChanged != null) {
      widget.onChanged!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: QuillEditor.basic(
          controller: widget.controller,
        ),
      ),
    );
  }


  @override
  void dispose() {
    widget.controller.removeListener(_handleContentChange);
    super.dispose();
  }
}