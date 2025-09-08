import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NotionTheme {
  // Notion Color Palette
  static const Color _notionWhite = Color(0xFFFFFFFF);
  static const Color _notionBlack = Color(0xFF2F3437);
  static const Color _notionGray50 = Color(0xFFF7F6F3);
  static const Color _notionGray100 = Color(0xFFEBEAE6);
  static const Color _notionGray200 = Color(0xFFE3E2DE);
  static const Color _notionGray300 = Color(0xFFCFCDCA);
  static const Color _notionGray400 = Color(0xFFADABA8);
  static const Color _notionGray500 = Color(0xFF979593);
  static const Color _notionGray600 = Color(0xFF64625F);
  static const Color _notionGray700 = Color(0xFF37352F);
  static const Color _notionGray800 = Color(0xFF2F2E2A);
  static const Color _notionGray900 = Color(0xFF191919);

  // Notion Accent Colors
  static const Color _notionBlue = Color(0xFF2383E2);
  static const Color _notionRed = Color(0xFFE03E3E);
  static const Color _notionGreen = Color(0xFF0F7B0F);
  static const Color _notionYellow = Color(0xFFFFC639);
  static const Color _notionOrange = Color(0xFFFF9500);
  static const Color _notionPurple = Color(0xFF9065B0);
  static const Color _notionPink = Color(0xFFE255A1);
  static const Color _notionTeal = Color(0xFF0DB4C4);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.inter().fontFamily,
      
      // Color Scheme - Notion Style
      colorScheme: ColorScheme.fromSeed(
        seedColor: _notionBlue,
        brightness: Brightness.light,
        surface: _notionWhite,
        onSurface: _notionGray700,
        surfaceContainer: _notionGray50,
        surfaceContainerHighest: _notionGray100,
        onSurfaceVariant: _notionGray500,
        outline: _notionGray300,
        primary: _notionBlue,
        secondary: _notionGray600,
        tertiary: _notionPurple,
      ),

      // App Bar Theme - Clean Notion Style
      appBarTheme: AppBarTheme(
        backgroundColor: _notionWhite,
        foregroundColor: _notionGray700,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _notionGray200.withAlpha(100),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: _notionWhite,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card Theme - Notion Cards
      cardTheme: CardThemeData(
        color: _notionWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: _notionGray300.withAlpha(50),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _notionGray200,
            width: 0.5,
          ),
        ),
      ),

      // Elevated Button - Notion Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _notionBlue,
          foregroundColor: _notionWhite,
          shadowColor: _notionBlue.withAlpha(50),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _notionGray600,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _notionGray700,
          side: const BorderSide(color: _notionGray300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration - Notion Style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _notionGray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _notionGray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _notionGray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _notionBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _notionRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: GoogleFonts.inter(
          color: _notionGray400,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.inter(
          color: _notionGray500,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _notionGray700,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          fontSize: 12,
          color: _notionGray500,
        ),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: _notionWhite,
        surfaceTintColor: Colors.transparent,
        width: 280,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _notionWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _notionWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _notionGray600,
          height: 1.5,
        ),
      ),

      // Text Theme - Notion Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _notionGray700,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
          letterSpacing: -0.25,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _notionGray700,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _notionGray700,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _notionGray700,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _notionGray500,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _notionGray600,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _notionGray600,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: _notionGray500,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _notionGray200,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _notionGray100,
        selectedColor: _notionBlue.withAlpha(50),
        deleteIconColor: _notionGray500,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _notionGray700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: _notionGray600,
        size: 20,
      ),

      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: _notionBlue,
        size: 20,
      ),

      // Scrollbar Theme
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(_notionGray300),
        trackColor: WidgetStateProperty.all(_notionGray100),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: _notionGray800,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 12,
          color: _notionWhite,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _notionGray800,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: _notionWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _notionBlue,
        linearTrackColor: _notionGray200,
        circularTrackColor: _notionGray200,
      ),
    );
  }

  // Dark Theme - Notion Dark Mode
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      
      // Dark Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: _notionBlue,
        brightness: Brightness.dark,
        surface: _notionGray900,
        onSurface: _notionGray100,
        surfaceContainer: _notionGray800,
        surfaceContainerHighest: _notionGray700,
        onSurfaceVariant: _notionGray400,
        outline: _notionGray600,
        primary: _notionBlue,
        secondary: _notionGray400,
        tertiary: _notionPurple,
      ),

      // Dark App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: _notionGray900,
        foregroundColor: _notionGray100,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: _notionBlack.withAlpha(100),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: _notionGray900,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),

      // Dark Cards
      cardTheme: CardThemeData(
        color: _notionGray800,
        surfaceTintColor: Colors.transparent,
        shadowColor: _notionBlack.withAlpha(100),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: _notionGray700,
            width: 0.5,
          ),
        ),
      ),

      // Continue with other components for dark theme...
      // (Similar structure but with dark colors)

      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: _notionGray100,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
          letterSpacing: -0.25,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _notionGray100,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _notionGray200,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _notionGray200,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _notionGray400,
          height: 1.4,
        ),
      ),
    );
  }

  // Notion Accent Colors for UI Elements
  static const Map<String, Color> accentColors = {
    'blue': _notionBlue,
    'red': _notionRed,
    'green': _notionGreen,
    'yellow': _notionYellow,
    'orange': _notionOrange,
    'purple': _notionPurple,
    'pink': _notionPink,
    'teal': _notionTeal,
  };

  // Notion Semantic Colors
  static const Map<String, Color> semanticColors = {
    'success': _notionGreen,
    'warning': _notionYellow,
    'error': _notionRed,
    'info': _notionBlue,
  };
}