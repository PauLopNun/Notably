import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notably/pages/auth_page.dart';
import 'package:notably/pages/home_page.dart';
import 'package:notably/pages/settings_page.dart';
import 'package:notably/pages/note_editor_page.dart';
import 'package:notably/theme/notion_theme.dart';
import 'models/note.dart';
import 'providers/theme_provider.dart';
import 'services/database_setup_service.dart';
import 'package:flutter/services.dart';

const supabaseUrl = 'https://nxqlxybhwqocfcubngwa.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54cWx4eWJod3FvY2ZjdWJuZ3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwMTk4ODksImV4cCI6MjA3MDU5NTg4OX0.f1dMukTLUE6V8M9_EHp2LpkdylvoOBY1_qS4Aww2N-k';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  // Auto-setup database schema
  await DatabaseSetupService.ensureDatabaseSchema();
  
  runApp(const ProviderScope(child: NotablyApp()));
}


class NotablyApp extends ConsumerWidget {
  const NotablyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Notably',
      debugShowCheckedModeBanner: false,
      theme: NotionTheme.lightTheme,
      darkTheme: NotionTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthPage(),
        '/home': (context) => const HomePage(),
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
      builder: (context, child) {
        // Set system UI overlay style based on theme
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );

        return child!;
      },
    );
  }
}
