import 'package:flutter/material.dart';
import '../../models/block.dart';

class QuoteBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onEnterPressed;
  final bool readOnly;

  const QuoteBlockWidget({
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

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 4,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          fontStyle: FontStyle.italic,
          color: Colors.grey[700],
        ),
        decoration: InputDecoration(
          hintText: 'Quote',
          hintStyle: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onSubmitted: (_) => onEnterPressed?.call(),
      ),
    );
  }
}