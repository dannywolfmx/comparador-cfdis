import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FiltroTipoComprobante extends StatefulWidget {
  const FiltroTipoComprobante({super.key});

  @override
  State<FiltroTipoComprobante> createState() => _FiltroTipoComprobanteState();
}

class _FiltroTipoComprobanteState extends State<FiltroTipoComprobante> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CFDIBloc, CFDIState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar tipo de comprobante',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            if (state is CFDILoaded) _buildTiposDeComprobante(state),
          ],
        );
      },
    );
  }

  Widget _buildTiposDeComprobante(CFDILoaded state) {
    final theme = Theme.of(context);
    final filteredTipos = tiposDeComprobante
        .where((tipo) => tipo.nombre.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredTipos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No se encontraron resultados',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Column(
      children: filteredTipos.map((tipoComprobante) {
        final bool isSelected = state.activeFilters.any(
          (filter) =>
              filter is TipoComprobante && filter.id == tipoComprobante.id,
        );
        // Obtener color según el tipo de comprobante
        final Color tipoColor =
            _getColorForTipoComprobante(context, tipoComprobante.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: CheckboxListTile(
            title: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tipoColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tipoColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _getShortTipoComprobante(tipoComprobante.id),
                    style: TextStyle(
                      color: tipoColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tipoComprobante.nombre,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                ),
              ],
            ),
            value: isSelected,
            activeColor: theme.colorScheme.primary,
            checkColor: theme.colorScheme.onPrimary,
            onChanged: (value) {
              if (value == null) return;
              context.read<CFDIBloc>().add(FilterCFDIs(tipoComprobante));
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }

  // Helper methods para colores y etiquetas de tipos de comprobante
  Color _getColorForTipoComprobante(BuildContext context, String tipo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (tipo.toUpperCase()) {
      case 'I':
        return isDark ? Colors.green.shade300 : Colors.green.shade700;
      case 'E':
        return isDark ? Colors.red.shade300 : Colors.red.shade700;
      case 'T':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade700;
      case 'N':
        return isDark ? Colors.purple.shade300 : Colors.purple.shade700;
      case 'P':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      default:
        return isDark ? Colors.grey.shade300 : Colors.grey.shade700;
    }
  }

  String _getShortTipoComprobante(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'I':
        return 'I';
      case 'E':
        return 'E';
      case 'T':
        return 'T';
      case 'N':
        return 'N';
      case 'P':
        return 'P';
      default:
        return tipo;
    }
  }
}
