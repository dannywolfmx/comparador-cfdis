import 'package:flutter/material.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/widgets/cfdi_list.dart';
import 'package:comparador_cfdis/widgets/table_cfdi.dart';
import 'package:comparador_cfdis/theme/app_dimensions.dart';

class AdaptiveCFDIView extends StatefulWidget {
  final List<CFDI> cfdis;
  
  const AdaptiveCFDIView({
    super.key,
    required this.cfdis,
  });

  @override
  State<AdaptiveCFDIView> createState() => _AdaptiveCFDIViewState();
}

class _AdaptiveCFDIViewState extends State<AdaptiveCFDIView> {
  bool _forceListView = false;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AppLayout.isMobile(context);
        final isTablet = AppLayout.isTablet(context);
        final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
        
        // Determinar vista basado en tamaño y orientación
        final shouldUseListView = isMobile && !isLandscape || _forceListView;
        
        return Column(
          children: [
            // Barra de controles superior
            if (!isMobile) _buildControlBar(context, constraints),
            
            // Vista principal
            Expanded(
              child: shouldUseListView
                ? CFDIListView(cfdis: widget.cfdis)
                : _buildTableView(context, constraints, isTablet),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlBar(BuildContext context, BoxConstraints constraints) {
    final theme = Theme.of(context);
    
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Información de registros
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_rows,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.cfdis.length} registros',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Controles de vista
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: false,
                icon: Icon(Icons.table_view_outlined, size: 16),
                label: Text('Tabla', style: TextStyle(fontSize: 12)),
              ),
              ButtonSegment<bool>(
                value: true,
                icon: Icon(Icons.view_list_outlined, size: 16),
                label: Text('Lista', style: TextStyle(fontSize: 12)),
              ),
            ],
            selected: {_forceListView},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _forceListView = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(BuildContext context, BoxConstraints constraints, bool isTablet) {
    // Ajustar la tabla según el espacio disponible
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TableCFDI(cfdis: widget.cfdis),
    );
  }
}
