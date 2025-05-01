import '../models/cfdi.dart';
import '../services/cfdi_parser.dart';

class CFDIRepository {
  List<CFDI> _cfdis = [];

  Future<List<CFDI>> loadCFDIsFromDirectory() async {
    return await CFDIParser.parseDirectoryCFDIs();
  }

  Future<List<CFDI>> loadCFDIFromFile() async {
    return await CFDIParser.pickAndParseXmls();
  }

  List<CFDI> get cfdis => _cfdis;

  //Filter CFDIs
  List<CFDI> filterCFDIs(String query) {
    final filteredCFDIs = _cfdis.where((cfdi) {
      final cfdiUuid = cfdi.timbreFiscalDigital?.uuid ?? '';
      return cfdiUuid.toUpperCase().contains(query.toUpperCase());
    }).toList();
    return filteredCFDIs;
  }

  void clearCFDIs() {
    _cfdis = [];
  }
}
