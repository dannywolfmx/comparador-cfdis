import 'package:comparador_cfdis/models/cfdi_information.dart';
import 'package:comparador_cfdis/models/filter.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../models/cfdi.dart';

abstract class CFDIState {}

class CFDIInitial extends CFDIState {}

class CFDILoading extends CFDIState {}

class CFDILoaded extends CFDIState {
  final List<CFDI> cfdis;
  final CFDIInformation cfdiInformation;
  final Set<FilterOption> activeFilters;
  final PlutoGridStateManager? stateManager;

  CFDILoaded(
    this.cfdis,
    this.cfdiInformation,
    this.activeFilters, {
    this.stateManager,
  }) {
    if (stateManager != null) {
      stateManager!.removeRows(stateManager!.rows);
      final List<PlutoRow> rows = cfdis.map((cfdi) => _row(cfdi)).toList();
      stateManager?.appendRows(rows);
    }
  }

  PlutoRow _row(CFDI cfdi) {
    return PlutoRow(
      cells: {
        'uuid': PlutoCell(value: cfdi.timbreFiscalDigital?.uuid),
        'rfcEmisor': PlutoCell(value: cfdi.emisor?.nombre),
        'rfcReceptor': PlutoCell(value: cfdi.receptor?.nombre),
        'fecha': PlutoCell(value: cfdi.fecha),
        'total': PlutoCell(value: cfdi.total),
        'acciones': PlutoCell(value: ''),
      },
    );
  }
}

class CFDIError extends CFDIState {
  final String message;

  CFDIError(this.message);
}
