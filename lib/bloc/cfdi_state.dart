import 'package:comparador_cfdis/models/cfdi_information.dart';

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
  CFDILoaded(this.cfdis, this.cfdiInformation) {
    count = cfdis.length;
  }
}

// En este estado hay un error al cargar los CFDIs
class CFDIError extends CFDIState {
  final String message;

  CFDIError(this.message);
}
