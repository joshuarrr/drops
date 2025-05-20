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
    surface: Colors.grey[100]!,
    onSurface: Colors.black,
    surfaceTint: Colors.black,
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
    surface: Colors.grey[900]!,
    onSurface: Colors.white,
    surfaceTint: Colors.white,
  );

  // Define button styles based on color scheme
  static ButtonStyle _buildElevatedButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.primary.withOpacity(0.35);
        } else if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(0.85);
        }
        return colorScheme.primary.withOpacity(0.5);
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return colorScheme.onPrimary;
      }),
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide.none,
        ),
      ),
    );
  }

  static ButtonStyle _buildTextButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.primary.withOpacity(0.35);
        } else if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(0.85);
        }
        return colorScheme.primary.withOpacity(0.5);
      }),
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ButtonStyle _buildOutlinedButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        return Colors.transparent;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.primary.withOpacity(0.35);
        } else if (states.contains(WidgetState.focused) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.selected)) {
          return colorScheme.primary.withOpacity(0.85);
        }
        return colorScheme.primary.withOpacity(0.5);
      }),
      side: WidgetStateProperty.all(BorderSide.none),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Update chip theme for both light and dark themes
  static ChipThemeData _buildChipTheme(ColorScheme colorScheme) {
    // For chips, we want to invert colors when selected
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ChipThemeData(
      backgroundColor: colorScheme.surface,
      disabledColor: colorScheme.primary.withOpacity(0.35),
      selectedColor: isDark
          ? Colors.black.withOpacity(0.85) // Dark mode: black background
          : Colors.white.withOpacity(0.85), // Light mode: white background
      labelStyle: TextStyle(color: colorScheme.onSurface),
      secondaryLabelStyle: TextStyle(color: colorScheme.onSurface),
      selectedShadowColor: Colors.transparent,
      showCheckmark: true,
      checkmarkColor: isDark ? Colors.white : Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightColorScheme,
    scaffoldBackgroundColor: _lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightColorScheme.surface,
      foregroundColor: _lightColorScheme.onSurface,
      elevation: _defaultElevation,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightColorScheme.primary,
      contentTextStyle: TextStyle(color: _lightColorScheme.onPrimary),
      actionTextColor: _lightColorScheme.onPrimary.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _buildElevatedButtonStyle(_lightColorScheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _buildTextButtonStyle(_lightColorScheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _buildOutlinedButtonStyle(_lightColorScheme),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _buildElevatedButtonStyle(_lightColorScheme),
    ),
    chipTheme: _buildChipTheme(_lightColorScheme),
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
    dividerTheme: DividerThemeData(
      color: _lightColorScheme.primary.withOpacity(0.2),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColorScheme.primary,
      foregroundColor: _lightColorScheme.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightColorScheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: _lightColorScheme.primary.withOpacity(0.4),
        ),
      ),
      floatingLabelStyle: TextStyle(color: _lightColorScheme.primary),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return _lightColorScheme.primary.withOpacity(0.5);
        }
        return null;
      }),
      thumbColor: WidgetStateProperty.all(_lightColorScheme.primary),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(_lightColorScheme.primary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_lightColorScheme.primary),
    ),
    textTheme: _buildTextTheme(_lightColorScheme),
    dialogTheme: DialogThemeData(backgroundColor: _lightColorScheme.surface),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkColorScheme,
    scaffoldBackgroundColor: _darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: _darkColorScheme.surface,
      foregroundColor: _darkColorScheme.onSurface,
      elevation: _defaultElevation,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkColorScheme.primary,
      contentTextStyle: TextStyle(color: _darkColorScheme.onPrimary),
      actionTextColor: _darkColorScheme.onPrimary.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _buildElevatedButtonStyle(_darkColorScheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: _buildTextButtonStyle(_darkColorScheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: _buildOutlinedButtonStyle(_darkColorScheme),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: _buildElevatedButtonStyle(_darkColorScheme),
    ),
    chipTheme: _buildChipTheme(_darkColorScheme),
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
    dividerTheme: DividerThemeData(
      color: _darkColorScheme.primary.withOpacity(0.2),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkColorScheme.primary,
      foregroundColor: _darkColorScheme.onPrimary,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkColorScheme.primary, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: _darkColorScheme.primary.withOpacity(0.4),
        ),
      ),
      floatingLabelStyle: TextStyle(color: _darkColorScheme.primary),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.selected)) {
          return _darkColorScheme.primary.withOpacity(0.5);
        }
        return null;
      }),
      thumbColor: WidgetStateProperty.all(_darkColorScheme.primary),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.all(_darkColorScheme.primary),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.all(_darkColorScheme.primary),
    ),
    textTheme: _buildTextTheme(_darkColorScheme),
    dialogTheme: DialogThemeData(backgroundColor: _darkColorScheme.surface),
  );

  // Helper method to build consistent text themes
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    // Material-3 reference typography
    // https://m3.material.io/styles/typography/overview

    const String? defaultFontFamily = null; // Keep null → use platform font

    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
        height: 64 / 57, // line-height ratio recommended by M3
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.normal,
        letterSpacing: -0.25,
        height: 52 / 45,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        height: 44 / 36,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),

      // Headlines
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        height: 40 / 32,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        height: 36 / 28,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.normal,
        letterSpacing: 0,
        height: 32 / 24,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),

      // Titles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 28 / 22,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 24 / 16,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.5,
        height: 24 / 16,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.25,
        height: 20 / 14,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        letterSpacing: 0.4,
        height: 16 / 12,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),

      // Labels
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
        fontFamily: defaultFontFamily,
        color: colorScheme.onSurface,
      ),
    );
  }
}
