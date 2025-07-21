import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Servicio para manejar configuración y utilidades de accesibilidad
class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance =>
      _instance ??= AccessibilityService._();

  AccessibilityService._();

  /// Configuración de accesibilidad
  bool _isScreenReaderEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  bool _isReduceMotionEnabled = false;
  double _textScaleFactor = 1.0;

  // Getters
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  bool get isReduceMotionEnabled => _isReduceMotionEnabled;
  double get textScaleFactor => _textScaleFactor;

  /// Inicializar el servicio de accesibilidad
  Future<void> initialize() async {
    await _detectAccessibilitySettings();
  }

  /// Detectar configuraciones de accesibilidad del sistema
  Future<void> _detectAccessibilitySettings() async {
    // Nota: Flutter no proporciona APIs directas para detectar todas estas configuraciones
    // Esta es una implementación base que se puede extender

    // Por ahora, usar MediaQuery para detectar algunas configuraciones
    // Esto debería ser llamado desde el contexto de la aplicación
  }

  /// Actualizar configuraciones desde MediaQuery
  void updateFromMediaQuery(MediaQueryData mediaQuery) {
    _isHighContrastEnabled = mediaQuery.highContrast;
    _textScaleFactor = mediaQuery.textScaleFactor;
    _isLargeTextEnabled = mediaQuery.textScaleFactor > 1.2;
    _isReduceMotionEnabled = mediaQuery.disableAnimations;

    // TalkBack/VoiceOver detection (aproximado)
    _isScreenReaderEnabled = mediaQuery.accessibleNavigation;
  }

  /// Proporcionar feedback háptico accesible
  static void provideFeedback(AccessibilityFeedback feedback) {
    switch (feedback) {
      case AccessibilityFeedback.success:
        HapticFeedback.lightImpact();
        break;
      case AccessibilityFeedback.error:
        HapticFeedback.heavyImpact();
        break;
      case AccessibilityFeedback.warning:
        HapticFeedback.mediumImpact();
        break;
      case AccessibilityFeedback.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Anunciar texto a lectores de pantalla
  static void announce(String message, {TextDirection? textDirection}) {
    SemanticsService.announce(
      message,
      textDirection ?? TextDirection.ltr,
    );
  }

  /// Obtener duración de animación considerando preferencias de accesibilidad
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_isReduceMotionEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// Obtener colores con contraste apropiado
  Color getAccessibleColor(
      Color baseColor, Color backgroundColor, BuildContext context) {
    if (!_isHighContrastEnabled) {
      return baseColor;
    }

    // Calcular contraste y ajustar si es necesario
    final luminance1 = baseColor.computeLuminance();
    final luminance2 = backgroundColor.computeLuminance();
    final contrast = _calculateContrast(luminance1, luminance2);

    // WCAG AA requiere al menos 4.5:1 para texto normal
    if (contrast < 4.5) {
      // Ajustar color para mayor contraste
      return _adjustColorForContrast(baseColor, backgroundColor);
    }

    return baseColor;
  }

  /// Calcular relación de contraste entre dos colores
  double _calculateContrast(double luminance1, double luminance2) {
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Ajustar color para mejor contraste
  Color _adjustColorForContrast(Color baseColor, Color backgroundColor) {
    final bgLuminance = backgroundColor.computeLuminance();

    // Si el fondo es claro, hacer el texto más oscuro
    if (bgLuminance > 0.5) {
      return Colors.black87;
    } else {
      return Colors.white;
    }
  }

  /// Verificar si un widget necesita focus
  static bool shouldAutoFocus(BuildContext context) {
    return MediaQuery.of(context).accessibleNavigation;
  }

  /// Crear FocusNode con configuración accesible
  static FocusNode createAccessibleFocusNode({
    String? debugLabel,
    bool skipTraversal = false,
    bool descendantsAreFocusable = true,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      skipTraversal: skipTraversal,
      descendantsAreFocusable: descendantsAreFocusable,
    );
  }
}

/// Tipos de feedback de accesibilidad
enum AccessibilityFeedback {
  success,
  error,
  warning,
  selection,
}

/// Widget para proporcionar información de accesibilidad en tiempo real
class AccessibilityWrapper extends StatelessWidget {
  final Widget child;
  final String? screenName;

  const AccessibilityWrapper({
    super.key,
    required this.child,
    this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    // Actualizar configuraciones de accesibilidad
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccessibilityService.instance
          .updateFromMediaQuery(MediaQuery.of(context));

      // Anunciar cambio de pantalla si es necesario
      if (screenName != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          AccessibilityService.announce('Navegaste a $screenName');
        });
      }
    });

    return child;
  }
}

/// Mixin para widgets que necesiten funcionalidades de accesibilidad
mixin AccessibilityMixin<T extends StatefulWidget> on State<T> {
  late AccessibilityService _accessibilityService;

  @override
  void initState() {
    super.initState();
    _accessibilityService = AccessibilityService.instance;
  }

  /// Anunciar mensaje a lectores de pantalla
  void announceMessage(String message) {
    AccessibilityService.announce(message);
  }

  /// Proporcionar feedback háptico
  void provideFeedback(AccessibilityFeedback feedback) {
    AccessibilityService.provideFeedback(feedback);
  }

  /// Verificar si las animaciones están reducidas
  bool get isReduceMotionEnabled => _accessibilityService.isReduceMotionEnabled;

  /// Obtener duración de animación apropiada
  Duration getAnimationDuration(Duration defaultDuration) {
    return _accessibilityService.getAnimationDuration(defaultDuration);
  }

  /// Verificar si el lector de pantalla está activo
  bool get isScreenReaderEnabled => _accessibilityService.isScreenReaderEnabled;
}

/// Widget para mostrar estado de carga accesible
class AccessibleLoadingIndicator extends StatelessWidget {
  final String loadingMessage;
  final Widget? child;

  const AccessibleLoadingIndicator({
    super.key,
    this.loadingMessage = 'Cargando...',
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: loadingMessage,
      liveRegion: true,
      child: child ?? const CircularProgressIndicator(),
    );
  }
}

/// Widget para mostrar errores de forma accesible
class AccessibleErrorWidget extends StatelessWidget {
  final String errorMessage;
  final String? errorDetails;
  final VoidCallback? onRetry;
  final Widget? icon;

  const AccessibleErrorWidget({
    super.key,
    required this.errorMessage,
    this.errorDetails,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Error: $errorMessage',
      liveRegion: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ?? const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (errorDetails != null) ...[
            const SizedBox(height: 8),
            Text(
              errorDetails!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
