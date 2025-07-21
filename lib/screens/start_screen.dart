import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/providers/column_visibility_provider.dart';
import 'package:comparador_cfdis/widgets/cfdi_dashboard.dart';
import 'package:comparador_cfdis/widgets/adaptive_cfdi_view.dart';
import 'package:comparador_cfdis/widgets/collapsible_filter_panel.dart';
import 'package:comparador_cfdis/widgets/modern/modern_card.dart';
import 'package:comparador_cfdis/widgets/modern/modern_scaffold.dart';
import 'package:comparador_cfdis/widgets/accessibility/accessible_widget.dart';
import 'package:comparador_cfdis/services/accessibility_service.dart';
import 'package:comparador_cfdis/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with AccessibilityMixin {
  bool _isFilterPanelCollapsed = false;
  int _currentView = 0; // 0: Dashboard, 1: Tabla, 2: Lista

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ColumnVisibilityProvider(),
      child: AccessibilityWrapper(
        screenName: 'Pantalla principal de CFDIs',
        child: Scaffold(
          body: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case CFDIInitial:
            return _buildInitialState(context);
          case CFDILoading:
            return _buildLoadingState();
          case CFDILoaded:
            return _buildLoadedState(state as CFDILoaded);
          case CFDIError:
            return _buildErrorState(state as CFDIError, context);
          default:
            return Container();
        }
      },
    );
  }

  Widget _buildInitialState(BuildContext context) {
    final theme = Theme.of(context);

    return AccessibilityWrapper(
      child: Center(
        child: MaxWidthContainer(
          maxWidth: 600,
          child: ModernCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: 'Icono de documentos CFDIs',
                  child: Icon(
                    Icons.description_outlined,
                    size: 80.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24.0),
                AccessibleText(
                  text: 'No hay CFDIs cargados',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  isHeader: true,
                  semanticLabel: 'Estado: No hay CFDIs cargados',
                ),
                const SizedBox(height: 8.0),
                AccessibleText(
                  text: 'Selecciona una opción para comenzar',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  semanticHint: 'Usa los botones a continuación para cargar archivos CFDIs',
                ),
                const SizedBox(height: 32.0),
                loadButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loadButtons(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AccessibleButton(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
            announceMessage('Cargando CFDIs desde directorio');
            provideFeedback(AccessibilityFeedback.selection);
          },
          semanticLabel: 'Cargar CFDIs desde directorio',
          semanticHint: 'Busca y carga todos los archivos XML de CFDIs desde una carpeta',
          tooltip: 'Selecciona una carpeta para cargar múltiples archivos CFDIs',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_open),
              const SizedBox(width: 8),
              const Text('Cargar desde directorio'),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        AccessibleButton(
          onPressed: () {
            context.read<CFDIBloc>().add(LoadCFDIsFromFile());
            announceMessage('Cargando archivo XML individual');
            provideFeedback(AccessibilityFeedback.selection);
          },
          semanticLabel: 'Cargar archivo XML individual',
          semanticHint: 'Selecciona un archivo XML específico para cargar',
          tooltip: 'Selecciona un archivo XML de CFDI individual',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.file_upload),
              const SizedBox(width: 8),
              const Text('Cargar archivo XML'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Builder(
      builder: (context) => Center(
        child: ModernCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AccessibleLoadingIndicator(
                loadingMessage: 'Cargando archivos CFDIs, por favor espera...',
              ),
              const SizedBox(height: 16),
              AccessibleText(
                text: 'Cargando CFDIs...',
                isLiveRegion: true,
                semanticLabel: 'Estado de carga: Procesando archivos CFDIs',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(CFDILoaded state) {
    final isMobile = AppLayout.isMobile(context);
    
    // Anunciar éxito de carga
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announceMessage('${state.cfdis.length} CFDIs cargados exitosamente');
    });
    
    if (isMobile) {
      // En móvil, navegación bottom tabs
      return Scaffold(
        body: _buildCurrentView(state),
        bottomNavigationBar: Semantics(
          label: 'Navegación principal',
          hint: 'Desliza para cambiar entre vistas',
          child: NavigationBar(
            selectedIndex: _currentView,
            onDestinationSelected: (index) {
              setState(() {
                _currentView = index;
              });
              _announceViewChange(index);
              provideFeedback(AccessibilityFeedback.selection);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard),
                label: 'Dashboard',
                tooltip: 'Ver estadísticas y métricas de CFDIs',
              ),
              NavigationDestination(
                icon: const Icon(Icons.view_list_outlined),
                selectedIcon: const Icon(Icons.view_list),
                label: 'Lista',
                tooltip: 'Ver lista detallada de CFDIs',
              ),
              NavigationDestination(
                icon: const Icon(Icons.filter_list_outlined),
                selectedIcon: const Icon(Icons.filter_list),
                label: 'Filtros',
                tooltip: 'Configurar filtros de búsqueda',
              ),
            ],
          ),
        ),
      );
    } else {
      // En desktop/tablet, sidebar con vista principal
      return Row(
        children: [
          // Panel de filtros colapsible
          Semantics(
            label: _isFilterPanelCollapsed ? 'Panel de filtros colapsado' : 'Panel de filtros expandido',
            hint: 'Usa el botón hamburguesa para alternar',
            child: CollapsibleFilterPanel(
              isCollapsed: _isFilterPanelCollapsed,
              onToggleCollapse: () {
                setState(() {
                  _isFilterPanelCollapsed = !_isFilterPanelCollapsed;
                });
                announceMessage(_isFilterPanelCollapsed ? 'Panel de filtros colapsado' : 'Panel de filtros expandido');
                provideFeedback(AccessibilityFeedback.selection);
              },
            ),
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra de navegación superior
                _buildDesktopNavBar(),
                // Vista actual
                Expanded(
                  child: Semantics(
                    label: 'Contenido principal',
                    child: _buildCurrentView(state),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildErrorState(CFDIError state, BuildContext context) {
    final theme = Theme.of(context);

    // Anunciar error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announceMessage('Error: ${state.message}');
      provideFeedback(AccessibilityFeedback.error);
    });

    return AccessibilityWrapper(
      child: Center(
        child: MaxWidthContainer(
          maxWidth: 600,
          child: ModernCard(
            child: AccessibleErrorWidget(
              errorMessage: 'Error al cargar CFDIs',
              errorDetails: state.message,
              onRetry: () {
                context.read<CFDIBloc>().add(LoadCFDIsFromDirectory());
                announceMessage('Reintentando cargar CFDIs');
                provideFeedback(AccessibilityFeedback.selection);
              },
              icon: Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentView(CFDILoaded state) {
    switch (_currentView) {
      case 0:
        return CFDIDashboard(cfdis: state.cfdis);
      case 1:
        return AdaptiveCFDIView(cfdis: state.cfdis);
      case 2:
        // En móvil, mostrar filtros en pantalla completa
        return CollapsibleFilterPanel(
          isCollapsed: false,
          onToggleCollapse: () {
            setState(() {
              _currentView = 0; // Volver al dashboard
            });
          },
        );
      default:
        return CFDIDashboard(cfdis: state.cfdis);
    }
  }

  Widget _buildDesktopNavBar() {
    final theme = Theme.of(context);
    
    return Semantics(
      label: 'Barra de navegación principal',
      hint: 'Selecciona una vista',
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Semantics(
              label: 'Selector de vista',
              hint: 'Cambia entre Dashboard y Tabla',
              child: SegmentedButton<int>(
                segments: [
                  ButtonSegment<int>(
                    value: 0,
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Dashboard'),
                    tooltip: 'Ver estadísticas y métricas generales',
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    icon: const Icon(Icons.table_view_outlined),
                    label: const Text('Tabla'),
                    tooltip: 'Ver tabla detallada de CFDIs',
                  ),
                ],
                selected: {_currentView},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _currentView = newSelection.first;
                  });
                  _announceViewChange(_currentView);
                  provideFeedback(AccessibilityFeedback.selection);
                },
              ),
            ),
            const Spacer(),
            // Información adicional
            BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
                if (state is CFDILoaded) {
                  return Semantics(
                    label: '${state.cfdis.length} CFDIs cargados',
                    hint: 'Número total de documentos fiscales',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.description,
                            size: 16,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${state.cfdis.length} CFDIs',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  /// Anunciar cambio de vista para accesibilidad
  void _announceViewChange(int index) {
    final viewNames = ['Dashboard', 'Lista de CFDIs', 'Filtros'];
    if (index < viewNames.length) {
      announceMessage('Navegaste a ${viewNames[index]}');
    }
  }
}
