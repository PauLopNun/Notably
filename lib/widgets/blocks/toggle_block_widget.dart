import 'package:flutter/material.dart';
import '../../models/block.dart';

class ToggleBlockWidget extends StatefulWidget {
  final PageBlock block;
  final FocusNode? focusNode;
  final TextEditingController? textController;
  final bool isReadOnly;
  final bool isSelected;
  final Function(String)? onTextChanged;
  final Function(BlockType)? onTypeChanged;
  final VoidCallback? onDelete;
  final Function(Offset)? onSlashCommand;
  final Function(bool)? onFocusChanged;

  const ToggleBlockWidget({
    super.key,
    required this.block,
    this.focusNode,
    this.textController,
    this.isReadOnly = false,
    this.isSelected = false,
    this.onTextChanged,
    this.onTypeChanged,
    this.onDelete,
    this.onSlashCommand,
    this.onFocusChanged,
  });

  @override
  State<ToggleBlockWidget> createState() => _ToggleBlockWidgetState();
}

class _ToggleBlockWidgetState extends State<ToggleBlockWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Since content is a String, we'll default to collapsed
    _isExpanded = false;
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.block.content;
    String text = content.isNotEmpty ? content : 'Toggle';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle header
        Row(
          children: [
            // Toggle icon
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Icon(
                _isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),

            // Text field
            Expanded(
              child: TextField(
                controller: widget.textController?..text = text,
                focusNode: widget.focusNode,
                readOnly: widget.isReadOnly,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Toggle',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                ),
                onChanged: widget.onTextChanged,
                onTap: () => widget.onFocusChanged?.call(true),
              ),
            ),
          ],
        ),

        // Expanded content
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Text(
                'Contenido del toggle aquí...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
      ],
    );
  }
}