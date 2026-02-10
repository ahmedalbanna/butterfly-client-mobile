import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFFD700); // Golden Yellow
  static const Color backgroundColor = Color(0xFF000000); // Deep Black
  static const Color surfaceColor = Color(0xFF1A1A1A);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color successColor = Color(0xFF66BB6A);

  // Text Styles
  static const String primaryFont = 'Alegreya';

  static final TextTheme textTheme = TextTheme(
    // Headings
    displayLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displayMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    displaySmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineSmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    // Body
    bodyLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      color: textColor,
    ),
    bodyMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      color: textColor,
    ),
    bodySmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      color: textSecondaryColor,
    ),
    // Labels
    labelLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    labelMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    labelSmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: textSecondaryColor,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    primaryColor: primaryColor,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall,
      iconTheme: const IconThemeData(color: textColor),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: backgroundColor,
      elevation: 8,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: textSecondaryColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: textSecondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle: textTheme.bodySmall,
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dividerColor: textSecondaryColor.withOpacity(0.2),
    useMaterial3: true,
  );
}
