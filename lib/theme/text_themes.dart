import 'package:flutter/material.dart';

/// Temas de texto para la aplicación siguiendo Material Design 3
class AppTextThemes {
  /// Familia de fuentes base
  static const String _fontFamily = 'Roboto';

  /// Tema de texto claro
  static const TextTheme lightTextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.27,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFF1C1B1F),
    ),
  );

  /// Tema de texto oscuro
  static const TextTheme darkTextTheme = TextTheme(
    // Display styles
    displayLarge: TextStyle(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    displayMedium: TextStyle(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    displaySmall: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),

    // Headline styles
    headlineLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.25,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.29,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),

    // Title styles
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.27,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      height: 1.5,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),

    // Label styles
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),

    // Body styles
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      height: 1.5,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      fontFamily: _fontFamily,
      color: Color(0xFFE6E1E5),
    ),
  );

  /// Estilos de texto personalizados para la aplicación
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    fontFamily: _fontFamily,
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    fontFamily: _fontFamily,
  );

  static const TextStyle metricLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle chipText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: _fontFamily,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle tableHeader = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    fontFamily: _fontFamily,
  );

  static const TextStyle tableCell = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    fontFamily: _fontFamily,
  );
}
