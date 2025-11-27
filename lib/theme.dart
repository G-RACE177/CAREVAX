import 'package:flutter/material.dart';

// Professional color palette for immunization app
const Color kPrimaryColor = Color(0xFF1976D2);      // Primary blue
const Color kPrimaryVariant = Color(0xFF0D47A1);    // Darker blue
const Color kSecondaryColor = Color(0xFF43A047);    // Accent green
const Color kBackgroundColor = Color(0xFFF5F7FA);   // Light background
const Color kSurfaceColor = Color(0xFFFFFFFF);      // White surface
const Color kErrorColor = Color(0xFFD32F2F);        // Error red
const Color kTextPrimary = Color(0xFF212121);       // Primary text
const Color kTextSecondary = Color(0xFF757575);     // Secondary text
const Color kDividerColor = Color(0xFFEEEEEE);      // Divider color

// Spacing constants
const double kDefaultPadding = 16.0;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border radius
const double kDefaultRadius = 8.0;
const double kLargeRadius = 16.0;
const double kSmallRadius = 4.0;

ThemeData appTheme() {
  final colorScheme = ColorScheme(
    primary: kPrimaryColor,
    primaryContainer: kPrimaryVariant,
    secondary: kSecondaryColor,
    secondaryContainer: kSecondaryColor.withOpacity(0.8),
    surface: kSurfaceColor,
    background: kBackgroundColor,
    error: kErrorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: kTextPrimary,
    onBackground: kTextPrimary,
    onError: Colors.white,
    brightness: Brightness.light,
  );
  
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kBackgroundColor,
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Card theme
    cardTheme: const CardThemeData(
      color: kSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(kDefaultRadius)),
      ),
      margin: EdgeInsets.symmetric(
        vertical: kSmallPadding,
        horizontal: kSmallPadding,
      ),
    ),
    
    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(kPrimaryColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 24,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
        ),
        elevation: MaterialStateProperty.all(2),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(kPrimaryColor),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 16,
          ),
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(kPrimaryColor),
        side: MaterialStateProperty.all(BorderSide(color: kPrimaryColor)),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 24,
          ),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kDefaultRadius),
          ),
        ),
      ),
    ),
    
    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceColor,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
        borderSide: BorderSide(color: kDividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
        borderSide: BorderSide(color: kDividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
        borderSide: BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultRadius),
        borderSide: BorderSide(color: kErrorColor),
      ),
    ),
    
    // Text theme
    textTheme: TextTheme(
      displayLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: kTextPrimary),
      bodyMedium: TextStyle(color: kTextPrimary),
      bodySmall: TextStyle(color: kTextSecondary),
      labelLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(color: kTextPrimary),
      labelSmall: TextStyle(color: kTextSecondary),
    ),
    
    // Divider theme
    dividerTheme: DividerThemeData(
      color: kDividerColor,
      thickness: 1,
      space: 16,
    ),
  );
}
