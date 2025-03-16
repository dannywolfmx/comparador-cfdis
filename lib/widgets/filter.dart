import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/widgets/filtros/forma_de_pago.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterColumn extends StatelessWidget {
  const FilterColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          // Filtro por forma de pago
          BlocBuilder<CFDIBloc, CFDIState>(builder: (context, state) {
            return const FiltroFormaPago();
          }),

          // Contador de CFDIs
          BlocBuilder<CFDIBloc, CFDIState>(
            builder: (context, state) {
              if (state is! CFDILoaded) {
                return const SizedBox.shrink();
              }
              return Text(
                'Total de CFDIs: ${state.total}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              );
            },
          ),
          // Botón para limpiar los filtros
        ],
      ),
    );
  }
}
