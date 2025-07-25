import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/filter_uso_de_cfdi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FiltroUsoDeCFDI extends StatefulWidget {
  const FiltroUsoDeCFDI({super.key});

  @override
  State<FiltroUsoDeCFDI> createState() => _FiltroUsoDeCFDIState();
}

class _FiltroUsoDeCFDIState extends State<FiltroUsoDeCFDI> {
  // Usos de CFDI del SAT
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
                  hintText: 'Buscar uso de CFDI',
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
            //Lista de checkbox para seleccionar el uso de CFDI
            if (state is CFDILoaded) _buildUsosDeCFDI(state),
          ],
        );
      },
    );
  }

  //Lista de checkbox para seleccionar el uso de CFDI
  Widget _buildUsosDeCFDI(CFDILoaded state) {
    final theme = Theme.of(context);
    final filteredUsos = usosDeCFDI
        .where(
          (uso) =>
              uso.nombre.toLowerCase().contains(_searchQuery) ||
              uso.id.toLowerCase().contains(_searchQuery),
        )
        .toList();

    if (filteredUsos.isEmpty) {
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
      children: filteredUsos.map((usoCFDI) {
        final bool isSelected = state.activeFilters.any(
          (filter) => filter is UsoDeCFDI && filter.id == usoCFDI.id,
        );
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
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    usoCFDI.id,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    usoCFDI.nombre,
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
              context.read<CFDIBloc>().add(FilterCFDIs(usoCFDI));
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }
}
