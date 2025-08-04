import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT Direct CFDI IVA Tests', () {
    test('Should use direct IVA value from CFDI TotalImpuestosTrasladados', () {
      print('=== TEST: Usar valor directo de TotalImpuestosTrasladados ===');

      // CFDI con TotalImpuestosTrasladados específico
      final cfdiData = {
        'SubTotal': '1000.00',
        'Emisor': {'Rfc': 'ABC123456789'},
        'Impuestos': {'TotalImpuestosTrasladados': '160.00'},
      };

      final cfdi = CFDI.fromJson(cfdiData);

      // Configuración de prueba
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

      print(
        'Valor directo de TotalImpuestosTrasladados: \$${cfdi.impuestos!.totalImpuestosTrasladados}',
      );
      print('IVA mapeado en DIOT: \$${record.ivaAcreditableExclusivo16}');

      expect(record.ivaAcreditableExclusivo16, 160.0);
      print('✅ SUCCESS: Usa valor directo del CFDI');
    });
  });
}
