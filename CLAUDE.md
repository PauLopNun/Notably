# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Install dependencies**: `flutter pub get`
- **Run application**: `flutter run` (auto-detects platform: Windows/macOS/Linux/Web/Mobile)
- **Run tests**: `flutter test`
- **Build for web**: `flutter build web`
- **Build for Android**: `flutter build apk` or `flutter build appbundle`
- **Build for Windows**: `flutter build windows`
- **Build for macOS**: `flutter build macos`
- **Build for Linux**: `flutter build linux`
- **Clean build**: `flutter clean && flutter pub get`

## Architecture Overview

Notably is a Flutter notes application using:

### Core Stack
- **Flutter/Dart**: Cross-platform UI framework
- **Supabase**: Backend-as-a-Service (authentication, database, real-time)
- **Riverpod**: State management with providers
- **Flutter Quill**: Rich text editing for note content
- **Material Design 3**: UI design system

### State Management Pattern
The app uses Riverpod providers for state management:
- `noteServiceProvider`: Provides NoteService instance
- `notesProvider`: StateNotifierProvider managing note list state
- `themeModeProvider`: StateNotifierProvider for theme switching

State flows through NotesNotifier which coordinates with NoteService for CRUD operations.

### Authentication & Data Flow
1. Users authenticate via Supabase Auth (email/password)
2. All data operations require authenticated user
3. Notes are user-scoped with RLS policies
4. Real-time sync through Supabase subscriptions

### Database Schema
Notes table structure:
- `id` (UUID, primary key)
- `user_id` (UUID, references auth.users)
- `title` (TEXT)
- `content` (JSONB, stores Quill delta format)
- `created_at`, `updated_at` (timestamps)

RLS policies ensure users only access their own notes.

### Key Architectural Patterns
- **Repository Pattern**: NoteService abstracts Supabase operations
- **Provider Pattern**: Riverpod providers for dependency injection
- **Navigation**: Named routes with parameter passing for note editing
- **Error Handling**: Try-catch with user-friendly error messages
- **Theme Management**: Persistent theme switching via SharedPreferences

### Important File Locations
- Entry point: `lib/main.dart` (includes Supabase credentials)
- Configuration: `lib/config/supabase_config.dart`
- Models: `lib/models/note.dart`
- Services: `lib/services/note_service.dart`
- State management: `lib/providers/note_provider.dart`
- Pages: `lib/pages/` (auth, home, editor, settings)
- Reusable components: `lib/widgets/`
- Theming: `lib/theme/app_theme.dart`

### Setup Requirements
Before development, ensure:
1. Supabase project created with notes table and RLS policies (see SETUP.md)
2. Credentials configured in `lib/main.dart` and `lib/config/supabase_config.dart`
3. Email authentication enabled in Supabase dashboard

### Development Notes
- Rich text content stored as JSON (Quill delta format)
- All note operations are user-scoped and authenticated
- Theme mode persisted using SharedPreferences
- Cross-platform compatibility (Web, Android, iOS)