import 'package:flutter/material.dart';
import 'block_widget_factory.dart';

class TableBlockWidget extends BaseBlockWidget {
  const TableBlockWidget({
    super.key,
    required super.block,
    super.isReadOnly = false,
    super.isSelected = false,
    super.onDelete,
  });

  @override
  State<TableBlockWidget> createState() => _TableBlockWidgetState();
}

class _TableBlockWidgetState extends State<TableBlockWidget> {
  late Map<String, dynamic> _tableData;
  
  @override
  void initState() {
    super.initState();
    _initializeTableData();
  }

  void _initializeTableData() {
    final content = widget.block.content as Map<String, dynamic>? ?? {};
    _tableData = {
      'rows': content['rows'] ?? [
        ['Header 1', 'Header 2', 'Header 3'],
        ['Row 1, Col 1', 'Row 1, Col 2', 'Row 1, Col 3'],
        ['Row 2, Col 1', 'Row 2, Col 2', 'Row 2, Col 3'],
      ],
      'columnCount': (content['columnCount'] as num?)?.toInt() ?? 3,
      'rowCount': (content['rowCount'] as num?)?.toInt() ?? 3,
      'headerRow': content['headerRow'] as bool? ?? true,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasHeader = _tableData['headerRow'] as bool;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: widget.isSelected ? Border.all(
          color: theme.colorScheme.primary,
          width: 2,
        ) : Border.all(color: theme.colorScheme.outline.withAlpha(80)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Controls
          if (!widget.isReadOnly) _buildTableControls(),
          
          // Table Content
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: hasHeader ? 56 : 0,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 48,
              columnSpacing: 16,
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              dataTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              border: TableBorder.all(
                color: theme.colorScheme.outline.withAlpha(60),
                width: 1,
                borderRadius: BorderRadius.circular(4),
              ),
              columns: _buildColumns(),
              rows: _buildRows(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(80),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_box, size: 18),
            onPressed: _addRow,
            tooltip: 'Agregar fila',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 18),
            onPressed: _removeRow,
            tooltip: 'Eliminar fila',
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.view_column, size: 18),
            onPressed: _addColumn,
            tooltip: 'Agregar columna',
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: _removeColumn,
            tooltip: 'Eliminar columna',
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          if (widget.isSelected && widget.onDelete != null)
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
              onPressed: widget.onDelete,
              tooltip: 'Eliminar tabla',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final rows = List<List<String>>.from(_tableData['rows']);
    if (rows.isEmpty) return [];
    
    final columnCount = rows.first.length;
    return List.generate(columnCount, (index) {
      return DataColumn(
        label: Expanded(
          child: Text('Column ${index + 1}'),
        ),
      );
    });
  }

  List<DataRow> _buildRows() {
    final rows = List<List<String>>.from(_tableData['rows']);
    final hasHeader = _tableData['headerRow'] as bool;
    final startIndex = hasHeader ? 1 : 0;
    
    return List.generate(
      rows.length - startIndex,
      (index) {
        final actualIndex = index + startIndex;
        final rowData = rows[actualIndex];
        
        return DataRow(
          cells: List.generate(
            rowData.length,
            (cellIndex) => DataCell(
              widget.isReadOnly
                  ? Text(rowData[cellIndex])
                  : _buildEditableCell(actualIndex, cellIndex, rowData[cellIndex]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditableCell(int rowIndex, int cellIndex, String value) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
        onChanged: (newValue) => _updateCell(rowIndex, cellIndex, newValue),
        maxLines: 1,
      ),
    );
  }

  void _updateCell(int rowIndex, int cellIndex, String value) {
    setState(() {
      final rows = List<List<String>>.from(_tableData['rows']);
      if (rowIndex < rows.length && cellIndex < rows[rowIndex].length) {
        rows[rowIndex][cellIndex] = value;
        _tableData['rows'] = rows;
      }
    });
    _notifyContentChanged();
  }

  void _addRow() {
    setState(() {
      final rows = List<List<String>>.from(_tableData['rows']);
      final columnCount = rows.isNotEmpty ? rows.first.length : 3;
      rows.add(List.generate(columnCount, (index) => 'New Cell'));
      _tableData['rows'] = rows;
      _tableData['rowCount'] = rows.length;
    });
    _notifyContentChanged();
  }

  void _removeRow() {
    setState(() {
      final rows = List<List<String>>.from(_tableData['rows']);
      if (rows.length > 1) {
        rows.removeLast();
        _tableData['rows'] = rows;
        _tableData['rowCount'] = rows.length;
      }
    });
    _notifyContentChanged();
  }

  void _addColumn() {
    setState(() {
      final rows = List<List<String>>.from(_tableData['rows']);
      for (var row in rows) {
        row.add('New Cell');
      }
      _tableData['rows'] = rows;
      _tableData['columnCount'] = rows.isNotEmpty ? rows.first.length : 0;
    });
    _notifyContentChanged();
  }

  void _removeColumn() {
    setState(() {
      final rows = List<List<String>>.from(_tableData['rows']);
      if (rows.isNotEmpty && rows.first.length > 1) {
        for (var row in rows) {
          if (row.isNotEmpty) {
            row.removeLast();
          }
        }
        _tableData['rows'] = rows;
        _tableData['columnCount'] = rows.isNotEmpty ? rows.first.length : 0;
      }
    });
    _notifyContentChanged();
  }

  void _notifyContentChanged() {
    widget.onTextChanged?.call(_tableData.toString());
  }
}