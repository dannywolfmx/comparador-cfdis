import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_event.dart';
import 'package:comparador_cfdis/models/filter_tipo_comprobante.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FiltroTipoComprobante extends StatefulWidget {
  const FiltroTipoComprobante({super.key});

  @override
  State<FiltroTipoComprobante> createState() => _FiltroTipoComprobanteState();
}

class _FiltroTipoComprobanteState extends State<FiltroTipoComprobante> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de comprobante',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        _buildTiposDeComprobante(),
      ],
    );
  }

  Widget _buildTiposDeComprobante() {
    return Column(
      children: tiposDeComprobante.map((tipoComprobante) {
        return CheckboxListTile(
          title: Text(
            tipoComprobante.nombre,
            style: const TextStyle(color: Colors.white),
          ),
          value: tipoComprobante.seleccionado,
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              tipoComprobante.seleccionado = value;
            });
            context.read<CFDIBloc>().add(FilterCFDIs(tipoComprobante));
          },
        );
      }).toList(),
    );
  }
}
