import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/filter.dart';

class TipoComprobante extends FilterOption {
  bool seleccionado = false;

  TipoComprobante(String id, String nombre) : super(id, nombre);
}

final List<TipoComprobante> tiposDeComprobante = [
  TipoComprobante('I', 'Ingreso'),
  TipoComprobante('E', 'Egreso'),
  TipoComprobante('T', 'Traslado'),
  TipoComprobante('P', 'Pago'),
];

class TipoComprobanteFilter implements FilterStrategy {
  final Set<FilterOption> filter;

  TipoComprobanteFilter(this.filter);

  @override
  List<CFDI> apply(List<CFDI> cfdis) {
    // Si no hay ningun tipo de comprobante seleccionado, no se aplica el filtro
    // y se devuelven todos los CFDIs
    if (!isActive()) {
      return cfdis;
    }

    //get all the active filters of TipoComprobante
    final tiposDeComprobante = filter.whereType<TipoComprobante>().toList();

    //Filter the cfdis
    return cfdis.where((cfdi) {
      return cfdi.tipoDeComprobante != null &&
          tiposDeComprobante.any((tipo) => tipo.id == cfdi.tipoDeComprobante);
    }).toList();
  }

  @override
  bool isActive() {
    //Check if filter has at the lest one tiposDeComprobante element
    return filter.any((element) => element is TipoComprobante);
  }
}
