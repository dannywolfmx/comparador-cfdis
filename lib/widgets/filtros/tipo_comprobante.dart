import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
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
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar tipo de comprobante',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        _buildTiposDeComprobante(),
      ],
    );
  }

  Widget _buildTiposDeComprobante() {
    final filteredTipos = tiposDeComprobante
        .where((tipo) => tipo.nombre.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredTipos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No se encontraron resultados',
            style: TextStyle(color: Colors.white.withOpacity(0.7)),
          ),
        ),
      );
    }

    return Column(
      children: filteredTipos.map((tipoComprobante) {
        // Obtener color según el tipo de comprobante
        Color tipoColor = _getColorForTipoComprobante(tipoComprobante.id);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: Colors.white.withOpacity(0.05),
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
                    color: tipoColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: tipoColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    _getShortTipoComprobante(tipoComprobante.id),
                    style: TextStyle(
                        color: tipoColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tipoComprobante.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            value: tipoComprobante.seleccionado,
            activeColor: Colors.white,
            checkColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                tipoComprobante.seleccionado = value;
              });
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
  Color _getColorForTipoComprobante(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'I':
        return Colors.green;
      case 'E':
        return Colors.red;
      case 'T':
        return Colors.blue;
      case 'N':
        return Colors.purple;
      case 'P':
        return Colors.orange;
      default:
        return Colors.grey;
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
