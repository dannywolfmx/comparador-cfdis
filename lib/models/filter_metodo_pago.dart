import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/filter.dart';

class MetodoPago extends FilterOption {
  bool seleccionado = false;
  MetodoPago(String id, String nombre) : super(id, nombre);
}

final List<MetodoPago> metodosDePago = [
  MetodoPago('PUE', 'Pago en una sola exhibición'),
  MetodoPago('PPD', 'Pago en parcialidades o diferido'),
];

class MetodoDePagoFilter implements FilterStrategy {
  final Set<FilterOption> filter;

  MetodoDePagoFilter(this.filter);

  @override
  List<CFDI> apply(List<CFDI> cfdis) {
    // Si no hay ninguna forma de pago seleccionada, no se aplica el filtro
    // y se devuelven todos los CFDIs
    if (!isActive()) {
      return cfdis;
    }

    //get all the active filters of FormaPago
    final metodosDePago = filter.whereType<MetodoPago>().toList();

    //Filter the cfdis
    return cfdis.where((cfdi) {
      return cfdi.metodoPago != null &&
          metodosDePago.any((metodo) => metodo.id == cfdi.metodoPago);
    }).toList();
  }

  @override
  bool isActive() {
    //Check if filter has at the lest one formasDePago element
    return filter.any((element) => element is MetodoPago);
  }
}
