import 'package:flutter/material.dart';

/// Tokens de espaciado y dimensiones para la aplicación
class AppSpacing {
  // Espaciado base
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Espaciado específico para componentes
  static const double cardPadding = md;
  static const double listItemPadding = sm;
  static const double buttonPadding = md;
  static const double dialogPadding = lg;
  static const double screenPadding = md;

  // Márgenes
  static const double cardMargin = sm;
  static const double listItemMargin = xs;
  static const double sectionMargin = lg;

  // Espaciado vertical
  static const double verticalSpaceXs = xs;
  static const double verticalSpaceSm = sm;
  static const double verticalSpaceMd = md;
  static const double verticalSpaceLg = lg;
  static const double verticalSpaceXl = xl;

  // Espaciado horizontal
  static const double horizontalSpaceXs = xs;
  static const double horizontalSpaceSm = sm;
  static const double horizontalSpaceMd = md;
  static const double horizontalSpaceLg = lg;
  static const double horizontalSpaceXl = xl;

  // Widgets de espaciado
  static const Widget verticalXs = SizedBox(height: xs);
  static const Widget verticalSm = SizedBox(height: sm);
  static const Widget verticalMd = SizedBox(height: md);
  static const Widget verticalLg = SizedBox(height: lg);
  static const Widget verticalXl = SizedBox(height: xl);

  static const Widget horizontalXs = SizedBox(width: xs);
  static const Widget horizontalSm = SizedBox(width: sm);
  static const Widget horizontalMd = SizedBox(width: md);
  static const Widget horizontalLg = SizedBox(width: lg);
  static const Widget horizontalXl = SizedBox(width: xl);
}

/// Dimensiones para componentes
class AppDimensions {
  // Bordes redondeados
  static const double borderRadiusXs = 4.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;
  static const double borderRadiusXl = 20.0;

  // Elevaciones
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 3.0;
  static const double elevationLg = 6.0;
  static const double elevationXl = 12.0;

  // Alturas de componentes
  static const double buttonHeight = 40.0;
  static const double inputHeight = 48.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavigationHeight = 80.0;
  static const double navigationRailWidth = 72.0;
  static const double listTileHeight = 56.0;
  static const double chipHeight = 32.0;

  // Anchos
  static const double dialogMaxWidth = 560.0;
  static const double sideSheetWidth = 400.0;
  static const double cardMaxWidth = 400.0;
  static const double buttonMinWidth = 88.0;

  // Tamaños de iconos
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Breakpoints para responsive design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

/// Utilidades para responsive design
class AppLayout {
  /// Determina si la pantalla es móvil
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppDimensions.mobileBreakpoint;
  }

  /// Determina si la pantalla es tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppDimensions.mobileBreakpoint &&
        width < AppDimensions.desktopBreakpoint;
  }

  /// Determina si la pantalla es desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppDimensions.desktopBreakpoint;
  }

  /// Obtiene el número de columnas para un grid basado en el tamaño de pantalla
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// Obtiene el padding horizontal apropiado para la pantalla
  static double getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) return AppSpacing.md;
    if (isTablet(context)) return AppSpacing.lg;
    return AppSpacing.xl;
  }

  /// Obtiene el ancho máximo del contenido
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800.0;
    return 1200.0;
  }
}

/// Configuración de animaciones
class AppAnimations {
  // Duraciones
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Curvas
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve bounce = Curves.elasticOut;

  // Transiciones comunes
  static const Duration pageTransition = medium;
  static const Duration dialogTransition = medium;
  static const Duration bottomSheetTransition = medium;
  static const Duration hoverTransition = fast;
}
