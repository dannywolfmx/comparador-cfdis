import 'package:comparador_cfdis/bloc/cfdi_bloc.dart';
import 'package:comparador_cfdis/bloc/cfdi_state.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/screens/cfdi_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
      configuration: const PlutoGridConfiguration(
          localeText: PlutoGridLocaleText.spanish(),
          columnSize: PlutoGridColumnSizeConfig(
            autoSizeMode: PlutoAutoSizeMode.scale,
          )),
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
        enableRowChecked: true,
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
      PlutoColumn(
        title: 'Acciones',
        field: 'acciones',
        type: PlutoColumnType.text(),
        width: 120,
        readOnly: true,
        renderer: (rendererContext) {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                // Obtenemos el UUID de la fila actual
                final uuid = rendererContext.row.cells['uuid']?.value;

                // Buscamos el CFDI correspondiente en la lista
                final cfdi = widget.cfdis.firstWhere(
                  (cfdi) => cfdi.timbreFiscalDigital?.uuid == uuid,
                  orElse: () => widget.cfdis.first,
                );

                // Mostramos los detalles del CFDI
                _mostrarDetalles(cfdi, context);
              },
              child: const Text('Detalles'),
            ),
          );
        },
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
      'acciones':
          PlutoCell(value: ''), // Esta celda se renderizará con el botón
    });
  }

  void _mostrarDetalles(CFDI cfdi, BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, animation, secondaryAnimation) {
          // Pass the complete list of CFDIs along with the selected CFDI
          return BlocProvider.value(
            value: BlocProvider.of<CFDIBloc>(context),
            child: CFDIDetailScreen(
              cfdi: cfdi,
            ),
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation =
              CurvedAnimation(parent: animation, curve: Curves.ease);
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        },
      ),
    );
  }
}
