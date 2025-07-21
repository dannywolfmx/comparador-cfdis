import 'package:flutter/material.dart';

/// Esquemas de colores para la aplicación siguiendo Material Design 3
class AppColorSchemes {
  /// Esquema de colores claro
  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1976D2),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE3F2FD),
    onPrimaryContainer: Color(0xFF0D47A1),
    secondary: Color(0xFF388E3C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8F5E8),
    onSecondaryContainer: Color(0xFF1B5E20),
    tertiary: Color(0xFFFF6F00),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFE0B2),
    onTertiaryContainer: Color(0xFFE65100),
    error: Color(0xFFD32F2F),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFEBEE),
    onErrorContainer: Color(0xFFB71C1C),
    surface: Color(0xFFFFFBFE),
    onSurface: Color(0xFF1C1B1F),
    surfaceContainerHighest: Color(0xFFF5F5F5),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFCAC4D0),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF313033),
    onInverseSurface: Color(0xFFF4EFF4),
    inversePrimary: Color(0xFF90CAF9),
    surfaceTint: Color(0xFF1976D2),
  );

  /// Esquema de colores oscuro
  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF90CAF9),
    onPrimary: Color(0xFF0D47A1),
    primaryContainer: Color(0xFF1565C0),
    onPrimaryContainer: Color(0xFFE3F2FD),
    secondary: Color(0xFF81C784),
    onSecondary: Color(0xFF1B5E20),
    secondaryContainer: Color(0xFF2E7D32),
    onSecondaryContainer: Color(0xFFE8F5E8),
    tertiary: Color(0xFFFFB74D),
    onTertiary: Color(0xFFE65100),
    tertiaryContainer: Color(0xFFFF8F00),
    onTertiaryContainer: Color(0xFFFFE0B2),
    error: Color(0xFFEF5350),
    onError: Color(0xFFB71C1C),
    errorContainer: Color(0xFFC62828),
    onErrorContainer: Color(0xFFFFEBEE),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE6E1E5),
    surfaceContainerHighest: Color(0xFF424242),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
    outlineVariant: Color(0xFF49454F),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE6E1E5),
    onInverseSurface: Color(0xFF313033),
    inversePrimary: Color(0xFF1976D2),
    surfaceTint: Color(0xFF90CAF9),
  );

  /// Colores adicionales para la aplicación
  static const Color cfdiIngreso = Color(0xFF4CAF50);
  static const Color cfdiEgreso = Color(0xFFF44336);
  static const Color cfdiTraslado = Color(0xFFFF9800);
  static const Color cfdiNomina = Color(0xFF9C27B0);
  static const Color cfdiPago = Color(0xFF2196F3);

  /// Colores para métricas
  static const Color metricPositive = Color(0xFF4CAF50);
  static const Color metricNegative = Color(0xFFF44336);
  static const Color metricNeutral = Color(0xFF757575);
  static const Color metricWarning = Color(0xFFFF9800);

  /// Colores para estados
  static const Color stateSuccess = Color(0xFF4CAF50);
  static const Color stateWarning = Color(0xFFFF9800);
  static const Color stateError = Color(0xFFF44336);
  static const Color stateInfo = Color(0xFF2196F3);

  /// Obtener color por tipo de comprobante
  static Color getColorByTipoComprobante(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'I':
        return cfdiIngreso;
      case 'E':
        return cfdiEgreso;
      case 'T':
        return cfdiTraslado;
      case 'N':
        return cfdiNomina;
      case 'P':
        return cfdiPago;
      default:
        return metricNeutral;
    }
  }

  /// Gradientes para cards y contenedores
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1976D2),
    ],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4CAF50),
      Color(0xFF388E3C),
    ],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBFE),
      Color(0xFFF5F5F5),
    ],
  );
}
