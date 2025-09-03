import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/block.dart';

class TextBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final VoidCallback? onEnterPressed;
  final VoidCallback? onBackspacePressed;
  final bool readOnly;

  const TextBlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onEnterPressed,
    this.onBackspacePressed,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content['text'] as String? ?? '';
    
    if (controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.collapsed(offset: text.length);
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Type something...',
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.6),
          fontSize: 16,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      onSubmitted: (_) => onEnterPressed?.call(),
      inputFormatters: [
        if (onBackspacePressed != null)
          BackspaceFormatter(onBackspacePressed!),
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