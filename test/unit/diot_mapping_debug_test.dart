import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT Mapping Debug Tests', () {
    test('Debug output for DIOT mapping service', () {
      print('=== TEST: Debug output del servicio de mapeo DIOT ===');

      final cfdiData = {
        'SubTotal': '1000.00',
        'Emisor': {'Rfc': 'DEBUG123456789'},
        'Impuestos': {'TotalImpuestosTrasladados': '160.00'},
      };

      final cfdi = CFDI.fromJson(cfdiData);

      const configuration = DIOTConfiguration(
        year: 2025,
        month: 1,
        ejercicio: 2025,
        periodo: 1,
        rfcContribuyente: 'XAXX010101000',
        tipoComplemento: TipoComplemento.normal,
        filterCriteria: DIOTFilterCriteria(),
        userPreferences: DIOTUserPreferences(),
      );

      final records =
          DIOTMappingService.mapCFDIsToRecords([cfdi], configuration);

      expect(records.length, 1);
      final record = records.first;

      print('Debug output - Record creado:');
      print('  RFC: ${record.rfc}');
      print('  Valor Actos 16%: \$${record.valorActos16Porciento}');
      print('  IVA Acreditable 16%: \$${record.ivaAcreditableExclusivo16}');

      expect(record.rfc, 'DEBUG123456789');
      expect(record.valorActos16Porciento, 1000.0);
      expect(record.ivaAcreditableExclusivo16, 160.0);

      print('✅ SUCCESS: Debug mapping completado');
    });
  });
}
