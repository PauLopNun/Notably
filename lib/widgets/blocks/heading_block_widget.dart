import 'package:flutter/material.dart';
import '../../models/block.dart';
import 'block_widget_factory.dart';

class HeadingBlockWidget extends BaseBlockWidget {
  final FocusNode? focusNode;
  final TextEditingController? textController;

  const HeadingBlockWidget({
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
  State<HeadingBlockWidget> createState() => _HeadingBlockWidgetState();
}

class _HeadingBlockWidgetState extends State<HeadingBlockWidget> with TextBlockMixin {
  @override
  void initState() {
    super.initState();
    initializeTextBlock(widget.textController, widget.focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(top: 4, right: 12),
                child: Center(
                  child: Text(
                    widget.block.type.icon,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              // Text field
              Expanded(
                child: buildTextField(
                  style: _getTextStyleForHeading(context),
                  placeholder: _getHintTextForHeading(),
                  maxLines: null,
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

  TextStyle _getTextStyleForHeading(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface;
    
    switch (widget.block.type) {
      case BlockType.heading1:
        return TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
          color: baseColor,
        );
      case BlockType.heading2:
        return TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
          color: baseColor,
        );
      case BlockType.heading3:
        return TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
          color: baseColor,
        );
      default:
        return TextStyle(fontSize: 16, color: baseColor);
    }
  }

  String _getHintTextForHeading() {
    switch (widget.block.type) {
      case BlockType.heading1:
        return 'Encabezado 1';
      case BlockType.heading2:
        return 'Encabezado 2';
      case BlockType.heading3:
        return 'Encabezado 3';
      default:
        return 'Encabezado';
    }
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
          itemBuilder: (context) => [
            BlockType.heading1,
            BlockType.heading2,
            BlockType.heading3,
            BlockType.paragraph,
          ].map((type) => PopupMenuItem<BlockType>(
                value: type,
                child: Row(
                  children: [
                    Text(type.icon),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              )).toList(),
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