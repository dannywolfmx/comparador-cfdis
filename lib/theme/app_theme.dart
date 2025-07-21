import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_schemes.dart';
import 'text_themes.dart';

/// Configuración principal del tema de la aplicación
class AppTheme {
  /// Tema claro de la aplicación
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.lightScheme,
      textTheme: AppTextThemes.lightTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        foregroundColor: AppColorSchemes.lightScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTextThemes.appBarTitle.copyWith(
          color: AppColorSchemes.lightScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: AppColorSchemes.lightScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColorSchemes.lightScheme.surface,
        surfaceTintColor: AppColorSchemes.lightScheme.surfaceTint,
        elevation: 1,
        shadowColor: AppColorSchemes.lightScheme.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColorSchemes.lightScheme.onPrimary,
          backgroundColor: AppColorSchemes.lightScheme.primary,
          elevation: 1,
          shadowColor: AppColorSchemes.lightScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextThemes.buttonText,
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: AppColorSchemes.lightScheme.onPrimary,
          backgroundColor: AppColorSchemes.lightScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextThemes.buttonText,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorSchemes.lightScheme.primary,
          side: BorderSide(
            color: AppColorSchemes.lightScheme.outline,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextThemes.buttonText,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorSchemes.lightScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: AppTextThemes.buttonText,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorSchemes.lightScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorSchemes.lightScheme.outline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorSchemes.lightScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorSchemes.lightScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorSchemes.lightScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColorSchemes.lightScheme.error,
            width: 2,
          ),
        ),
        labelStyle: AppTextThemes.lightTextTheme.bodyMedium,
        hintStyle: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
          color: AppColorSchemes.lightScheme.onSurfaceVariant,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColorSchemes.lightScheme.surfaceContainerHighest,
        deleteIconColor: AppColorSchemes.lightScheme.onSurfaceVariant,
        disabledColor: AppColorSchemes.lightScheme.onSurface.withOpacity(0.12),
        selectedColor: AppColorSchemes.lightScheme.secondaryContainer,
        secondarySelectedColor: AppColorSchemes.lightScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: AppTextThemes.chipText.copyWith(
          color: AppColorSchemes.lightScheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: AppTextThemes.chipText.copyWith(
          color: AppColorSchemes.lightScheme.onSecondaryContainer,
        ),
        brightness: Brightness.light,
        elevation: 1,
        pressElevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: AppColorSchemes.lightScheme.surface,
        selectedTileColor: AppColorSchemes.lightScheme.secondaryContainer,
        iconColor: AppColorSchemes.lightScheme.onSurfaceVariant,
        textColor: AppColorSchemes.lightScheme.onSurface,
        titleTextStyle: AppTextThemes.lightTextTheme.bodyLarge,
        subtitleTextStyle: AppTextThemes.lightTextTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        surfaceTintColor: AppColorSchemes.lightScheme.surfaceTint,
        elevation: 1,
        shadowColor: AppColorSchemes.lightScheme.shadow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(16),
          ),
        ),
      ),

      // Navigation Rail Theme
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        elevation: 1,
        selectedIconTheme: IconThemeData(
          color: AppColorSchemes.lightScheme.onSecondaryContainer,
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColorSchemes.lightScheme.onSurfaceVariant,
        ),
        selectedLabelTextStyle:
            AppTextThemes.lightTextTheme.labelMedium?.copyWith(
          color: AppColorSchemes.lightScheme.onSurface,
        ),
        unselectedLabelTextStyle:
            AppTextThemes.lightTextTheme.labelMedium?.copyWith(
          color: AppColorSchemes.lightScheme.onSurfaceVariant,
        ),
        indicatorColor: AppColorSchemes.lightScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        elevation: 3,
        height: 80,
        indicatorColor: AppColorSchemes.lightScheme.secondaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextThemes.lightTextTheme.labelMedium?.copyWith(
              color: AppColorSchemes.lightScheme.onSurface,
            );
          }
          return AppTextThemes.lightTextTheme.labelMedium?.copyWith(
            color: AppColorSchemes.lightScheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: AppColorSchemes.lightScheme.onSecondaryContainer,
            );
          }
          return IconThemeData(
            color: AppColorSchemes.lightScheme.onSurfaceVariant,
          );
        }),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColorSchemes.lightScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorSchemes.lightScheme.onPrimary;
          }
          return AppColorSchemes.lightScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorSchemes.lightScheme.primary;
          }
          return AppColorSchemes.lightScheme.surfaceContainerHighest;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColorSchemes.lightScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor:
            WidgetStateProperty.all(AppColorSchemes.lightScheme.onPrimary),
        overlayColor: WidgetStateProperty.all(
          AppColorSchemes.lightScheme.primary.withOpacity(0.12),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColorSchemes.lightScheme.primary,
        linearTrackColor: AppColorSchemes.lightScheme.surfaceContainerHighest,
        circularTrackColor: AppColorSchemes.lightScheme.surfaceContainerHighest,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorSchemes.lightScheme.inverseSurface,
        contentTextStyle: AppTextThemes.lightTextTheme.bodyMedium?.copyWith(
          color: AppColorSchemes.lightScheme.onInverseSurface,
        ),
        actionTextColor: AppColorSchemes.lightScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        surfaceTintColor: AppColorSchemes.lightScheme.surfaceTint,
        elevation: 3,
        modalBackgroundColor: AppColorSchemes.lightScheme.surface,
        modalElevation: 3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AppColorSchemes.lightScheme.surface,
        surfaceTintColor: AppColorSchemes.lightScheme.surfaceTint,
        elevation: 3,
        shadowColor: AppColorSchemes.lightScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppTextThemes.lightTextTheme.headlineSmall,
        contentTextStyle: AppTextThemes.lightTextTheme.bodyMedium,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColorSchemes.lightScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextThemes.lightTextTheme.bodySmall?.copyWith(
          color: AppColorSchemes.lightScheme.onInverseSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // Menu Theme
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor:
              WidgetStateProperty.all(AppColorSchemes.lightScheme.surface),
          surfaceTintColor:
              WidgetStateProperty.all(AppColorSchemes.lightScheme.surfaceTint),
          elevation: WidgetStateProperty.all(3),
          shadowColor:
              WidgetStateProperty.all(AppColorSchemes.lightScheme.shadow),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Scroll behavior
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(
          AppColorSchemes.lightScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        trackColor: WidgetStateProperty.all(
          AppColorSchemes.lightScheme.surfaceContainerHighest,
        ),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(8),
      ),
    );
  }

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColorSchemes.darkScheme,
      textTheme: AppTextThemes.darkTextTheme,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorSchemes.darkScheme.surface,
        foregroundColor: AppColorSchemes.darkScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: AppTextThemes.appBarTitle.copyWith(
          color: AppColorSchemes.darkScheme.onSurface,
        ),
        iconTheme: IconThemeData(
          color: AppColorSchemes.darkScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: AppColorSchemes.darkScheme.surface,
        surfaceTintColor: AppColorSchemes.darkScheme.surfaceTint,
        elevation: 1,
        shadowColor: AppColorSchemes.darkScheme.shadow,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Similar button themes as light theme but with dark colors
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColorSchemes.darkScheme.onPrimary,
          backgroundColor: AppColorSchemes.darkScheme.primary,
          elevation: 1,
          shadowColor: AppColorSchemes.darkScheme.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: AppTextThemes.buttonText,
        ),
      ),

      // Continue with other themes similar to light theme but using dark colors...
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Obtener el tema basado en el modo de brightness
  static ThemeData getTheme(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
}
