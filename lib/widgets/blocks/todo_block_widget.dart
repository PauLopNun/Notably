import 'package:flutter/material.dart';
import '../../models/block.dart';

class TodoBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(bool) onCheckedChanged;
  final VoidCallback? onEnterPressed;
  final bool readOnly;

  const TodoBlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCheckedChanged,
    this.onEnterPressed,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content['text'] as String? ?? '';
    final checked = block.content['checked'] as bool? ?? false;
    
    if (controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.collapsed(offset: text.length);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        Container(
          width: 24,
          padding: const EdgeInsets.only(top: 2),
          child: Checkbox(
            value: checked,
            onChanged: readOnly ? null : (value) => onCheckedChanged(value ?? false),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Text content
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked ? Colors.grey : null,
            ),
            decoration: InputDecoration(
              hintText: 'To-do item',
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
}