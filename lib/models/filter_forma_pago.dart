import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/filter.dart';

class FormaPago extends FilterOption {
  bool seleccionado = false;

  FormaPago(String id, String nombre) : super(id, nombre);
}

final List<FormaPago> formasDePago = [
  FormaPago('01', 'Efectivo'),
  FormaPago('02', 'Cheque nominativo'),
  FormaPago('03', 'Transferencia electrónica de fondos'),
  FormaPago('04', 'Tarjeta de crédito'),
  FormaPago('05', 'Monedero electrónico'),
  FormaPago('06', 'Dinero electrónico'),
  FormaPago('08', 'Vales de despensa'),
  FormaPago('12', 'Dación en pago'),
  FormaPago('13', 'Pago por subrogación'),
  FormaPago('14', 'Pago por consignación'),
  FormaPago('15', 'Condonación'),
  FormaPago('17', 'Compensación'),
  FormaPago('23', 'Novación'),
  FormaPago('24', 'Confusión'),
  FormaPago('25', 'Remisión de deuda'),
  FormaPago('26', 'Prescripción o caducidad'),
  FormaPago('27', 'A satisfacción del acreedor'),
  FormaPago('28', 'Tarjeta de débito'),
  FormaPago('29', 'Tarjeta de servicios'),
  FormaPago('30', 'Aplicación de anticipos'),
  FormaPago('31', 'Intermediario pagos'),
  FormaPago('99', 'Por definir'),
];

class FormaDePagoFilter implements FilterStrategy {
  final Set<FilterOption> filter;

  FormaDePagoFilter(this.filter);

  @override
  List<CFDI> apply(List<CFDI> cfdis) {
    // Si no hay ninguna forma de pago seleccionada, no se aplica el filtro
    // y se devuelven todos los CFDIs
    if (!isActive()) {
      return cfdis;
    }

    //get all the active filters of FormaPago
    final formasDePago = filter.whereType<FormaPago>().toList();

    //Filter the cfdis
    return cfdis.where((cfdi) {
      return cfdi.formaPago != null &&
          formasDePago.any((forma) => forma.id == cfdi.formaPago);
    }).toList();
  }

  @override
  bool isActive() {
    //Check if filter has at the lest one formasDePago element
    return filter.any((element) => element is FormaPago);
  }
}
