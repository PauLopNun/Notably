import 'package:flutter/material.dart';
import '../../models/block.dart';

class HeadingBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onEnterPressed;
  final bool readOnly;

  const HeadingBlockWidget({
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

    final textStyle = _getTextStyleForHeading();
    final hintText = _getHintTextForHeading();

    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      onChanged: onChanged,
      style: textStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textStyle.copyWith(
          color: Colors.grey.withOpacity(0.6),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      maxLines: null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onEnterPressed?.call(),
    );
  }

  TextStyle _getTextStyleForHeading() {
    switch (block.type) {
      case BlockType.heading1:
        return const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        );
      case BlockType.heading2:
        return const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        );
      case BlockType.heading3:
        return const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );
      default:
        return const TextStyle(fontSize: 16);
    }
  }

  String _getHintTextForHeading() {
    switch (block.type) {
      case BlockType.heading1:
        return 'Heading 1';
      case BlockType.heading2:
        return 'Heading 2';
      case BlockType.heading3:
        return 'Heading 3';
      default:
        return 'Heading';
    }
  }
}