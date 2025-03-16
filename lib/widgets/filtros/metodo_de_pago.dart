import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
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
  @override
  Widget build(BuildContext context) {
    //Lista de checkbox para seleccionar el método de pago
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de pago',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        //Lista de checkbox para seleccionar el método de pago
        _buildMetodosDePago(),
      ],
    );
  }

  //Lista de checkbox para seleccionar el método de pago
  Widget _buildMetodosDePago() {
    return Column(
      children: metodosDePago.map((metodoPago) {
        return CheckboxListTile(
          title: Text(
            metodoPago.nombre,
            style: const TextStyle(color: Colors.white),
          ),
          value: metodoPago.seleccionado,
          onChanged: (value) {
            if (value == null) return;
            //Apply filter to the list of CFDis
            context.read<CFDIBloc>().add(FilterCFDIs(metodoPago));
            setState(() {
              metodoPago.seleccionado = value;
            });
          },
        );
      }).toList(),
    );
  }
}
