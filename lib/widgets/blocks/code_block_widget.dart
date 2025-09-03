import 'package:flutter/material.dart';
import '../../models/block.dart';

class CodeBlockWidget extends StatelessWidget {
  final PageBlock block;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String)? onLanguageChanged;
  final bool readOnly;

  const CodeBlockWidget({
    super.key,
    required this.block,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.onLanguageChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final code = block.content['code'] as String? ?? '';
    final language = block.content['language'] as String? ?? 'text';
    
    if (controller.text != code) {
      controller.text = code;
      controller.selection = TextSelection.collapsed(offset: code.length);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Language selector header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                if (readOnly)
                  Text(
                    language,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: language,
                      isDense: true,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      items: _getLanguageOptions(),
                      onChanged: onLanguageChanged != null
                          ? (value) => onLanguageChanged!(value ?? 'text')
                          : null,
                    ),
                  ),
                const Spacer(),
                if (!readOnly)
                  IconButton(
                    icon: Icon(Icons.content_copy, size: 16, color: Colors.grey[600]),
                    onPressed: () => _copyToClipboard(context, code),
                    tooltip: 'Copy code',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          
          // Code editor
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              readOnly: readOnly,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your code here...',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.6),
                  fontSize: 14,
                  fontFamily: 'monospace',
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

  List<DropdownMenuItem<String>> _getLanguageOptions() {
    const languages = [
      'text',
      'javascript',
      'typescript',
      'python',
      'java',
      'dart',
      'html',
      'css',
      'json',
      'xml',
      'sql',
      'bash',
      'markdown',
      'yaml',
    ];

    return languages.map((lang) {
      return DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
    }).toList();
  }

  void _copyToClipboard(BuildContext context, String code) {
    // In a real implementation, you'd use Clipboard.setData
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}