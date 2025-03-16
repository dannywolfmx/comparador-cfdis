import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/models/filter_forma_pago.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FiltroFormaPago extends StatefulWidget {
  const FiltroFormaPago({super.key});

  @override
  State<FiltroFormaPago> createState() => _FiltroFormaPagoState();
}

class _FiltroFormaPagoState extends State<FiltroFormaPago> {
// Formas de pago del SAT
  @override
  Widget build(BuildContext context) {
    //Lista de checkbox para seleccionar la forma de pago
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Forma de pago',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        //Lista de checkbox para seleccionar la forma de pago
        _buildFormasDePago(),
      ],
    );
  }

  //Lista de checkbox para seleccionar la forma de pago
  Widget _buildFormasDePago() {
    return Column(
      children: formasDePago.map((formaPago) {
        return CheckboxListTile(
          title: Text(
            formaPago.nombre,
            style: const TextStyle(color: Colors.white),
          ),
          value: formaPago.seleccionado,
          onChanged: (value) {
            if (value == null) return;
            //Apply filter to the list of CFDis
            context.read<CFDIBloc>().add(FilterCFDIs(formaPago));
            setState(() {
              formaPago.seleccionado = value;
            });
          },
        );
      }).toList(),
    );
  }
}
