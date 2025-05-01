import 'package:comparador_cfdis/models/cfdi_information.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../models/cfdi.dart';

// Clase abstracta para los estados de la carga de CFDIs
abstract class CFDIState {}

// Estados de la carga de CFDIs
// En este estado los CFDIs no han sido cargados
class CFDIInitial extends CFDIState {}

// En este estado los CFDIs están siendo cargados
class CFDILoading extends CFDIState {}

// En este estado los CFDIs han sido cargados
// En este estado ya se puede consumir la lista de CFDIs
class CFDILoaded extends CFDIState {
  final List<CFDI> cfdis;
  int count = 0;
  CFDIInformation cfdiInformation;
  PlutoGridStateManager? stateManager;
  CFDILoaded(this.cfdis, this.cfdiInformation, {this.stateManager}) {
    count = cfdis.length;
    if (stateManager != null) {
      stateManager!.removeRows(stateManager!.rows);
      List<PlutoRow> rows = cfdis.map((cfdi) => _row(cfdi)).toList();
      stateManager?.appendRows(rows);
    }
  }

  PlutoRow _row(CFDI cfdi) {
    return PlutoRow(cells: {
      'uuid': PlutoCell(value: cfdi.timbreFiscalDigital?.uuid),
      'rfcEmisor': PlutoCell(value: cfdi.emisor?.nombre),
      'rfcReceptor': PlutoCell(value: cfdi.receptor?.nombre),
      'fecha': PlutoCell(value: cfdi.fecha),
      'total': PlutoCell(value: cfdi.total),
      'acciones': PlutoCell(value: ''),
    });
  }
}

// En este estado hay un error al cargar los CFDIs
class CFDIError extends CFDIState {
  final String message;

  CFDIError(this.message);
}
