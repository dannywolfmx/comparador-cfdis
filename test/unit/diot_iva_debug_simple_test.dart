import 'package:flutter_test/flutter_test.dart';
import 'package:comparador_cfdis/models/cfdi.dart';
import 'package:comparador_cfdis/models/diot_batch.dart';
import 'package:comparador_cfdis/services/diot_mapping_service.dart';
import 'package:comparador_cfdis/constants/diot_constants.dart';

void main() {
  group('DIOT IVA Debug Simple Tests', () {
    test('Debug TotalImpuestosTrasladados usage and fallback behavior', () {
      print('=== TEST: Debug uso de TotalImpuestosTrasladados y fallback ===');

      // Caso 1: Con TotalImpuestosTrasladados válido
      final cfdiConIva = CFDI.fromJson({
        'SubTotal': '1000.00',
        'Emisor': {'Rfc': 'TEST123456789'},
        'Impuestos': {'TotalImpuestosTrasladados': '160.00'},
      });

      // Caso 2: Sin TotalImpuestosTrasladados (fallback)
      final cfdiSinIva = CFDI.fromJson({
        'SubTotal': '1000.00',
        'Emisor': {'Rfc': 'TEST987654321'},
      });

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

      final recordsConIva =
          DIOTMappingService.mapCFDIsToRecords([cfdiConIva], configuration);
      final recordsSinIva =
          DIOTMappingService.mapCFDIsToRecords([cfdiSinIva], configuration);

      print(
        'Con TotalImpuestosTrasladados: \$${recordsConIva.first.ivaAcreditableExclusivo16}',
      );
      print(
        'Sin TotalImpuestosTrasladados (fallback): \$${recordsSinIva.first.ivaAcreditableExclusivo16}',
      );

      expect(recordsConIva.first.ivaAcreditableExclusivo16, 160.0);
      expect(recordsSinIva.first.ivaAcreditableExclusivo16, 0.0);

      print('✅ SUCCESS: Uso directo y fallback funcionan correctamente');
    });
  });
}
