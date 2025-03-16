import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/forma_pago.dart';

abstract class FilterOption {
  final String id;
  final String nombre;

  FilterOption(this.id, this.nombre);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

abstract class FilterStrategy {
  List<CFDI> apply(List<CFDI> cfdis);
  bool isActive();
}

//Cadena de filtros
class FilterChain {
  final List<FilterStrategy> filters = [];

  FilterChain();

  //Agregar un filtro a la cadena
  void add(FilterStrategy filter) {
    filters.add(filter);
  }

  //Aplicar todos los filtros de la cadena
  List<CFDI> apply(List<CFDI> cfdis) {
    var filteredCFDIs = cfdis;
    for (var filter in filters) {
      filteredCFDIs = filter.apply(filteredCFDIs);
    }
    return filteredCFDIs;
  }
}

//FilterFactory
class FilterFactory {
  FilterChain chains = FilterChain();

  FilterFactory(Set<FilterOption> filters) {
    //Crear una cadena de filtros para cada combinación de filtros
    chains.add(FormaDePagoFilter(filters));
  }

  List<CFDI> apply(List<CFDI> cfdis) {
    return chains.apply(cfdis);
  }
}
