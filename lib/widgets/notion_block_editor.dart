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
      height: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolbarButton(theme, Icons.format_bold, 'Bold'),
                  _buildToolbarButton(theme, Icons.format_italic, 'Italic'),
                  _buildToolbarButton(theme, Icons.format_underlined, 'Underline'),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 20, color: theme.dividerColor),
                  const SizedBox(width: 8),
                  _buildToolbarButton(theme, Icons.format_list_bulleted, 'Bullet List'),
                  _buildToolbarButton(theme, Icons.format_list_numbered, 'Number List'),
                  _buildToolbarButton(theme, Icons.format_quote, 'Quote'),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 20, color: theme.dividerColor),
                  const SizedBox(width: 8),
                  _buildToolbarButton(theme, Icons.code, 'Code'),
                  _buildToolbarButton(theme, Icons.link, 'Link'),
                ],
              ),
            ),
          ),
          
          // Editor Area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: widget.controller,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(ThemeData theme, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // Handle toolbar actions
          switch (tooltip) {
            case 'Bold':
              widget.controller.formatText(
                widget.controller.selection.start,
                widget.controller.selection.end - widget.controller.selection.start,
                Attribute.bold,
              );
              break;
            case 'Italic':
              widget.controller.formatText(
                widget.controller.selection.start,
                widget.controller.selection.end - widget.controller.selection.start,
                Attribute.italic,
              );
              break;
            case 'Underline':
              widget.controller.formatText(
                widget.controller.selection.start,
                widget.controller.selection.end - widget.controller.selection.start,
                Attribute.underline,
              );
              break;
            case 'Bullet List':
              widget.controller.formatText(
                widget.controller.selection.start,
                0,
                Attribute.ul,
              );
              break;
            case 'Number List':
              widget.controller.formatText(
                widget.controller.selection.start,
                0,
                Attribute.ol,
              );
              break;
            case 'Quote':
              widget.controller.formatText(
                widget.controller.selection.start,
                0,
                Attribute.blockQuote,
              );
              break;
            case 'Code':
              widget.controller.formatText(
                widget.controller.selection.start,
                widget.controller.selection.end - widget.controller.selection.start,
                Attribute.codeBlock,
              );
              break;
          }
        },
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
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