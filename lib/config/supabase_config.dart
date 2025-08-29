class SupabaseConfig {
  // Credenciales de Supabase (ya configuradas en main.dart)
  static const String supabaseUrl = 'https://nxqlxybhwqocfcubngwa.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54cWx4eWJod3FvY2ZjdWJuZ3dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwMTk4ODksImV4cCI6MjA3MDU5NTg4OX0.f1dMukTLUE6V8M9_EHp2LpkdylvoOBY1_qS4Aww2N-k';
  
  // Configuración de la base de datos
  static const String notesTable = 'notes';
  
  // Configuración de autenticación
  static const bool enableEmailAuth = true;
  static const bool enableGoogleAuth = false;
  static const bool enableGithubAuth = false;
}
