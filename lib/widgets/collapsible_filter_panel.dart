import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/widgets/filtros/date_range.dart';
import 'package:comparador_cfdis/widgets/filtros/forma_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/metodo_de_pago.dart';
import 'package:comparador_cfdis/widgets/filtros/tipo_comprobante.dart';
import 'package:comparador_cfdis/widgets/filtros/uso_de_cfdi.dart';
import 'package:comparador_cfdis/widgets/filter_template_panel.dart';
import 'package:comparador_cfdis/widgets/global_search_widget.dart';
import 'package:comparador_cfdis/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollapsibleFilterPanel extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  
  const CollapsibleFilterPanel({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<CollapsibleFilterPanel> createState() => _CollapsibleFilterPanelState();
}

class _CollapsibleFilterPanelState extends State<CollapsibleFilterPanel>
    with TickerProviderStateMixin {
  bool _expandedFormaPago = false;
  bool _expandedMetodoPago = false;
  bool _expandedUsoCFDI = false;
  bool _expandedTipoComprobante = false;
  bool _expandedDateRange = false;
  
  late AnimationController _collapseController;
  
  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    
    if (!widget.isCollapsed) {
      _collapseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CollapsibleFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _collapseController.reverse();
      } else {
        _collapseController.forward();
      }
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = AppLayout.isMobile(context);
    
    return Container(
      width: widget.isCollapsed ? 56 : (isMobile ? double.infinity : 320),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surfaceContainerHighest,
            theme.colorScheme.surfaceContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(context, theme),
          if (!widget.isCollapsed) ...[
            const Divider(height: 1),
            Expanded(child: _buildContent(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!widget.isCollapsed) ...[
            Text(
              'Filtros',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            BlocBuilder<CFDIBloc, CFDIState>(
              builder: (context, state) {
                if (state is! CFDILoaded) {
                  return const SizedBox.shrink();
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      tooltip: 'Limpiar filtros',
                      onPressed: () {
                        context.read<CFDIBloc>().add(ClearFilters());
                        _resetExpandedStates();
                      },
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          IconButton(
            icon: Icon(
              widget.isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              size: 24,
            ),
            tooltip: widget.isCollapsed ? 'Expandir filtros' : 'Colapsar filtros',
            onPressed: widget.onToggleCollapse,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Búsqueda global
              const SizedBox(height: 8),
              const GlobalSearchWidget(),
              
              const SizedBox(height: 12),

              // Panel de plantillas de filtros
              const FilterTemplatePanel(),

              const SizedBox(height: 12),

              // Filtros expandibles
              _buildExpandableFilter(
                title: 'Rango de Fechas',
                icon: Icons.date_range,
                expanded: _expandedDateRange,
                onTap: () => setState(() {
                  _expandedDateRange = !_expandedDateRange;
                }),
                child: const FiltroDateRange(),
              ),

              _buildExpandableFilter(
                title: 'Forma de pago',
                icon: Icons.payment,
                expanded: _expandedFormaPago,
                onTap: () => setState(() {
                  _expandedFormaPago = !_expandedFormaPago;
                }),
                child: const FiltroFormaPago(),
              ),

              _buildExpandableFilter(
                title: 'Método de pago',
                icon: Icons.account_balance_wallet,
                expanded: _expandedMetodoPago,
                onTap: () => setState(() {
                  _expandedMetodoPago = !_expandedMetodoPago;
                }),
                child: const FiltroMetodoDePago(),
              ),

              _buildExpandableFilter(
                title: 'Uso de CFDI',
                icon: Icons.description,
                expanded: _expandedUsoCFDI,
                onTap: () => setState(() {
                  _expandedUsoCFDI = !_expandedUsoCFDI;
                }),
                child: const FiltroUsoDeCFDI(),
              ),

              _buildExpandableFilter(
                title: 'Tipo de comprobante',
                icon: Icons.receipt,
                expanded: _expandedTipoComprobante,
                onTap: () => setState(() {
                  _expandedTipoComprobante = !_expandedTipoComprobante;
                }),
                child: const FiltroTipoComprobante(),
              ),

              // Contador de CFDIs al final
              const SizedBox(height: 16),
              _buildCFDICounter(context),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandableFilter({
    required String title,
    required IconData icon,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: AppAnimations.fast,
                      child: Icon(
                        Icons.expand_more,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: AppAnimations.fast,
            curve: Curves.easeInOut,
            child: expanded
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCFDICounter(BuildContext context) {
    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        if (state is! CFDILoaded) {
          return const SizedBox.shrink();
        }
        
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article,
                color: theme.colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '${state.cfdis.length} CFDIs',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetExpandedStates() {
    setState(() {
      _expandedFormaPago = false;
      _expandedMetodoPago = false;
      _expandedUsoCFDI = false;
      _expandedTipoComprobante = false;
      _expandedDateRange = false;
    });
  }
}
