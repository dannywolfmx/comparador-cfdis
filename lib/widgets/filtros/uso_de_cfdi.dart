import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
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
  @override
  Widget build(BuildContext context) {
    //Lista de checkbox para seleccionar el uso de CFDI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uso de CFDI',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        //Lista de checkbox para seleccionar el uso de CFDI
        _buildUsosDeCFDI(),
      ],
    );
  }

  //Lista de checkbox para seleccionar el uso de CFDI
  Widget _buildUsosDeCFDI() {
    return Column(
      children: usosDeCFDI.map((usoCFDI) {
        return CheckboxListTile(
          title: Text(
            usoCFDI.nombre,
            style: const TextStyle(color: Colors.white),
          ),
          value: usoCFDI.seleccionado,
          onChanged: (value) {
            if (value == null) return;
            //Apply filter to the list of CFDis
            context.read<CFDIBloc>().add(FilterCFDIs(usoCFDI));
            setState(() {
              usoCFDI.seleccionado = value;
            });
          },
        );
      }).toList(),
    );
  }
}
