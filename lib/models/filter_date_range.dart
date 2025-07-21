
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/filter.dart';

class DateRangeFilter implements FilterStrategy {
  final DateTime? startDate;
  final DateTime? endDate;

  DateRangeFilter({this.startDate, this.endDate});

  @override
  List<CFDI> apply(List<CFDI> cfdis) {
    if (startDate == null && endDate == null) {
      return cfdis;
    }

    return cfdis.where((cfdi) {
      if (cfdi.fecha == null) {
        return false;
      }
      try {
        final cfdiDate = DateTime.parse(cfdi.fecha!);
        if (startDate != null && cfdiDate.isBefore(startDate!)) {
          return false;
        }
        if (endDate != null && cfdiDate.isAfter(endDate!)) {
          return false;
        }
        return true;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  @override
  bool isActive() {
    return startDate != null || endDate != null;
  }
}
