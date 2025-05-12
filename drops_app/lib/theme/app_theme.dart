import 'package:flutter/material.dart';

class AppTheme {
  static const double _defaultElevation = 1.0;

  // Light theme colors
  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Colors.black,
    onPrimary: Colors.white,
    secondary: Colors.grey[800]!,
    onSecondary: Colors.white,
    error: Colors.red[700]!,
    onError: Colors.white,
    background: Colors.white,
    onBackground: Colors.black,
    surface: Colors.grey[100]!,
    onSurface: Colors.black,
  );

  // Dark theme colors
  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.grey[400]!,
    onSecondary: Colors.black,
    error: Colors.red[300]!,
    onError: Colors.black,
    background: Colors.black,
    onBackground: Colors.white,
    surface: Colors.grey[900]!,
    onSurface: Colors.white,
  );

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.background,
      foregroundColor: _lightColorScheme.onBackground,
      elevation: _defaultElevation,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _lightColorScheme.onPrimary,
        backgroundColor: _lightColorScheme.primary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightColorScheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightColorScheme.primary,
        side: BorderSide(color: _lightColorScheme.primary),
      ),
    ),
    iconTheme: IconThemeData(color: _lightColorScheme.primary),
    sliderTheme: SliderThemeData(
      activeTrackColor: _lightColorScheme.primary,
      inactiveTrackColor: _lightColorScheme.primary.withOpacity(0.3),
      thumbColor: _lightColorScheme.primary,
      overlayColor: _lightColorScheme.primary.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightColorScheme.surface,
      selectedItemColor: _lightColorScheme.primary,
      unselectedItemColor: _lightColorScheme.primary.withOpacity(0.6),
    ),
    cardColor: _lightColorScheme.surface,
    dialogBackgroundColor: _lightColorScheme.background,
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.primary.withOpacity(0.2),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    textTheme: _buildTextTheme(_lightColorScheme),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.background,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.background,
      foregroundColor: _darkColorScheme.onBackground,
      elevation: _defaultElevation,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: _darkColorScheme.onPrimary,
        backgroundColor: _darkColorScheme.primary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkColorScheme.primary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkColorScheme.primary,
        side: BorderSide(color: _darkColorScheme.primary),
      ),
    ),
    iconTheme: IconThemeData(color: _darkColorScheme.primary),
    sliderTheme: SliderThemeData(
      activeTrackColor: _darkColorScheme.primary,
      inactiveTrackColor: _darkColorScheme.primary.withOpacity(0.3),
      thumbColor: _darkColorScheme.primary,
      overlayColor: _darkColorScheme.primary.withOpacity(0.1),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkColorScheme.surface,
      selectedItemColor: _darkColorScheme.primary,
      unselectedItemColor: _darkColorScheme.primary.withOpacity(0.6),
    ),
    cardColor: _darkColorScheme.surface,
    dialogBackgroundColor: _darkColorScheme.background,
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.primary.withOpacity(0.2),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    textTheme: _buildTextTheme(_darkColorScheme),
  );

  // Helper method to build consistent text themes
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(color: colorScheme.onBackground),
      displayMedium: TextStyle(color: colorScheme.onBackground),
      displaySmall: TextStyle(color: colorScheme.onBackground),
      headlineLarge: TextStyle(color: colorScheme.onBackground),
      headlineMedium: TextStyle(color: colorScheme.onBackground),
      headlineSmall: TextStyle(color: colorScheme.onBackground),
      titleLarge: TextStyle(color: colorScheme.onBackground),
      titleMedium: TextStyle(color: colorScheme.onBackground),
      titleSmall: TextStyle(color: colorScheme.onBackground),
      bodyLarge: TextStyle(color: colorScheme.onBackground),
      bodyMedium: TextStyle(color: colorScheme.onBackground),
      bodySmall: TextStyle(color: colorScheme.onBackground),
      labelLarge: TextStyle(color: colorScheme.onBackground),
      labelMedium: TextStyle(color: colorScheme.onBackground),
      labelSmall: TextStyle(color: colorScheme.onBackground),
    );
  }
}
