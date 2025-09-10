import 'package:flutter/material.dart';
import 'block_widget_factory.dart';

class CalloutBlockWidget extends BaseBlockWidget {
  final FocusNode? focusNode;
  final TextEditingController? textController;

  const CalloutBlockWidget({
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
  State<CalloutBlockWidget> createState() => _CalloutBlockWidgetState();
}

class _CalloutBlockWidgetState extends State<CalloutBlockWidget> with TextBlockMixin {
  String _selectedIcon = '💡';
  String _selectedStyle = 'info';
  
  final List<String> _calloutIcons = [
    '💡', '⚠️', '📝', '✅', '❌', '📌', '🔥', '⚡', '🎯', '🚀', '💪', '🎉', '📖', '🧠', '⭐'
  ];
  
  final Map<String, CalloutStyle> _calloutStyles = {
    'info': CalloutStyle(
      backgroundColor: const Color(0xFFE3F2FD),
      borderColor: const Color(0xFF2196F3),
      textColor: const Color(0xFF1565C0),
      name: 'Info',
    ),
    'success': CalloutStyle(
      backgroundColor: const Color(0xFFE8F5E8),
      borderColor: const Color(0xFF4CAF50),
      textColor: const Color(0xFF2E7D32),
      name: 'Success',
    ),
    'warning': CalloutStyle(
      backgroundColor: const Color(0xFFFFF3E0),
      borderColor: const Color(0xFFFF9800),
      textColor: const Color(0xFFE65100),
      name: 'Warning',
    ),
    'error': CalloutStyle(
      backgroundColor: const Color(0xFFFFEBEE),
      borderColor: const Color(0xFFF44336),
      textColor: const Color(0xFFC62828),
      name: 'Error',
    ),
    'neutral': CalloutStyle(
      backgroundColor: const Color(0xFFF5F5F5),
      borderColor: const Color(0xFF9E9E9E),
      textColor: const Color(0xFF424242),
      name: 'Neutral',
    ),
  };

  @override
  void initState() {
    super.initState();
    initializeTextBlock(widget.textController, widget.focusNode);
    _selectedIcon = widget.block.properties['icon']?.toString() ?? '💡';
    _selectedStyle = widget.block.properties['style']?.toString() ?? 'info';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _calloutStyles[_selectedStyle]!;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: widget.isSelected ? Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ) : Border.all(
          color: style.borderColor.withAlpha(120),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: style.backgroundColor,
      ),
      child: Column(
        children: [
          // Callout header with controls
          if (!widget.isReadOnly) _buildCalloutControls(style),
          
          // Callout content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12, top: 2),
                  decoration: BoxDecoration(
                    color: style.borderColor.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _selectedIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                
                // Text content
                Expanded(
                  child: _buildTextEditor(style),
                ),
                
                // Delete button
                if (widget.isSelected && !widget.isReadOnly)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: style.borderColor,
                    ),
                    onPressed: widget.onDelete,
                    tooltip: 'Eliminar callout',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalloutControls(CalloutStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: style.borderColor.withAlpha(40),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: Border(
          bottom: BorderSide(
            color: style.borderColor.withAlpha(120),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Icon Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedIcon,
                isDense: true,
                style: const TextStyle(fontSize: 16),
                items: _calloutIcons.map((icon) {
                  return DropdownMenuItem(
                    value: icon,
                    child: Text(icon),
                  );
                }).toList(),
                onChanged: _onIconChanged,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Style Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStyle,
                isDense: true,
                style: TextStyle(
                  color: style.textColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                items: _calloutStyles.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value.name),
                  );
                }).toList(),
                onChanged: _onStyleChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextEditor(CalloutStyle style) {
    return TextField(
      controller: textController,
      focusNode: focusNode,
      readOnly: widget.isReadOnly,
      maxLines: null,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: style.textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Escribe tu callout aquí...',
        hintStyle: TextStyle(
          color: style.textColor.withAlpha(150),
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: widget.onTextChanged,
    );
  }

  void _onIconChanged(String? newIcon) {
    if (newIcon != null) {
      setState(() {
        _selectedIcon = newIcon;
      });
      _notifyContentChanged();
    }
  }

  void _onStyleChanged(String? newStyle) {
    if (newStyle != null) {
      setState(() {
        _selectedStyle = newStyle;
      });
      _notifyContentChanged();
    }
  }

  void _notifyContentChanged() {
    final content = {
      'text': textController.text,
      'icon': _selectedIcon,
      'style': _selectedStyle,
    };
    widget.onTextChanged?.call(content.toString());
  }
}

class CalloutStyle {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final String name;

  const CalloutStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.name,
  });
}