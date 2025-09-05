import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notably/pages/auth_page.dart';
import 'package:notably/pages/main_layout.dart';
import 'package:notably/pages/settings_page.dart';
import 'package:notably/pages/note_editor_page.dart';
import 'models/note.dart';
import 'providers/theme_provider.dart';

const supabaseUrl = 'https://nxqlxybhwqocfcubngwa.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54cWx4eWJod3FvY2ZjdWJuZ3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwMTk4ODksImV4cCI6MjA3MDU5NTg4OX0.f1dMukTLUE6V8M9_EHp2LpkdylvoOBY1_qS4Aww2N-k';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(const ProviderScope(child: NotablyApp()));
}


class NotablyApp extends ConsumerWidget {
  const NotablyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Notably',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeMode,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const MainLayout(),
        '/settings': (context) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/editor') {
          final note = settings.arguments as Note?;
          return MaterialPageRoute(
            builder: (_) => NoteEditorPage(note: note),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
