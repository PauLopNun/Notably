import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/sidebar.dart';
import '../widgets/note_list.dart';
import '../widgets/note_editor.dart';
import '../models/note.dart';
import '../theme/app_theme.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  bool _isSidebarOpen = true;
  Note? _selectedNote;
  bool _isEditorOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          // Sidebar deslizable
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarOpen ? 280 : 70,
            child: Sidebar(
              isCollapsed: !_isSidebarOpen,
              onNoteSelected: (note) {
                setState(() {
                  _selectedNote = note;
                  _isEditorOpen = true;
                });
              },
              onCreateNote: () {
                setState(() {
                  _selectedNote = null;
                  _isEditorOpen = true;
                });
              },
            ),
          ),
          
          // Separador vertical
          Container(
            width: 1,
            color: AppTheme.dividerColor,
          ),
          
          // Área principal
          Expanded(
            child: Row(
              children: [
                // Lista de notas (solo visible cuando no hay editor abierto)
                if (!_isEditorOpen)
                  Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      border: Border(
                        right: BorderSide(
                          color: AppTheme.dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: NoteList(
                      onNoteSelected: (note) {
                        setState(() {
                          _selectedNote = note;
                          _isEditorOpen = true;
                        });
                      },
                    ),
                  ),
                
                // Editor de notas
                if (_isEditorOpen)
                  Expanded(
                    child: NoteEditor(
                      note: _selectedNote,
                      onClose: () {
                        setState(() {
                          _isEditorOpen = false;
                          _selectedNote = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      // Botón flotante para crear nota
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _selectedNote = null;
            _isEditorOpen = true;
          });
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva nota'),
      ),
      // Evitar solapamiento con BottomAppBar usando notch y endDocked
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSidebarOpen = !_isSidebarOpen;
                  });
                },
                icon: Icon(
                  _isSidebarOpen ? Icons.menu_open : Icons.menu,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                tooltip: 'Ajustes',
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
                icon: const Icon(Icons.settings),
              ),
              const Spacer(),
              if (_isEditorOpen)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditorOpen = false;
                      _selectedNote = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Cerrar editor'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
