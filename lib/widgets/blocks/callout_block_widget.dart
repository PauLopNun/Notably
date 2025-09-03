import 'package:flutter/material.dart';
import '../../models/block.dart';

class CalloutBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String)? onIconChanged;
  final bool readOnly;

  const CalloutBlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onIconChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = block.content['text'] as String? ?? '';
    final icon = block.content['icon'] as String? ?? '💡';
    final backgroundColor = block.content['backgroundColor'] as String? ?? 'blue';
    
    if (controller.text != text) {
      controller.text = text;
      controller.selection = TextSelection.collapsed(offset: text.length);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(backgroundColor),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(backgroundColor),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          if (readOnly)
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            )
          else
            GestureDetector(
              onTap: () => _showIconPicker(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white.withOpacity(0.7),
                ),
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          
          const SizedBox(width: 12),
          
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
                hintText: 'Type your callout...',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.5),
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String backgroundColor) {
    switch (backgroundColor) {
      case 'blue':
        return Colors.blue[50]!;
      case 'green':
        return Colors.green[50]!;
      case 'yellow':
        return Colors.yellow[50]!;
      case 'red':
        return Colors.red[50]!;
      case 'purple':
        return Colors.purple[50]!;
      case 'orange':
        return Colors.orange[50]!;
      default:
        return Colors.blue[50]!;
    }
  }

  Color _getBorderColor(String backgroundColor) {
    switch (backgroundColor) {
      case 'blue':
        return Colors.blue[200]!;
      case 'green':
        return Colors.green[200]!;
      case 'yellow':
        return Colors.yellow[200]!;
      case 'red':
        return Colors.red[200]!;
      case 'purple':
        return Colors.purple[200]!;
      case 'orange':
        return Colors.orange[200]!;
      default:
        return Colors.blue[200]!;
    }
  }

  void _showIconPicker(BuildContext context) {
    const icons = [
      '💡', '📝', '⚠️', '✅', '❌', '🔥', '⭐', '📌',
      '🎯', '💭', '📊', '🔔', '📚', '🎨', '🔧', '💻',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose an icon'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: icons.map((emoji) {
            return GestureDetector(
              onTap: () {
                onIconChanged?.call(emoji);
                Navigator.pop(context);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}