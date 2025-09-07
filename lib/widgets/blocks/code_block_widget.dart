import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'block_widget_factory.dart';

class CodeBlockWidget extends BaseBlockWidget {
  final FocusNode? focusNode;
  final TextEditingController? textController;

  const CodeBlockWidget({
    super.key,
    required super.block,
    this.focusNode,
    this.textController,
    super.isReadOnly = false,
    super.isSelected = false,
    super.onTextChanged,
    super.onTypeChanged,
    super.onDelete,
    super.onSlashCommand,
    super.onFocusChanged,
  });

  @override
  State<CodeBlockWidget> createState() => _CodeBlockWidgetState();
}

class _CodeBlockWidgetState extends State<CodeBlockWidget> with TextBlockMixin {
  String _selectedLanguage = 'plain';
  final List<String> _languages = [
    'plain', 'dart', 'javascript', 'python', 'java', 'cpp', 'c', 'html', 'css', 'json', 'xml', 'sql', 'bash'
  ];

  @override
  void initState() {
    super.initState();
    initializeTextBlock(widget.textController, widget.focusNode);
    _selectedLanguage = widget.block.content['language']?.toString() ?? 'plain';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: widget.isSelected ? Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ) : Border.all(
          color: theme.colorScheme.outline.withAlpha(60),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Code header with language selector and actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withAlpha(100),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.code_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                
                // Language Selector
                if (!widget.isReadOnly) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.colorScheme.outline.withAlpha(100),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
                        isDense: true,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        items: _languages.map((language) {
                          return DropdownMenuItem(
                            value: language,
                            child: Text(language.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: _onLanguageChanged,
                      ),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _selectedLanguage.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Copy Button
                IconButton(
                  icon: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _copyCode,
                  tooltip: 'Copiar código',
                  visualDensity: VisualDensity.compact,
                ),
                
                // Delete Button
                if (widget.isSelected && !widget.isReadOnly)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
                    onPressed: widget.onDelete,
                    tooltip: 'Eliminar bloque de código',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
          
          // Code content with syntax highlighting simulation
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(20),
            child: _buildCodeEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeEditor() {
    final theme = Theme.of(context);
    return TextField(
      controller: textController,
      focusNode: focusNode,
      readOnly: widget.isReadOnly,
      maxLines: null,
      expands: false,
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 14,
        color: _getCodeColor(),
        height: 1.6,
        letterSpacing: 0.5,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: _getPlaceholderText(),
        hintStyle: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
          fontStyle: FontStyle.italic,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      cursorColor: theme.colorScheme.primary,
      cursorWidth: 2,
      onChanged: widget.onTextChanged,
    );
  }

  String _getPlaceholderText() {
    switch (_selectedLanguage) {
      case 'dart':
        return 'void main() {\n  print("Hello, Dart!");\n}';
      case 'javascript':
        return 'console.log("Hello, World!");';
      case 'python':
        return 'print("Hello, Python!")';
      case 'java':
        return 'public class Main {\n  public static void main(String[] args) {\n    System.out.println("Hello, Java!");\n  }\n}';
      case 'html':
        return '<h1>Hello, HTML!</h1>';
      case 'css':
        return '.container {\n  display: flex;\n  justify-content: center;\n}';
      case 'json':
        return '{\n  "message": "Hello, JSON!"\n}';
      case 'sql':
        return 'SELECT * FROM users WHERE active = true;';
      case 'bash':
        return '#!/bin/bash\necho "Hello, Bash!"';
      default:
        return 'Escribe tu código aquí...';
    }
  }

  Color _getCodeColor() {
    final theme = Theme.of(context);
    switch (_selectedLanguage) {
      case 'dart':
        return const Color(0xFF0175C2);
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      case 'html':
        return const Color(0xFFE34F26);
      case 'css':
        return const Color(0xFF1572B6);
      default:
        return theme.colorScheme.onSurface;
    }
  }

  void _onLanguageChanged(String? newLanguage) {
    if (newLanguage != null) {
      setState(() {
        _selectedLanguage = newLanguage;
      });
      // Notify parent of content change
      _notifyContentChanged();
    }
  }

  void _copyCode() {
    final code = textController.text;
    if (code.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado al portapapeles'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _notifyContentChanged() {
    final content = {
      'code': textController.text,
      'language': _selectedLanguage,
    };
    widget.onTextChanged?.call(content.toString());
  }
}