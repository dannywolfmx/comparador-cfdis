import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/filter_metodo_pago.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FiltroMetodoDePago extends StatefulWidget {
  const FiltroMetodoDePago({super.key});

  @override
  State<FiltroMetodoDePago> createState() => _FiltroMetodoDePagoState();
}

class _FiltroMetodoDePagoState extends State<FiltroMetodoDePago> {
  // Métodos de pago del SAT
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar método de pago',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
            //Lista de checkbox para seleccionar el método de pago
            _buildMetodosDePago(),
          ],
        );
      },
    );
  }

  //Lista de checkbox para seleccionar el método de pago
  Widget _buildMetodosDePago() {
    final filteredMetodos = metodosDePago
        .where((metodo) =>
            metodo.nombre.toLowerCase().contains(_searchQuery) ||
            metodo.id.toLowerCase().contains(_searchQuery))
        .toList();

    if (filteredMetodos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No se encontraron resultados',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
        ),
      );
    }

    return Column(
      children: filteredMetodos.map((metodoPago) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          color: Colors.white.withValues(alpha: 0.05),
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
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    metodoPago.id,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    metodoPago.nombre,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            value: metodoPago.seleccionado,
            activeColor: Colors.white,
            checkColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              if (value == null) return;
              //Apply filter to the list of CFDIs
              context.read<CFDIBloc>().add(FilterCFDIs(metodoPago));
              // No se actualiza el estado aquí, se deja que el BLoC lo maneje
            },
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }
}
