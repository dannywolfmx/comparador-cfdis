import 'package:flutter/material.dart';

/// Utilidades para colores adaptativos que mantienen buen contraste
/// en modo claro y oscuro
class AdaptiveColors {
  /// Obtiene colores adaptativos para métricas financieras
  static AdaptiveColorSet getFinancialMetricColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return AdaptiveColorSet(
      // Subtotal - Azul
      subtotal: isDark ? Colors.lightBlue.shade300 : Colors.blue.shade700,
      subtotalContainer: isDark
          ? Colors.lightBlue.shade900.withValues(alpha: 0.3)
          : Colors.blue.shade50,
      onSubtotal: isDark ? Colors.lightBlue.shade900 : Colors.white,

      // Descuento - Naranja
      descuento: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
      descuentoContainer: isDark
          ? Colors.orange.shade900.withValues(alpha: 0.3)
          : Colors.orange.shade50,
      onDescuento: isDark ? Colors.orange.shade900 : Colors.white,

      // Base gravable - Verde
      baseGravable: isDark ? Colors.green.shade300 : Colors.green.shade700,
      baseGravableContainer: isDark
          ? Colors.green.shade900.withValues(alpha: 0.3)
          : Colors.green.shade50,
      onBaseGravable: isDark ? Colors.green.shade900 : Colors.white,

      // IVA - Índigo
      iva: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700,
      ivaContainer: isDark
          ? Colors.indigo.shade900.withValues(alpha: 0.3)
          : Colors.indigo.shade50,
      onIva: isDark ? Colors.indigo.shade900 : Colors.white,

      // Total - Teal
      total: isDark ? Colors.teal.shade300 : Colors.teal.shade700,
      totalContainer: isDark
          ? Colors.teal.shade900.withValues(alpha: 0.3)
          : Colors.teal.shade50,
      onTotal: isDark ? Colors.teal.shade900 : Colors.white,

      // Total con IVA - Púrpura
      totalConIva: isDark ? Colors.purple.shade300 : Colors.purple.shade700,
      totalConIvaContainer: isDark
          ? Colors.purple.shade900.withValues(alpha: 0.3)
          : Colors.purple.shade50,
      onTotalConIva: isDark ? Colors.purple.shade900 : Colors.white,

      // Colores de superficie y contraste
      surface: colorScheme.surface,
      onSurface: colorScheme.onSurface,
      surfaceVariant: colorScheme.surfaceContainerHighest,
      onSurfaceVariant: colorScheme.onSurfaceVariant,
      outline: colorScheme.outline,
      shadow: colorScheme.shadow,
    );
  }

  /// Obtiene colores para botones de acción adaptativos
  static AdaptiveActionColors getActionColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveActionColors(
      // Botón añadir archivo - Azul
      addFile: isDark ? Colors.blue.shade400 : Colors.blue.shade600,
      onAddFile: isDark ? Colors.blue.shade900 : Colors.white,

      // Botón cargar directorio - Verde
      loadDirectory: isDark ? Colors.green.shade400 : Colors.green.shade600,
      onLoadDirectory: isDark ? Colors.green.shade900 : Colors.white,

      // Botón secundario
      secondary: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
      onSecondary: isDark ? Colors.grey.shade900 : Colors.white,
    );
  }

  /// Obtiene colores para diferentes tipos de CFDI
  static Color getCfdiTypeColor(BuildContext context, String tipoComprobante) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (tipoComprobante.toUpperCase()) {
      case 'I': // Ingreso
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'E': // Egreso
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'T': // Traslado
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'P': // Pago
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'N': // Nómina
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  /// Obtiene color de superficie con elevación adaptativa
  static Color getElevatedSurface(
    BuildContext context, {
    double elevation = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      // En modo oscuro, incrementar ligeramente el brillo
      return Color.alphaBlend(
        colorScheme.surfaceTint.withValues(alpha: 0.05 * elevation),
        colorScheme.surface,
      );
    } else {
      // En modo claro, usar superficie estándar
      return colorScheme.surface;
    }
  }

  /// Obtiene color de texto con contraste adecuado
  static Color getContrastingTextColor(Color backgroundColor) {
    // Calcular luminancia
    final luminance = backgroundColor.computeLuminance();

    // Si es oscuro, usar texto claro; si es claro, usar texto oscuro
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Obtiene color de borde adaptativo
  static Color getAdaptiveBorderColor(
    BuildContext context, {
    double opacity = 0.2,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.outline.withValues(alpha: opacity);
  }

  /// Obtiene gradiente adaptativo para contenedores
  static LinearGradient getAdaptiveGradient(
    BuildContext context,
    Color baseColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: 0.2),
          baseColor.withValues(alpha: 0.1),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: 0.1),
          baseColor.withValues(alpha: 0.05),
        ],
      );
    }
  }
}

/// Clase para almacenar conjunto de colores adaptativos para métricas
class AdaptiveColorSet {
  final Color subtotal;
  final Color subtotalContainer;
  final Color onSubtotal;

  final Color descuento;
  final Color descuentoContainer;
  final Color onDescuento;

  final Color baseGravable;
  final Color baseGravableContainer;
  final Color onBaseGravable;

  final Color iva;
  final Color ivaContainer;
  final Color onIva;

  final Color total;
  final Color totalContainer;
  final Color onTotal;

  final Color totalConIva;
  final Color totalConIvaContainer;
  final Color onTotalConIva;

  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final Color outline;
  final Color shadow;

  const AdaptiveColorSet({
    required this.subtotal,
    required this.subtotalContainer,
    required this.onSubtotal,
    required this.descuento,
    required this.descuentoContainer,
    required this.onDescuento,
    required this.baseGravable,
    required this.baseGravableContainer,
    required this.onBaseGravable,
    required this.iva,
    required this.ivaContainer,
    required this.onIva,
    required this.total,
    required this.totalContainer,
    required this.onTotal,
    required this.totalConIva,
    required this.totalConIvaContainer,
    required this.onTotalConIva,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.outline,
    required this.shadow,
  });
}

/// Clase para almacenar colores de acciones adaptativos
class AdaptiveActionColors {
  final Color addFile;
  final Color onAddFile;
  final Color loadDirectory;
  final Color onLoadDirectory;
  final Color secondary;
  final Color onSecondary;

  const AdaptiveActionColors({
    required this.addFile,
    required this.onAddFile,
    required this.loadDirectory,
    required this.onLoadDirectory,
    required this.secondary,
    required this.onSecondary,
  });
}
