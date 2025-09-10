import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/block.dart';
import 'text_block_widget.dart';
import 'heading_block_widget.dart';
import 'list_block_widget.dart';
import 'todo_block_widget.dart';
import 'quote_block_widget.dart';
import 'code_block_widget.dart';
import 'divider_block_widget.dart';
import 'callout_block_widget.dart';
import 'image_block_widget.dart';
import 'table_block_widget.dart';

class BlockWidgetFactory {
  static Widget create({
    required PageBlock block,
    FocusNode? focusNode,
    TextEditingController? textController,
    bool isReadOnly = false,
    bool isSelected = false,
    Function(String)? onTextChanged,
    Function(BlockType)? onTypeChanged,
    VoidCallback? onDelete,
    Function(Offset)? onSlashCommand,
    Function(bool)? onFocusChanged,
  }) {
    switch (block.type) {
      case BlockType.paragraph:
        return TextBlockWidget(
          block: block,
          focusNode: focusNode,
          textController: textController,
          isReadOnly: isReadOnly,
          onTextChanged: onTextChanged,
        );

      case BlockType.heading1:
      case BlockType.heading2:
      case BlockType.heading3:
        return HeadingBlockWidget(
          block: block,
          focusNode: focusNode,
          textController: textController,
          isReadOnly: isReadOnly,
          isSelected: isSelected,
          onTextChanged: onTextChanged,
          onTypeChanged: onTypeChanged,
          onDelete: onDelete,
          onSlashCommand: onSlashCommand,
          onFocusChanged: onFocusChanged,
        );

      case BlockType.bulletedList:
      case BlockType.numberedList:
        if (textController == null || focusNode == null || onTextChanged == null) {
          return const SizedBox();
        }
        return ListBlockWidget(
          block: block,
          controller: textController,
          focusNode: focusNode,
          onChanged: onTextChanged,
          readOnly: isReadOnly,
        );

      case BlockType.todo:
        if (textController == null || focusNode == null || onTextChanged == null) {
          return const SizedBox();
        }
        return TodoBlockWidget(
          block: block,
          controller: textController,
          focusNode: focusNode,
          onChanged: onTextChanged,
          onCheckedChanged: (checked) => {}, // TODO: implement properly
          readOnly: isReadOnly,
        );

      case BlockType.quote:
        if (textController == null || focusNode == null || onTextChanged == null) {
          return const SizedBox();
        }
        return QuoteBlockWidget(
          block: block,
          controller: textController,
          focusNode: focusNode,
          onChanged: onTextChanged,
          readOnly: isReadOnly,
        );

      case BlockType.code:
        return CodeBlockWidget(
          block: block,
          focusNode: focusNode,
          textController: textController,
          isReadOnly: isReadOnly,
          isSelected: isSelected,
          onTextChanged: onTextChanged,
          onTypeChanged: onTypeChanged,
          onDelete: onDelete,
          onSlashCommand: onSlashCommand,
          onFocusChanged: onFocusChanged,
        );

      case BlockType.divider:
        return const DividerBlockWidget();

      case BlockType.callout:
        return CalloutBlockWidget(
          block: block,
          focusNode: focusNode,
          textController: textController,
          isReadOnly: isReadOnly,
          isSelected: isSelected,
          onTextChanged: onTextChanged,
          onTypeChanged: onTypeChanged,
          onDelete: onDelete,
          onSlashCommand: onSlashCommand,
          onFocusChanged: onFocusChanged,
        );

      case BlockType.image:
        return ImageBlockWidget(
          block: block,
          isSelected: isSelected,
          onDelete: onDelete,
        );

      case BlockType.table:
        return TableBlockWidget(
          block: block,
          isSelected: isSelected,
          onDelete: onDelete,
        );

      // Default cases for not yet implemented blocks
      case BlockType.video:
      case BlockType.file:
      case BlockType.embed:
      case BlockType.database:
        return _buildPlaceholderWidget(block, isSelected, onDelete);
    }
  }

  static Widget _buildPlaceholderWidget(
    PageBlock block,
    bool isSelected,
    VoidCallback? onDelete,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.withAlpha(80),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withAlpha(40),
      ),
      child: Row(
        children: [
          Text(
            block.type.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${block.type.displayName} (Próximamente)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Este tipo de bloque estará disponible en una futura actualización.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null && isSelected)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Eliminar bloque',
            ),
        ],
      ),
    );
  }
}

// Base widget class for all blocks
abstract class BaseBlockWidget extends StatefulWidget {
  final PageBlock block;
  final bool isReadOnly;
  final bool isSelected;
  final Function(String)? onTextChanged;
  final Function(BlockType)? onTypeChanged;
  final VoidCallback? onDelete;
  final Function(Offset)? onSlashCommand;
  final Function(bool)? onFocusChanged;

  const BaseBlockWidget({
    super.key,
    required this.block,
    this.isReadOnly = false,
    this.isSelected = false,
    this.onTextChanged,
    this.onTypeChanged,
    this.onDelete,
    this.onSlashCommand,
    this.onFocusChanged,
  });
}

// Mixin for text-based blocks
mixin TextBlockMixin<T extends BaseBlockWidget> on State<T> {
  late TextEditingController textController;
  late FocusNode focusNode;

  void initializeTextBlock(TextEditingController? controller, FocusNode? node) {
    textController = controller ?? TextEditingController();
    focusNode = node ?? FocusNode();
    
    final text = widget.block.content;
    textController.text = text;
    
    textController.addListener(_onTextChanged);
    focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    widget.onTextChanged?.call(textController.text);
  }

  void _onFocusChanged() {
    widget.onFocusChanged?.call(focusNode.hasFocus);
  }

  void handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Handle slash commands
      if (event.logicalKey == LogicalKeyboardKey.slash) {
        if (textController.text.isEmpty || 
            textController.text.endsWith(' ')) {
          // Show slash menu at cursor position
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final position = renderBox.localToGlobal(Offset.zero);
            widget.onSlashCommand?.call(position);
          }
        }
      }
      
      // Handle backspace on empty blocks
      if (event.logicalKey == LogicalKeyboardKey.backspace && 
          textController.text.isEmpty) {
        widget.onDelete?.call();
      }
    }
  }

  Widget buildTextField({
    TextStyle? style,
    String? placeholder,
    int? maxLines,
  }) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      readOnly: widget.isReadOnly,
      style: style,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: placeholder ?? 'Escribe algo...',
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
      onSubmitted: (_) => _handleEnterKey(),
    );
  }

  void _handleEnterKey() {
    // Create new block on Enter
    // This would be handled by the parent widget
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }
}