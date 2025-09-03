import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(_labelForMode(mode)),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Sistema'),
            value: ThemeMode.system,
            groupValue: mode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: mode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setMode(v);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Oscuro'),
            value: ThemeMode.dark,
            groupValue: mode,
            onChanged: (v) {
              if (v != null) ref.read(themeModeProvider.notifier).setMode(v);
            },
          ),
        ],
      ),
    );
  }

  String _labelForMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Oscuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }
}


