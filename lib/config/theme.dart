import 'package:flutter/material.dart';

class AppTheme {
  // ==================== COLORS ====================
  
  // Primary & Backgrounds
  static const Color primaryColor = Color(0xFFFFD700); // Golden Yellow
  static const Color backgroundColor = Color(0xFF000000); // Deep Black
  static const Color surfaceColor = Color(0xFF1A1A1A); // Card/Surface
  static const Color surfaceLighter = Color(0xFF2A2A2A); // Lighter surface
  
  // Text Colors
  static const Color textColor = Color(0xFFFFFFFF); // White
  static const Color textSecondaryColor = Color(0xFFB0B0B0); // Gray
  static const Color textTertiaryColor = Color(0xFF808080); // Darker Gray
  
  // States
  static const Color errorColor = Color(0xFFEF5350);
  static const Color successColor = Color(0xFF66BB6A);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color infoColor = Color(0xFF42A5F5);
  
  // Accents & Borders
  static const Color accentColor = Color(0xFFFFE8B5); // Light golden
  static const Color borderColor = Color(0xFF3A3A3A);
  static const Color borderLightColor = Color(0xFF4A4A4A);
  static const Color dividerColor = Color(0xFF2A2A2A);
  
  // Semantic Colors
  static const Color disabledColor = Color(0xFF404040);
  static const Color shadowColor = Color(0xFF000000);
  
  // ==================== TYPOGRAPHY ====================
  
  static const String primaryFont = 'Alegreya';
  
  // Spacing Scale (8pt base)
  static const double spacing0 = 0;
  static const double spacing1 = 4;
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing7 = 32;
  static const double spacing8 = 40;
  
  // Border Radius
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXLarge = 16;
  static const double radiusFull = 100;
  
  // Shadows
  static const List<BoxShadow> shadowNone = [];
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x2D000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
  static const List<BoxShadow> shadowGolden = [
    BoxShadow(
      color: Color(0x40FFD700),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static final TextTheme textTheme = TextTheme(
    // Display - Hero/Large sections
    displayLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: -0.5,
    ),
    displayMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: -0.3,
    ),
    displaySmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    // Headings
    headlineMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textColor,
    ),
    headlineSmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textColor,
    ),
    // Body text
    bodyLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.5,
    ),
    bodyMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: textColor,
      height: 1.4,
    ),
    bodySmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textSecondaryColor,
      height: 1.4,
    ),
    // Labels & Buttons
    labelLarge: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: 0.1,
    ),
    labelMedium: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: textColor,
      letterSpacing: 0.1,
    ),
    labelSmall: const TextStyle(
      fontFamily: primaryFont,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: textSecondaryColor,
      letterSpacing: 0.15,
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColor,
    canvasColor: backgroundColor,
    primaryColor: primaryColor,
    textTheme: textTheme,
    
    // AppBar Styling
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.headlineSmall,
      iconTheme: const IconThemeData(color: textColor, size: 24),
      actionsIconTheme: const IconThemeData(color: textColor, size: 24),
      surfaceTintColor: Colors.transparent,
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: backgroundColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
    
    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    
    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    
    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: textTheme.labelLarge,
      ),
    ),
    
    // Input Field Styling
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: disabledColor, width: 1),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondaryColor),
      hintStyle: textTheme.bodySmall,
      errorStyle: textTheme.bodySmall?.copyWith(color: errorColor),
      helperStyle: textTheme.bodySmall,
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return primaryColor;
        return textSecondaryColor;
      }),
      suffixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return primaryColor;
        return textSecondaryColor;
      }),
    ),
    
    // Card Styling
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: const BorderSide(color: borderColor, width: 0.5),
      ),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: Colors.transparent,
    ),
    
    // Divider
    dividerColor: dividerColor,
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: spacing4,
    ),
    
    // Checkbox & Radio
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryColor;
        return borderColor;
      }),
      side: const BorderSide(color: primaryColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
      ),
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondaryColor,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radiusLarge),
          topRight: Radius.circular(radiusLarge),
        ),
      ),
      elevation: 8,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      titleTextStyle: textTheme.headlineSmall,
      contentTextStyle: textTheme.bodyMedium,
    ),
  );
}
