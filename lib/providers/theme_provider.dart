import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  system,
  light,
  dark,
}

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeNotifier() : super(AppThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey) ?? 'system';
      
      final themeMode = AppThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeString,
        orElse: () => AppThemeMode.system,
      );
      
      state = themeMode;
    } catch (e) {
      // Keep default system theme if loading fails
      state = AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.name);
      state = themeMode;
    } catch (e) {
      // Handle error but don't crash
      debugPrint('Failed to save theme preference: $e');
    }
  }

  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

// Providers
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>(
  (ref) => ThemeNotifier(),
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeNotifier = ref.watch(themeNotifierProvider.notifier);
  return themeNotifier.themeMode;
});

// Custom color schemes for different themes
class AppColorSchemes {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF6366F1),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF1E1B16),
    secondary: Color(0xFF8B5CF6),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFEDE9FE),
    onSecondaryContainer: Color(0xFF1C1B1F),
    tertiary: Color(0xFF10B981),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD1FAE5),
    onTertiaryContainer: Color(0xFF002110),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF410002),
    outline: Color(0xFF79747E),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFFC0C6DC),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF6366F1),
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF818CF8),
    onPrimary: Color(0xFF1E1B16),
    primaryContainer: Color(0xFF4338CA),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: Color(0xFFA78BFA),
    onSecondary: Color(0xFF1C1B1F),
    secondaryContainer: Color(0xFF6D28D9),
    onSecondaryContainer: Color(0xFFEDE9FE),
    tertiary: Color(0xFF34D399),
    onTertiary: Color(0xFF002110),
    tertiaryContainer: Color(0xFF047857),
    onTertiaryContainer: Color(0xFFD1FAE5),
    error: Color(0xFFF87171),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: Color(0xFF938F99),
    surface: Color(0xFF0F172A),
    onSurface: Color(0xFFE4E1E6),
    surfaceContainerHighest: Color(0xFF1E293B),
    onSurfaceVariant: Color(0xFFCAC4D0),
    inverseSurface: Color(0xFFE4E1E6),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF6366F1),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0xFF818CF8),
  );

  // Additional surface colors for better hierarchy
  static Color lightSurfaceContainer = const Color(0xFFF3F4F6);
  static Color lightSurfaceContainerHigh = const Color(0xFFE5E7EB);
  static Color lightSurfaceContainerHighest = const Color(0xFFD1D5DB);

  static Color darkSurfaceContainer = const Color(0xFF1E293B);
  static Color darkSurfaceContainerHigh = const Color(0xFF334155);
  static Color darkSurfaceContainerHighest = const Color(0xFF475569);
}

// Theme data configurations
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.lightColorScheme,
    fontFamily: 'Inter',
    
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFFFFFBFE),
      foregroundColor: Color(0xFF1C1B1F),
      titleTextStyle: TextStyle(
        color: Color(0xFF1C1B1F),
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 1,
      color: AppColorSchemes.lightColorScheme.surface,
      surfaceTintColor: AppColorSchemes.lightColorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorSchemes.lightSurfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.lightColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.lightColorScheme.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.lightColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.lightColorScheme.error),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 3,
      shape: CircleBorder(),
    ),

    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorSchemes.lightSurfaceContainer,
      indicatorColor: AppColorSchemes.lightColorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Drawer theme
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      surfaceTintColor: AppColorSchemes.lightColorScheme.surfaceTint,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      surfaceTintColor: AppColorSchemes.lightColorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorSchemes.lightColorScheme.surface,
      surfaceTintColor: AppColorSchemes.lightColorScheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorSchemes.darkColorScheme,
    fontFamily: 'Inter',
    
    // AppBar theme
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Color(0xFFE4E1E6),
      titleTextStyle: TextStyle(
        color: Color(0xFFE4E1E6),
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColorSchemes.darkColorScheme.surface,
      surfaceTintColor: AppColorSchemes.darkColorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorSchemes.darkSurfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.darkColorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.darkColorScheme.outline.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.darkColorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColorSchemes.darkColorScheme.error),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // Floating action button theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Navigation bar theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColorSchemes.darkSurfaceContainer,
      indicatorColor: AppColorSchemes.darkColorScheme.primaryContainer,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),

    // Drawer theme
    drawerTheme: DrawerThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      surfaceTintColor: AppColorSchemes.darkColorScheme.surfaceTint,
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      surfaceTintColor: AppColorSchemes.darkColorScheme.surfaceTint,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColorSchemes.darkColorScheme.surface,
      surfaceTintColor: AppColorSchemes.darkColorScheme.surfaceTint,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
  );
}

// Extension for additional surface colors
extension ColorSchemeExtension on ColorScheme {
  Color get surfaceContainer {
    return brightness == Brightness.light
        ? AppColorSchemes.lightSurfaceContainer
        : AppColorSchemes.darkSurfaceContainer;
  }

  Color get surfaceContainerHigh {
    return brightness == Brightness.light
        ? AppColorSchemes.lightSurfaceContainerHigh
        : AppColorSchemes.darkSurfaceContainerHigh;
  }

  Color get surfaceContainerHighest {
    return brightness == Brightness.light
        ? AppColorSchemes.lightSurfaceContainerHighest
        : AppColorSchemes.darkSurfaceContainerHighest;
  }
}