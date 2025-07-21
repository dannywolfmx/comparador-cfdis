import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/filter.dart';

class UsoDeCFDI extends FilterOption {
  bool seleccionado = false;

  UsoDeCFDI(String id, String nombre) : super(id, nombre);
}

final List<UsoDeCFDI> usosDeCFDI = [
  UsoDeCFDI('G01', 'Adquisición de mercancias'),
  UsoDeCFDI('G02', 'Devoluciones, descuentos o bonificaciones'),
  UsoDeCFDI('G03', 'Gastos en general'),
  UsoDeCFDI('I01', 'Construcciones'),
  UsoDeCFDI('I02', 'Mobilario y equipo de oficina por inversiones'),
  UsoDeCFDI('I03', 'Equipo de transporte'),
  UsoDeCFDI('I04', 'Equipo de computo y accesorios'),
  UsoDeCFDI('I05', 'Dados, troqueles, moldes, matrices y herramental'),
  UsoDeCFDI('I06', 'Comunicaciones telefónicas'),
  UsoDeCFDI('I07', 'Comunicaciones satelitales'),
  UsoDeCFDI('I08', 'Otra maquinaria y equipo'),
  UsoDeCFDI('D01', 'Honorarios médicos, dentales y gastos hospitalarios'),
  UsoDeCFDI('D02', 'Gastos médicos por incapacidad o discapacidad'),
  UsoDeCFDI('D03', 'Gastos funerales'),
  UsoDeCFDI('D04', 'Donativos'),
  UsoDeCFDI(
    'D05',
    'Intereses reales efectivamente pagados por créditos hipotecarios (casa habitación)',
  ),
  UsoDeCFDI('D06', 'Aportaciones voluntarias al SAR'),
  UsoDeCFDI('D07', 'Primas por seguros de gastos médicos'),
  UsoDeCFDI('D08', 'Gastos de transportación escolar obligatoria'),
  UsoDeCFDI(
    'D09',
    'Depósitos en cuentas para el ahorro, primas que tengan como base planes de pensiones',
  ),
  UsoDeCFDI('D10', 'Pagos por servicios educativos (colegiaturas)'),
  UsoDeCFDI('P01', 'Por definir'),
  UsoDeCFDI('S01', 'Sin efectos fiscales'),
];

class UsoDeCFDIFilter implements FilterStrategy {
  final Set<FilterOption> filter;

  UsoDeCFDIFilter(this.filter);

  @override
  List<CFDI> apply(List<CFDI> cfdis) {
    // Si no hay ninguna uso de cfdi seleccionado, no se aplica el filtro
    // y se devuelven todos los CFDIs
    if (!isActive()) {
      return cfdis;
    }

    //get all the active filters of UsoDeCFDI
    final usosDeCFDI = filter.whereType<UsoDeCFDI>().toList();

    //Filter the cfdis
    return cfdis.where((cfdi) {
      return cfdi.receptor?.usoCFDI != null &&
          usosDeCFDI.any((uso) => uso.id == cfdi.receptor?.usoCFDI);
    }).toList();
  }

  @override
  bool isActive() {
    //Check if filter has at the lest one usosDeCFDI element
    return filter.any((element) => element is UsoDeCFDI);
  }
}
