import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF0d9488);
  static const Color secondary = Color(0xFF06b6d4);
  static const Color teal500 = Color(0xFF14b8a6);
  static const Color teal700 = Color(0xFF0f766e);
  static const Color teal50 = Color(0xFFf0fdfa);
  static const Color teal100 = Color(0xFFccfbf1);

  static const Color cyan500 = Color(0xFF06b6d4);
  static const Color cyan700 = Color(0xFF0891b2);

  static const Color background = Color(0xFFf8fafc);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0f172a);
  static const Color textSecondary = Color(0xFF64748b);
  static const Color textHint = Color(0xFF94a3b8);
  static const Color border = Color(0xFFcbd5e1);
  static const Color borderLight = Color(0xFFe2e8f0);

  static const Color error = Color(0xFFef4444);
  static const Color success = Color(0xFF10b981);
  static const Color warning = Color(0xFFf59e0b);

  static const Color amber100 = Color(0xFFfef3c7);
  static const Color amber700 = Color(0xFFb45309);
  static const Color emerald100 = Color(0xFFd1fae5);
  static const Color emerald700 = Color(0xFF047857);
  static const Color red100 = Color(0xFFfee2e2);
  static const Color red700 = Color(0xFFb91c1c);
  static const Color purple100 = Color(0xFFf3e8ff);
  static const Color purple700 = Color(0xFF7e22ce);
  static const Color blue100 = Color(0xFFdbeafe);
  static const Color blue700 = Color(0xFF1d4ed8);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primary, cyan500, teal500],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, cyan500],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sectionUnderline = LinearGradient(
    colors: [Color(0xFF2dd4bf), Color(0xFF22d3ee)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const Color statusPending = amber700;
  static const Color statusPendingBg = amber100;
  static const Color statusCompleted = emerald700;
  static const Color statusCompletedBg = emerald100;
  static const Color statusCancelled = red700;
  static const Color statusCancelledBg = red100;
  static const Color statusAwaiting = purple700;
  static const Color statusAwaitingBg = purple100;
  static const Color statusInProgress = blue700;
  static const Color statusInProgressBg = blue100;
  static const Color statusActive = teal700;
  static const Color statusActiveBg = teal100;

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: cyan500,
      onSecondary: Colors.white,
      tertiary: teal500,
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFf1f5f9),
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimary,
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surface,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
          shadowColor: primary.withValues(alpha: 0.3),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(fontFamily: 'Cairo', color: textHint, fontSize: 14),
        labelStyle: TextStyle(fontFamily: 'Cairo', color: textSecondary, fontSize: 14),
        errorStyle: const TextStyle(fontFamily: 'Cairo', color: error, fontSize: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Cairo', fontSize: 60, fontWeight: FontWeight.w900, color: textPrimary),
        displayMedium: TextStyle(fontFamily: 'Cairo', fontSize: 48, fontWeight: FontWeight.w900, color: textPrimary),
        displaySmall: TextStyle(fontFamily: 'Cairo', fontSize: 36, fontWeight: FontWeight.bold, color: textPrimary),
        headlineLarge: TextStyle(fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.bold, color: textPrimary),
        headlineMedium: TextStyle(fontFamily: 'Cairo', fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        headlineSmall: TextStyle(fontFamily: 'Cairo', fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontFamily: 'Cairo', fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontFamily: 'Cairo', fontSize: 14, color: textPrimary, height: 1.6),
        bodySmall: TextStyle(fontFamily: 'Cairo', fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelMedium: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: textSecondary),
        labelSmall: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: textSecondary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 24,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      ),
    );
  }
}
