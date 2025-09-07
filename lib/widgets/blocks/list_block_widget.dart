import 'package:flutter/material.dart';
import '../../models/block.dart';

class ListBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onEnterPressed;
  final bool readOnly;

  const ListBlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onEnterPressed,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content['text'] as String? ?? '';
    
    if (controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.collapsed(offset: text.length);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // List indicator
        Container(
          width: 24,
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _getListIndicator(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Text content
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: TextStyle(
                color: Colors.grey.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onSubmitted: (_) => onEnterPressed?.call(),
          ),
        ),
      ],
    );
  }

  String _getListIndicator() {
    switch (block.type) {
      case BlockType.bulletedList:
        return '•';
      case BlockType.numberedList:
        // In a real implementation, you'd track the numbering
        final number = (block.properties['number'] as int?) ?? 1;
        return '$number.';
      default:
        return '•';
    }
  }

  String _getHintText() {
    switch (block.type) {
      case BlockType.bulletedList:
        return 'List item';
      case BlockType.numberedList:
        return 'List item';
      default:
        return 'List item';
    }
  }
}