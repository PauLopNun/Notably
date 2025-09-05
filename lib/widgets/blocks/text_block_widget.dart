import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/block.dart';
import 'block_widget_factory.dart';

class TextBlockWidget extends BaseBlockWidget {
  final FocusNode? focusNode;
  final TextEditingController? textController;

  const TextBlockWidget({
    super.key,
    required super.block,
    this.focusNode,
    this.textController,
    super.isReadOnly,
    super.isSelected,
    super.onTextChanged,
    super.onTypeChanged,
    super.onDelete,
    super.onSlashCommand,
    super.onFocusChanged,
  });

  @override
  State<TextBlockWidget> createState() => _TextBlockWidgetState();
}

class _TextBlockWidgetState extends State<TextBlockWidget> with TextBlockMixin {
  @override
  void initState() {
    super.initState();
    initializeTextBlock(widget.textController, widget.focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: widget.isSelected ? BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ) : null,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: handleKeyPress,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Block type indicator
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 4, right: 8),
                child: Center(
                  child: Text(
                    widget.block.type.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              // Text field
              Expanded(
                child: buildTextField(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  placeholder: 'Escribe algo...',
                ),
              ),
              
              // Actions
              if (widget.isSelected && !widget.isReadOnly)
                _buildBlockActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Type change button
        PopupMenuButton<BlockType>(
          icon: Icon(
            Icons.more_vert,
            size: 16,
            color: Theme.of(context).colorScheme.outline,
          ),
          itemBuilder: (context) => BlockType.values
              .where((type) => type.isTextBlock || type.isListBlock)
              .map((type) => PopupMenuItem<BlockType>(
                    value: type,
                    child: Row(
                      children: [
                        Text(type.icon),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  ))
              .toList(),
          onSelected: (type) => widget.onTypeChanged?.call(type),
        ),
        
        // Delete button
        IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 16,
            color: Colors.red.withValues(alpha: 0.8),
          ),
          onPressed: widget.onDelete,
          tooltip: 'Eliminar bloque',
        ),
      ],
    );
  }
}

class BackspaceFormatter extends TextInputFormatter {
  final VoidCallback onBackspace;

  BackspaceFormatter(this.onBackspace);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.isNotEmpty && newValue.text.isEmpty) {
      onBackspace();
    }
    return newValue;
  }
}