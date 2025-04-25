import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:provider/provider.dart';

class TableCFDI extends StatefulWidget {
  const TableCFDI({super.key, required this.cfdis});

  final List<CFDI> cfdis;

  @override
  State<TableCFDI> createState() => _TableCFDIState();
}

class _TableCFDIState extends State<TableCFDI> {
  late PlutoGridStateManager stateManager;

  bool showColumn = true;
  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: _columns(),
      rows: widget.cfdis.map((cfdi) => _row(cfdi)).toList(),
      configuration: const PlutoGridConfiguration(),
      onLoaded: (event) {
        stateManager = event.stateManager;
        stateManager.setShowColumnFilter(showColumn);
        final state = context.read<CFDIBloc>().state;
        if (state is CFDILoaded) {
          state.stateManager = stateManager;
        }
      },
      onChanged: (event) {},
    );
  }

  List<PlutoColumn> _columns() {
    return [
      PlutoColumn(
        title: 'RFC Emisor',
        field: 'rfcEmisor',
        type: PlutoColumnType.text(),
        width: 150,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'RFC Receptor',
        field: 'rfcReceptor',
        type: PlutoColumnType.text(),
        width: 150,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Fecha',
        field: 'fecha',
        type: PlutoColumnType.date(),
        width: 150,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'Total',
        field: 'total',
        type: PlutoColumnType.number(),
        width: 100,
        readOnly: true,
      ),
      PlutoColumn(
        title: 'UUID',
        field: 'uuid',
        type: PlutoColumnType.text(),
        width: 200,
        readOnly: true,
      ),
    ];
  }

  PlutoRow _row(CFDI cfdi) {
    return PlutoRow(cells: {
      'uuid': PlutoCell(value: cfdi.timbreFiscalDigital?.uuid),
      'rfcEmisor': PlutoCell(value: cfdi.emisor?.nombre),
      'rfcReceptor': PlutoCell(value: cfdi.receptor?.nombre),
      'fecha': PlutoCell(value: cfdi.fecha),
      'total': PlutoCell(value: cfdi.total),
    });
  }
}
